import Foundation

public struct PeakStatusInfo: Sendable, Equatable {
    public let status: PeakStatus
    public let reason: String
    public let periodStart: Date
    public let periodEnd: Date
    public let nextTransition: Date
    public let nextStatus: PeakStatus
    public let isChineseHoliday: Bool
    public let holidayName: String?
    public let isWeekend: Bool
    public let currentDate: Date
    public let utcCalendarDateString: String // e.g. "2026-10-05"

    /// `true` when no validated holiday calendar exists for the current year. In that case
    /// the status may still be reported, but it cannot account for Chinese public holidays.
    public let isHolidayDataMissing: Bool

    /// Provenance label of the loaded calendar for the current year, if known.
    public let holidaySource: String?

    public init(
        status: PeakStatus,
        reason: String,
        periodStart: Date,
        periodEnd: Date,
        nextTransition: Date,
        nextStatus: PeakStatus,
        isChineseHoliday: Bool,
        holidayName: String? = nil,
        isWeekend: Bool,
        currentDate: Date,
        utcCalendarDateString: String,
        isHolidayDataMissing: Bool = false,
        holidaySource: String? = nil
    ) {
        self.status = status
        self.reason = reason
        self.periodStart = periodStart
        self.periodEnd = periodEnd
        self.nextTransition = nextTransition
        self.nextStatus = nextStatus
        self.isChineseHoliday = isChineseHoliday
        self.holidayName = holidayName
        self.isWeekend = isWeekend
        self.currentDate = currentDate
        self.utcCalendarDateString = utcCalendarDateString
        self.isHolidayDataMissing = isHolidayDataMissing
        self.holidaySource = holidaySource
    }

    /// Time interval remaining until the current period ends (or until next transition).
    public func timeRemaining(at referenceDate: Date = Date()) -> TimeInterval {
        max(0, periodEnd.timeIntervalSince(referenceDate))
    }
}
