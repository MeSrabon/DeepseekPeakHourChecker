import Foundation

/// Coordinates the bundled, cached, and remote holiday calendars.
///
/// Downloaded calendars are validated by `HolidayCalendarValidator` before they are written,
/// so an incomplete upstream response can never overwrite good bundled data.
public final class HolidayService: HolidayProvider, @unchecked Sendable {
    public static let shared = HolidayService()
    public static let didUpdateHolidaysNotification = Notification.Name("DeepSeekPeakHours.didUpdateHolidays")

    private let localProvider: LocalHolidayProvider
    private let remoteProvider: RemoteChineseHolidayProvider
    private let lock = NSLock()
    private var lastErrorMessage: String?

    public init(
        localProvider: LocalHolidayProvider = LocalHolidayProvider(),
        remoteProvider: RemoteChineseHolidayProvider = RemoteChineseHolidayProvider()
    ) {
        self.localProvider = localProvider
        self.remoteProvider = remoteProvider
    }

    // MARK: HolidayProvider

    public func isHoliday(dateString: String) -> (isHoliday: Bool, holiday: ChineseHoliday?) {
        localProvider.isHoliday(dateString: dateString)
    }

    public func holidays(for year: Int) -> [ChineseHoliday] {
        localProvider.holidays(for: year)
    }

    public func hasHolidayData(for year: Int) -> Bool {
        localProvider.hasHolidayData(for: year)
    }

    public var availableYears: [Int] {
        localProvider.availableYears
    }

    public func source(for year: Int) -> String? {
        localProvider.source(for: year)
    }

    // MARK: Status

    public var lastError: String? {
        lock.lock()
        defer { lock.unlock() }
        return lastErrorMessage
    }

    private func setLastError(_ message: String?) {
        lock.lock()
        defer { lock.unlock() }
        lastErrorMessage = message
    }

    public var statusDescription: String {
        let years = availableYears.map(String.init).joined(separator: ", ")
        let source = availableYears.last.flatMap { localProvider.source(for: $0) } ?? "Bundled"
        if let lastRefresh = AppSettings.shared.lastHolidayRefresh {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return "Active (Years: \(years)) · \(source) · Last refreshed: \(formatter.string(from: lastRefresh))"
        }
        return "Active (Years: \(years)) · \(source)"
    }

    /// A user-facing warning when a queried year has no validated holiday data.
    public func missingDataDescription(for year: Int) -> String? {
        guard !hasHolidayData(for: year) else { return nil }
        return "No holiday calendar is available for \(year). Peak hours may be shown incorrectly on Chinese public holidays."
    }

    // MARK: Refresh

    /// Downloads and validates holiday calendars. A year is only accepted when the response
    /// passes `HolidayCalendarValidator`, so a degraded upstream response cannot corrupt the
    /// cache. Returns `true` when at least one year was successfully updated.
    @discardableResult
    public func refreshHolidays(years: [Int]? = nil) async -> Bool {
        let targetYears = years ?? HolidayCalendarValidator.defaultRefreshYears()
        var successCount = 0
        var errors: [String] = []

        for year in targetYears {
            do {
                let calendar = try await remoteProvider.fetchHolidays(year: year)
                if localProvider.saveDownloadedCalendar(calendar) {
                    successCount += 1
                } else {
                    errors.append("Year \(year): rejected incomplete holiday calendar")
                }
            } catch {
                errors.append("Year \(year): \(error.localizedDescription)")
            }
        }

        setLastError(errors.isEmpty ? nil : errors.joined(separator: "; "))

        if successCount > 0 {
            AppSettings.shared.lastHolidayRefresh = Date()
            NotificationCenter.default.post(name: HolidayService.didUpdateHolidaysNotification, object: self)
            return true
        }

        return false
    }
}
