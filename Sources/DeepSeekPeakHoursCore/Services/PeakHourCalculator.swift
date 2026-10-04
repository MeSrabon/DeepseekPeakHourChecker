import Foundation

/// Authoritative calculation of DeepSeek pricing periods.
///
/// Schedule rule:
/// - Peak hours: 01:00–04:00 UTC and 06:00–10:00 UTC, Monday through Friday, excluding
///   Chinese statutory public holidays.
/// - Off-peak: all other times, including weekends and the entire duration of Chinese public
///   holidays.
///
/// Date & timezone integrity:
/// DeepSeek's schedule intervals ([01:00, 04:00) UTC and [06:00, 10:00) UTC) fall strictly
/// within the same calendar day in UTC. In China Standard Time (UTC+8), 01:00 UTC is 09:00 CST
/// and 10:00 UTC is 18:00 CST on the same calendar date. The weekday and holiday status of a
/// date are therefore evaluated with a UTC calendar. Local times (e.g. Asia/Dhaka, UTC+6) are
/// projected from those instants using Foundation's Calendar/TimeZone APIs for display only.
public final class PeakHourCalculator: @unchecked Sendable {
    public static let shared = PeakHourCalculator()

    /// Peak windows expressed in UTC, as half-open ranges `[startHour, endHour)`.
    /// Sourced from the official schedule (`DeepSeekSchedule`).
    public static let peakWindowsUTC: [Range<Int>] = DeepSeekSchedule.peakWindowsUTC

    private let holidayProvider: HolidayProvider
    private let utcCalendar: Calendar
    private let dateFormatter: DateFormatter

    public init(holidayProvider: HolidayProvider = HolidayService.shared) {
        self.holidayProvider = holidayProvider

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        self.utcCalendar = cal

        let df = DateFormatter()
        df.calendar = cal
        df.timeZone = TimeZone(secondsFromGMT: 0)!
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"
        self.dateFormatter = df
    }

    /// Evaluates the status at a given instant in time.
    public func status(at date: Date) -> PeakStatus {
        let utcComponents = utcCalendar.dateComponents([.year, .month, .day, .hour, .minute, .weekday], from: date)
        guard let weekday = utcComponents.weekday,
              let hour = utcComponents.hour,
              let minute = utcComponents.minute else {
            return .offPeak
        }

        // Sunday = 1, Saturday = 7 in the Gregorian calendar; Monday = 2 … Friday = 6.
        let isWeekday = (weekday >= 2 && weekday <= 6)
        guard isWeekday else { return .offPeak }

        // Chinese public holidays waive peak pricing for the whole UTC day.
        let dateString = dateFormatter.string(from: date)
        if holidayProvider.isHoliday(dateString: dateString).isHoliday {
            return .offPeak
        }

        let minuteOfDay = hour * 60 + minute
        let inPeakWindow = Self.peakWindowsUTC.contains { window in
            minuteOfDay >= window.lowerBound * 60 && minuteOfDay < window.upperBound * 60
        }
        return inPeakWindow ? .peak : .offPeak
    }

    /// Computes full diagnostic and status information at a given instant.
    public func statusInfo(at date: Date, displayTimeZone: TimeZone = .current) -> PeakStatusInfo {
        let currentStatus = status(at: date)
        let utcComponents = utcCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: date)
        let weekday = utcComponents.weekday ?? 1
        let isWeekend = (weekday == 1 || weekday == 7)
        let dateString = dateFormatter.string(from: date)
        let holidayCheck = holidayProvider.isHoliday(dateString: dateString)
        let year = utcComponents.year ?? utcCalendar.component(.year, from: date)
        let hasHolidayData = holidayProvider.hasHolidayData(for: year)

        let nextTrans = nextTransition(after: date)
        let nextStat: PeakStatus = (currentStatus == .peak) ? .offPeak : .peak
        let prevTrans = previousTransition(before: date)

        let reason = reason(
            for: currentStatus,
            date: date,
            isWeekend: isWeekend,
            holidayCheck: holidayCheck,
            displayTimeZone: displayTimeZone
        )

        return PeakStatusInfo(
            status: currentStatus,
            reason: reason,
            periodStart: prevTrans,
            periodEnd: nextTrans,
            nextTransition: nextTrans,
            nextStatus: nextStat,
            isChineseHoliday: holidayCheck.isHoliday,
            holidayName: holidayCheck.holiday?.name,
            isWeekend: isWeekend,
            currentDate: date,
            utcCalendarDateString: dateString,
            isHolidayDataMissing: !hasHolidayData,
            holidaySource: hasHolidayData ? holidayProvider.source(for: year) : nil
        )
    }

    private func reason(
        for status: PeakStatus,
        date: Date,
        isWeekend: Bool,
        holidayCheck: (isHoliday: Bool, holiday: ChineseHoliday?),
        displayTimeZone: TimeZone
    ) -> String {
        switch status {
        case .peak:
            return peakWindowDescription(for: date, in: displayTimeZone)
        case .offPeak:
            if isWeekend {
                return "Weekend"
            }
            if holidayCheck.isHoliday {
                let name = holidayCheck.holiday?.name ?? "Public Holiday"
                return "Chinese public holiday (\(name))"
            }
            return "Outside peak hours"
        }
    }

    /// Builds a human-readable peak-window label in both UTC and the display timezone.
    private func peakWindowDescription(for date: Date, in displayTimeZone: TimeZone) -> String {
        let hour = utcCalendar.component(.hour, from: date)
        guard let window = Self.peakWindowsUTC.first(where: { $0.contains(hour) }) else {
            return "Peak hours"
        }

        let utcLabel = String(format: "%02d:00–%02d:00 UTC", window.lowerBound, window.upperBound)
        guard displayTimeZone.secondsFromGMT(for: date) != 0 else {
            return "Peak window (\(utcLabel))"
        }

        guard let start = utcCalendar.date(bySettingHour: window.lowerBound, minute: 0, second: 0, of: date),
              let end = utcCalendar.date(bySettingHour: window.upperBound, minute: 0, second: 0, of: date) else {
            return "Peak window (\(utcLabel))"
        }

        let formatter = DateFormatter()
        formatter.timeZone = displayTimeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        let abbreviation = displayTimeZone.abbreviation(for: date) ?? displayTimeZone.identifier
        return "Peak window (\(utcLabel) · \(formatter.string(from: start))–\(formatter.string(from: end)) \(abbreviation))"
    }

    /// Finds the earliest instant strictly after `date` where the status flips.
    ///
    /// Status can only change at 01:00, 04:00, 06:00, and 10:00 UTC; because off-peak spans
    /// 10:00 → 01:00, the state never changes at a UTC midnight boundary.
    public func nextTransition(after date: Date) -> Date {
        var searchDate = utcCalendar.startOfDay(for: date)
        let current = status(at: date)

        // Search up to 21 days ahead (sufficient for Spring Festival / Golden Week).
        for _ in 0..<21 {
            for hour in DeepSeekSchedule.transitionHoursUTC {
                if let candidate = utcCalendar.date(bySettingHour: hour, minute: 0, second: 0, of: searchDate),
                   candidate > date {
                    let testInstant = candidate.addingTimeInterval(1)
                    if status(at: testInstant) != current {
                        return candidate
                    }
                }
            }
            guard let nextDay = utcCalendar.date(byAdding: .day, value: 1, to: searchDate) else { break }
            searchDate = nextDay
        }

        // Fallback safety net (should not be reached for any real calendar).
        return date.addingTimeInterval(3600)
    }

    /// Finds the instant strictly before or at `date` when the current status started.
    public func previousTransition(before date: Date) -> Date {
        var searchDate = utcCalendar.startOfDay(for: date)
        let current = status(at: date)

        for _ in 0..<21 {
            for hour in DeepSeekSchedule.transitionHoursUTC.reversed() {
                if let candidate = utcCalendar.date(bySettingHour: hour, minute: 0, second: 0, of: searchDate),
                   candidate <= date {
                    let testBefore = candidate.addingTimeInterval(-1)
                    if status(at: testBefore) != current {
                        return candidate
                    }
                }
            }
            guard let prevDay = utcCalendar.date(byAdding: .day, value: -1, to: searchDate) else { break }
            searchDate = prevDay
        }

        return utcCalendar.startOfDay(for: date)
    }

    /// Returns the day's schedule intervals for a given date in the specified timezone.
    public func dailySchedule(for date: Date, in timeZone: TimeZone) -> [PeakPeriod] {
        var localCalendar = Calendar(identifier: .gregorian)
        localCalendar.timeZone = timeZone

        let startOfLocalDay = localCalendar.startOfDay(for: date)
        guard let endOfLocalDay = localCalendar.date(byAdding: .day, value: 1, to: startOfLocalDay) else {
            return []
        }

        var periods: [PeakPeriod] = []
        var currentInstant = startOfLocalDay

        while currentInstant < endOfLocalDay {
            let currentStat = status(at: currentInstant)
            let nextTrans = nextTransition(after: currentInstant)
            let periodEnd = min(nextTrans, endOfLocalDay)
            let label = (currentStat == .peak) ? "Peak" : "Off-peak"

            periods.append(PeakPeriod(start: currentInstant, end: periodEnd, status: currentStat, label: label))
            currentInstant = periodEnd
        }

        return periods
    }

    /// Convenience helper to check whether a specific UTC calendar day is peak-eligible
    /// (i.e. Monday–Friday and not a Chinese public holiday).
    public func isPeakEligibleDay(utcDate: Date) -> (eligible: Bool, holiday: ChineseHoliday?, isWeekend: Bool) {
        let utcComponents = utcCalendar.dateComponents([.weekday], from: utcDate)
        let weekday = utcComponents.weekday ?? 1
        let isWeekend = (weekday == 1 || weekday == 7)
        if isWeekend {
            return (false, nil, true)
        }
        let dateString = dateFormatter.string(from: utcDate)
        let check = holidayProvider.isHoliday(dateString: dateString)
        if check.isHoliday {
            return (false, check.holiday, false)
        }
        return (true, nil, false)
    }

    /// Whether a validated holiday calendar exists for the calendar year of `date`.
    public func hasHolidayData(for date: Date) -> Bool {
        let year = utcCalendar.component(.year, from: date)
        return holidayProvider.hasHolidayData(for: year)
    }
}
