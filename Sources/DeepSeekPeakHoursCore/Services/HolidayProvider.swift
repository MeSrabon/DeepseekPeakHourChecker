import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Abstraction over the Chinese statutory holiday calendar used to waive DeepSeek peak hours.
public protocol HolidayProvider: Sendable {
    /// Returns the holiday (off-day) for a `yyyy-MM-dd` UTC date, if any.
    func isHoliday(dateString: String) -> (isHoliday: Bool, holiday: ChineseHoliday?)

    /// All entries (off-days and make-up working days) for a year.
    func holidays(for year: Int) -> [ChineseHoliday]

    /// Whether a complete, validated calendar is available for the given year.
    func hasHolidayData(for year: Int) -> Bool

    /// Provenance label for a loaded year, if known.
    func source(for year: Int) -> String?

    /// Years for which a validated calendar is currently loaded.
    var availableYears: [Int] { get }
}

public extension HolidayProvider {
    func source(for year: Int) -> String? { nil }
}

// MARK: - Local (bundled + cached) provider

public final class LocalHolidayProvider: HolidayProvider, @unchecked Sendable {
    private let lock = NSLock()

    /// Only public holidays (off-days) are indexed for lookup; make-up working days are
    /// deliberately excluded so they never waive peak pricing.
    private var holidaysByDate: [String: ChineseHoliday] = [:]
    private var holidaysByYear: [Int: [ChineseHoliday]] = [:]
    private var sourcesByYear: [Int: String] = [:]

    private let fileManager = FileManager.default
    private let bundle: Bundle

    public init(bundle: Bundle? = nil) {
        self.bundle = bundle ?? Bundle.module
        loadAllAvailableHolidays()
    }

    private var appSupportHolidaysDirectory: URL? {
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let dir = appSupport.appendingPathComponent("DeepSeekPeakHours/Holidays", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// Loads every calendar discoverable from the bundle or the on-disk cache. Bundled data
    /// is always the trust baseline; cached data is only used when it passes validation.
    public func loadAllAvailableHolidays() {
        lock.lock()
        defer { lock.unlock() }

        holidaysByDate.removeAll()
        holidaysByYear.removeAll()
        sourcesByYear.removeAll()

        let years = Set(discoverBundledYears()).union(discoverCachedYears()).sorted()
        for year in years {
            loadYearLocked(year)
        }
    }

    public func loadYear(_ year: Int) {
        lock.lock()
        defer { lock.unlock() }
        loadYearLocked(year)
    }

    private func loadYearLocked(_ year: Int) {
        let baseline = loadBundledCalendar(year)

        if let cached = loadCachedCalendar(year),
           HolidayCalendarValidator.isAcceptable(cached, comparedToBaseline: baseline) {
            ingest(cached)
            return
        }

        if let baseline, HolidayCalendarValidator.isPlausible(baseline) {
            ingest(baseline)
        }
    }

    /// Persists a downloaded calendar, but only after it passes validation. Returns `false`
    /// when the data was rejected (e.g. an incomplete upstream response) so callers can
    /// report the failure instead of silently corrupting the cache.
    @discardableResult
    public func saveDownloadedCalendar(_ calendar: ChineseHolidayCalendar) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        let baseline = loadBundledCalendar(calendar.year)
        guard HolidayCalendarValidator.isAcceptable(calendar, comparedToBaseline: baseline) else {
            return false
        }

        ingest(calendar)

        if let cacheDir = appSupportHolidaysDirectory {
            let cachedFile = cacheDir.appendingPathComponent("china-\(calendar.year).json")
            if let data = try? JSONEncoder().encode(calendar) {
                try? data.write(to: cachedFile, options: .atomic)
            }
        }
        return true
    }

    // MARK: Ingest / decode

    private func ingest(_ calendar: ChineseHolidayCalendar) {
        holidaysByYear[calendar.year] = calendar.holidays
        sourcesByYear[calendar.year] = calendar.source ?? (calendar.provisional ? "Projection" : "Bundled")

        // Index off-days only. Make-up working days must never waive peak pricing.
        for holiday in calendar.offDays {
            holidaysByDate[holiday.date] = holiday
        }
    }

    private func loadBundledCalendar(_ year: Int) -> ChineseHolidayCalendar? {
        if let url = bundledURL(for: year) {
            if let data = try? Data(contentsOf: url),
               let calendar = try? JSONDecoder().decode(ChineseHolidayCalendar.self, from: data) {
                return calendar
            }
        }

        for path in [
            "Resources/Holidays/china-\(year).json",
            "Sources/DeepSeekPeakHoursCore/Resources/Holidays/china-\(year).json"
        ] {
            if fileManager.fileExists(atPath: path),
               let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
               let calendar = try? JSONDecoder().decode(ChineseHolidayCalendar.self, from: data) {
                return calendar
            }
        }
        return nil
    }

    private func loadCachedCalendar(_ year: Int) -> ChineseHolidayCalendar? {
        guard let cacheDir = appSupportHolidaysDirectory else { return nil }
        let cachedFile = cacheDir.appendingPathComponent("china-\(year).json")
        guard fileManager.fileExists(atPath: cachedFile.path),
              let data = try? Data(contentsOf: cachedFile),
              let calendar = try? JSONDecoder().decode(ChineseHolidayCalendar.self, from: data) else {
            return nil
        }
        return calendar
    }

    private func bundledURL(for year: Int) -> URL? {
        let fileName = "china-\(year)"
        return bundle.url(forResource: fileName, withExtension: "json", subdirectory: "Holidays")
            ?? bundle.url(forResource: fileName, withExtension: "json")
    }

    private func discoverBundledYears() -> [Int] {
        var years = Set<Int>()
        for subdirectory in ["Holidays", nil] {
            let urls = bundle.urls(forResourcesWithExtension: "json", subdirectory: subdirectory) ?? []
            for url in urls {
                if let year = Self.parseYear(from: url.deletingPathExtension().lastPathComponent) {
                    years.insert(year)
                }
            }
        }
        return years.sorted()
    }

    private func discoverCachedYears() -> [Int] {
        guard let cacheDir = appSupportHolidaysDirectory,
              let contents = try? fileManager.contentsOfDirectory(at: cacheDir, includingPropertiesForKeys: nil) else {
            return []
        }
        return contents.compactMap { Self.parseYear(from: $0.deletingPathExtension().lastPathComponent) }
    }

    /// Parses `china-2026` into `2026`.
    static func parseYear(from fileName: String) -> Int? {
        guard fileName.hasPrefix("china-") else { return nil }
        let suffix = fileName.dropFirst("china-".count)
        guard suffix.count == 4, let year = Int(suffix) else { return nil }
        return year
    }

    // MARK: HolidayProvider

    public func isHoliday(dateString: String) -> (isHoliday: Bool, holiday: ChineseHoliday?) {
        lock.lock()
        defer { lock.unlock() }

        if let holiday = holidaysByDate[dateString] {
            return (true, holiday)
        }
        return (false, nil)
    }

    public func holidays(for year: Int) -> [ChineseHoliday] {
        lock.lock()
        defer { lock.unlock() }
        return holidaysByYear[year] ?? []
    }

    public func hasHolidayData(for year: Int) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return holidaysByYear[year] != nil
    }

    public var availableYears: [Int] {
        lock.lock()
        defer { lock.unlock() }
        return holidaysByYear.keys.sorted()
    }

    /// Provenance label for a loaded year, used in the settings UI.
    public func source(for year: Int) -> String? {
        lock.lock()
        defer { lock.unlock() }
        return sourcesByYear[year]
    }
}

// MARK: - Remote provider (State Council mirror)

/// Downloads the official State Council holiday schedule from the machine-readable
/// `NateScarlet/holiday-cn` mirror. Unlike the previous Nager.Date integration, this source
/// includes the full multi-day holiday spans and the 调休 make-up working days.
public final class RemoteChineseHolidayProvider: @unchecked Sendable {
    public static let endpointTemplate = "https://raw.githubusercontent.com/NateScarlet/holiday-cn/master/%d.json"
    public static let dataSourceName = "State Council of the PRC (mirror: NateScarlet/holiday-cn)"

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    // Source schema: { "year": 2026, "days": [ { "name": "国庆节", "date": "2026-10-01", "isOffDay": true } ] }
    struct SourceDay: Codable {
        let name: String
        let date: String
        let isOffDay: Bool
    }

    struct SourceCalendar: Codable {
        let year: Int?
        let days: [SourceDay]
    }

    public func fetchHolidays(year: Int) async throws -> ChineseHolidayCalendar {
        guard let url = URL(string: String(format: Self.endpointTemplate, year)) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("DeepSeekPeakHours/1.0 (macOS)", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try Self.parse(data: data, year: year)
    }

    /// Pure parser, exposed for testing with fixture data.
    public static func parse(data: Data, year: Int) throws -> ChineseHolidayCalendar {
        let decoded = try JSONDecoder().decode(SourceCalendar.self, from: data)
        let sourceYear = decoded.year ?? year

        let holidays = decoded.days.map { day -> ChineseHoliday in
            let (english, chinese) = translatedName(day.name)
            let displayName = day.isOffDay ? english : "\(english) (Make-up Workday)"
            return ChineseHoliday(date: day.date, name: displayName, chineseName: chinese, isOffDay: day.isOffDay)
        }

        let formatter = ISO8601DateFormatter()
        return ChineseHolidayCalendar(
            country: "CN",
            year: sourceYear,
            holidays: holidays,
            source: dataSourceName,
            retrievedAt: formatter.string(from: Date()),
            provisional: false
        )
    }

    /// Maps the Chinese festival names returned by the source to friendly English names.
    public static func translatedName(_ chinese: String) -> (english: String, chinese: String) {
        if let known = nameMap[chinese] {
            return (known, chinese)
        }
        return (chinese, chinese)
    }

    private static let nameMap: [String: String] = [
        "元旦": "New Year's Day",
        "春节": "Spring Festival (Chinese New Year)",
        "清明节": "Qingming Festival",
        "劳动节": "Labor Day",
        "端午节": "Dragon Boat Festival",
        "中秋节": "Mid-Autumn Festival",
        "国庆节": "National Day",
        "国庆节、中秋节": "National Day / Mid-Autumn Festival"
    ]
}
