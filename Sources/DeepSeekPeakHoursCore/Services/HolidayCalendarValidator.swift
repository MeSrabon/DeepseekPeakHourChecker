import Foundation

/// Validates Chinese holiday calendars before they are trusted or allowed to replace an
/// existing calendar.
///
/// This exists because the historical remote source (Nager.Date) returned only the six core
/// statutory days and omitted the multi-day State Council holiday spans. Blindly persisting
/// such a response silently downgraded Golden Week and Spring Festival to peak-eligible
/// working days. Every calendar — bundled, cached, or freshly downloaded — must now pass
/// `isAcceptable` before it can be used or written.
public enum HolidayCalendarValidator {

    /// A complete State Council year has far more than this many days off. Six is the value
    /// returned by the old, incomplete remote source; ten rejects it with a wide margin
    /// while still accepting any genuine year.
    public static let minimumOffDays = 10

    /// The three fixed solar holidays that must always appear in a Chinese holiday calendar.
    private static let requiredMonthDays = ["01-01", "05-01", "10-01"]

    /// Returns `true` when the calendar looks like a genuine, complete Chinese holiday year.
    public static func isPlausible(_ calendar: ChineseHolidayCalendar) -> Bool {
        guard calendar.country.uppercased() == "CN" else { return false }

        let offDays = calendar.offDays
        guard offDays.count >= minimumOffDays else { return false }

        let dates = Set(offDays.map { $0.date })
        let yearPrefix = String(calendar.year)
        for monthDay in requiredMonthDays where !dates.contains("\(yearPrefix)-\(monthDay)") {
            return false
        }

        // A genuine year always contains at least one multi-day off span; the incomplete
        // remote source contained only singletons.
        guard hasConsecutiveOffDays(offDays, minimum: 3) else { return false }

        return true
    }

    /// Decides whether `candidate` may replace the currently trusted calendar for its year.
    ///
    /// - A candidate that is not `isPlausible` is always rejected.
    /// - When no baseline exists, a plausible candidate is accepted.
    /// - When the baseline is provisional (an unpublished-year estimate), an authoritative
    ///   candidate may replace it even if it differs.
    /// - When the baseline is authoritative, the candidate must not drop any off-day the
    ///   baseline already recognised. This is the guard that prevents a reduced dataset
    ///   from ever regressing holiday coverage.
    public static func isAcceptable(
        _ candidate: ChineseHolidayCalendar,
        comparedToBaseline baseline: ChineseHolidayCalendar?
    ) -> Bool {
        guard isPlausible(candidate) else { return false }
        guard let baseline else { return true }
        if baseline.provisional { return true }

        let candidateOff = Set(candidate.offDays.map { $0.date })
        let baselineOff = Set(baseline.offDays.map { $0.date })
        return baselineOff.isSubset(of: candidateOff)
    }

    /// Years worth refreshing around a reference date (previous, current, and next two).
    public static func defaultRefreshYears(reference: Date = Date()) -> [Int] {
        let year = utcCalendar.component(.year, from: reference)
        return Array((year - 1)...(year + 2))
    }

    // MARK: - Helpers

    private static var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private static func hasConsecutiveOffDays(_ holidays: [ChineseHoliday], minimum: Int) -> Bool {
        let calendar = utcCalendar
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        let dates = holidays
            .compactMap { formatter.date(from: $0.date) }
            .map { calendar.startOfDay(for: $0) }
            .sorted()

        guard !dates.isEmpty else { return false }

        var run = 1
        for index in 1..<dates.count {
            let previous = dates[index - 1]
            let current = dates[index]
            let expectedNext = calendar.date(byAdding: .day, value: 1, to: previous)
            if let expectedNext, calendar.isDate(expectedNext, inSameDayAs: current) {
                run += 1
                if run >= minimum { return true }
            } else {
                run = 1
            }
        }
        return run >= minimum
    }
}
