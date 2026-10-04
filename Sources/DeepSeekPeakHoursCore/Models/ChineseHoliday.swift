import Foundation

/// A single entry in the Chinese statutory holiday calendar.
///
/// Entries are keyed by the Gregorian calendar date in UTC (`yyyy-MM-dd`). Because both
/// DeepSeek peak windows (01:00–04:00 UTC and 06:00–10:00 UTC) map onto the same calendar
/// date in China Standard Time (UTC+8), the UTC date is the correct key for determining
/// whether peak pricing is waived.
public struct ChineseHoliday: Codable, Sendable, Equatable, Identifiable {
    public var id: String { "\(date)_\(name)" }

    /// Gregorian date formatted as `yyyy-MM-dd`.
    public let date: String

    /// Friendly (English) name, e.g. `"National Day"`.
    public let name: String

    /// Original Chinese name, e.g. `"国庆节"`.
    public let chineseName: String?

    /// `true` when the State Council designates this date as a public holiday (a day off).
    /// `false` for 调休 make-up working days, which are recorded for completeness but are
    /// **not** holidays.
    public let isOffDay: Bool

    public init(date: String, name: String, chineseName: String? = nil, isOffDay: Bool = true) {
        self.date = date
        self.name = name
        self.chineseName = chineseName
        self.isOffDay = isOffDay
    }

    // Backwards compatible decoding: older bundled files omit `isOffDay`, in which case the
    // entry is treated as a holiday. `chineseName` is also optional.
    enum CodingKeys: String, CodingKey {
        case date, name, chineseName, isOffDay
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(String.self, forKey: .date)
        self.name = try container.decode(String.self, forKey: .name)
        self.chineseName = try container.decodeIfPresent(String.self, forKey: .chineseName)
        self.isOffDay = try container.decodeIfPresent(Bool.self, forKey: .isOffDay) ?? true
    }
}

/// A full-year Chinese holiday calendar plus provenance metadata.
public struct ChineseHolidayCalendar: Codable, Sendable, Equatable {
    public let country: String
    public let year: Int
    public let holidays: [ChineseHoliday]

    /// Human-readable provenance, e.g. `"State Council of the PRC (mirror: holiday-cn)"`.
    public let source: String?

    /// ISO-8601 timestamp describing when the calendar was generated/retrieved.
    public let retrievedAt: String?

    /// `true` when the calendar is an estimate for a year whose official schedule has not
    /// yet been published by the State Council. Provisional calendars must never override
    /// an authoritative one.
    public let provisional: Bool

    public init(
        country: String,
        year: Int,
        holidays: [ChineseHoliday],
        source: String? = nil,
        retrievedAt: String? = nil,
        provisional: Bool = false
    ) {
        self.country = country
        self.year = year
        self.holidays = holidays
        self.source = source
        self.retrievedAt = retrievedAt
        self.provisional = provisional
    }

    /// Only the days that actually waive peak pricing.
    public var offDays: [ChineseHoliday] {
        holidays.filter { $0.isOffDay }
    }

    /// Make-up working days (调休) recorded for completeness.
    public var makeUpWorkdays: [ChineseHoliday] {
        holidays.filter { !$0.isOffDay }
    }

    enum CodingKeys: String, CodingKey {
        case country, year, holidays, source, retrievedAt, provisional
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.country = try container.decode(String.self, forKey: .country)
        self.year = try container.decode(Int.self, forKey: .year)
        self.holidays = try container.decode([ChineseHoliday].self, forKey: .holidays)
        self.source = try container.decodeIfPresent(String.self, forKey: .source)
        self.retrievedAt = try container.decodeIfPresent(String.self, forKey: .retrievedAt)
        self.provisional = try container.decodeIfPresent(Bool.self, forKey: .provisional) ?? false
    }
}
