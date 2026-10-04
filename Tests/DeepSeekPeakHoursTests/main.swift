import Foundation
import DeepSeekPeakHoursCore

var testPassed = 0
var testFailed = 0

func assertEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String, file: String = #file, line: Int = #line) {
    if actual == expected {
        testPassed += 1
        print("  ✓ \(message)")
    } else {
        testFailed += 1
        print("  ✗ FAILED: \(message)")
        print("    Expected: \(expected), got: \(actual)")
        print("    At \(file):\(line)")
    }
}

func assertTrue(_ condition: Bool, _ message: String, file: String = #file, line: Int = #line) {
    if condition {
        testPassed += 1
        print("  ✓ \(message)")
    } else {
        testFailed += 1
        print("  ✗ FAILED: \(message)")
        print("    At \(file):\(line)")
    }
}

var utcCalendar = Calendar(identifier: .gregorian)
utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!

let dhakaTimeZone = TimeZone(identifier: "Asia/Dhaka") ?? TimeZone(secondsFromGMT: 6 * 3600)!
let calculator = PeakHourCalculator(holidayProvider: HolidayService.shared)

func makeUTCDate(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int = 0) -> Date {
    var comps = DateComponents()
    comps.year = year
    comps.month = month
    comps.day = day
    comps.hour = hour
    comps.minute = minute
    comps.second = second
    return utcCalendar.date(from: comps)!
}

print("=======================================================")
print("  DeepSeek Peak Hour Checker — Comprehensive Test Suite")
print("=======================================================\n")

// MARK: - 1. Monday Peak
print("[Test Group 1] Monday Peak Hours")
// 2026-10-12 is regular Monday
let tMonPeak1 = makeUTCDate(year: 2026, month: 10, day: 12, hour: 1, minute: 30)
assertEqual(calculator.status(at: tMonPeak1), .peak, "Monday 01:30 UTC is Peak")

// MARK: - 2. Monday Off-Peak
print("\n[Test Group 2] Monday Between-Peak Off-Peak")
let tMonOff1 = makeUTCDate(year: 2026, month: 10, day: 12, hour: 4, minute: 30)
assertEqual(calculator.status(at: tMonOff1), .offPeak, "Monday 04:30 UTC is Off-Peak")

// MARK: - 3. Second Peak
print("\n[Test Group 3] Monday Second Peak Hours")
let tMonPeak2 = makeUTCDate(year: 2026, month: 10, day: 12, hour: 6, minute: 30)
assertEqual(calculator.status(at: tMonPeak2), .peak, "Monday 06:30 UTC is Peak")

// MARK: - 4. After Second Peak
print("\n[Test Group 4] Monday After Second Peak")
let tMonOff2 = makeUTCDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30)
assertEqual(calculator.status(at: tMonOff2), .offPeak, "Monday 10:30 UTC is Off-Peak")

// MARK: - 5. Weekend
print("\n[Test Group 5] Weekend Periods")
// 2026-10-10 is Saturday
let tSat = makeUTCDate(year: 2026, month: 10, day: 10, hour: 2, minute: 0)
assertEqual(calculator.status(at: tSat), .offPeak, "Saturday 02:00 UTC is Off-Peak")
// 2026-10-11 is Sunday
let tSun = makeUTCDate(year: 2026, month: 10, day: 11, hour: 7, minute: 0)
assertEqual(calculator.status(at: tSun), .offPeak, "Sunday 07:00 UTC is Off-Peak")

// MARK: - 6. Friday Both Peaks & Weekend Transition
print("\n[Test Group 6] Friday Both Peaks & Weekend Transition")
let tFriPeak1 = makeUTCDate(year: 2026, month: 10, day: 16, hour: 2, minute: 0)
assertEqual(calculator.status(at: tFriPeak1), .peak, "Friday 02:00 UTC is Peak")
let tFriMid = makeUTCDate(year: 2026, month: 10, day: 16, hour: 5, minute: 0)
assertEqual(calculator.status(at: tFriMid), .offPeak, "Friday 05:00 UTC is Off-Peak")
let tFriPeak2 = makeUTCDate(year: 2026, month: 10, day: 16, hour: 8, minute: 0)
assertEqual(calculator.status(at: tFriPeak2), .peak, "Friday 08:00 UTC is Peak")
let tFriNight = makeUTCDate(year: 2026, month: 10, day: 16, hour: 11, minute: 0)
assertEqual(calculator.status(at: tFriNight), .offPeak, "Friday 11:00 UTC is Off-Peak")

// MARK: - 7. Chinese Public Holiday Waived Peak
print("\n[Test Group 7] Chinese Public Holiday Handling")
// 2026-10-01 is National Day (Thursday). Normally peak at 02:00 UTC, but waived!
let tNatDay = makeUTCDate(year: 2026, month: 10, day: 1, hour: 2, minute: 0)
assertEqual(calculator.status(at: tNatDay), .offPeak, "Chinese National Day at 02:00 UTC is Off-Peak")
let infoNatDay = calculator.statusInfo(at: tNatDay)
assertTrue(infoNatDay.isChineseHoliday, "Recognized as Chinese public holiday")
assertEqual(infoNatDay.holidayName ?? "", "National Day", "Holiday name matches National Day")

// 2026-10-05 Golden Week Monday
let tGoldenMon = makeUTCDate(year: 2026, month: 10, day: 5, hour: 7, minute: 0)
assertEqual(calculator.status(at: tGoldenMon), .offPeak, "Golden Week Monday at 07:00 UTC is Off-Peak")

// MARK: - 8. Bangladesh Conversion
print("\n[Test Group 8] Bangladesh Timezone Conversion (Asia/Dhaka UTC+6)")
let df = DateFormatter()
df.timeZone = dhakaTimeZone
df.locale = Locale(identifier: "en_US_POSIX")
df.dateFormat = "HH:mm"

let u1 = makeUTCDate(year: 2026, month: 10, day: 12, hour: 1, minute: 0)
assertEqual(df.string(from: u1), "07:00", "01:00 UTC -> 07:00 BDT")
let u2 = makeUTCDate(year: 2026, month: 10, day: 12, hour: 4, minute: 0)
assertEqual(df.string(from: u2), "10:00", "04:00 UTC -> 10:00 BDT")
let u3 = makeUTCDate(year: 2026, month: 10, day: 12, hour: 6, minute: 0)
assertEqual(df.string(from: u3), "12:00", "06:00 UTC -> 12:00 BDT")
let u4 = makeUTCDate(year: 2026, month: 10, day: 12, hour: 10, minute: 0)
assertEqual(df.string(from: u4), "16:00", "10:00 UTC -> 16:00 BDT")

// MARK: - 9. Midnight and Transition Boundaries
print("\n[Test Group 9] Transition Boundaries (Exact Second Accuracy)")
assertEqual(calculator.status(at: makeUTCDate(year: 2026, month: 10, day: 12, hour: 0, minute: 59, second: 59)), .offPeak, "00:59:59 UTC is Off-Peak")
assertEqual(calculator.status(at: makeUTCDate(year: 2026, month: 10, day: 12, hour: 1, minute: 0, second: 0)), .peak, "01:00:00 UTC is Peak")
assertEqual(calculator.status(at: makeUTCDate(year: 2026, month: 10, day: 12, hour: 3, minute: 59, second: 59)), .peak, "03:59:59 UTC is Peak")
assertEqual(calculator.status(at: makeUTCDate(year: 2026, month: 10, day: 12, hour: 4, minute: 0, second: 0)), .offPeak, "04:00:00 UTC is Off-Peak")
assertEqual(calculator.status(at: makeUTCDate(year: 2026, month: 10, day: 12, hour: 5, minute: 59, second: 59)), .offPeak, "05:59:59 UTC is Off-Peak")
assertEqual(calculator.status(at: makeUTCDate(year: 2026, month: 10, day: 12, hour: 6, minute: 0, second: 0)), .peak, "06:00:00 UTC is Peak")
assertEqual(calculator.status(at: makeUTCDate(year: 2026, month: 10, day: 12, hour: 9, minute: 59, second: 59)), .peak, "09:59:59 UTC is Peak")
assertEqual(calculator.status(at: makeUTCDate(year: 2026, month: 10, day: 12, hour: 10, minute: 0, second: 0)), .offPeak, "10:00:00 UTC is Off-Peak")

// MARK: - 10. Next Transition Search Across Weekends
print("\n[Test Group 10] Next Transition Across Weekend")
let nextFromFri = calculator.nextTransition(after: tFriNight)
let expectedMon = makeUTCDate(year: 2026, month: 10, day: 19, hour: 1, minute: 0)
assertEqual(nextFromFri, expectedMon, "Transition from Friday night correctly jumps to Monday 01:00 UTC")

// MARK: - 11. Bangladesh Daily Schedule
print("\n[Test Group 11] Bangladesh Daily Schedule Output")
let monDay = makeUTCDate(year: 2026, month: 10, day: 12, hour: 0, minute: 0)
let dailySlots = calculator.dailySchedule(for: monDay, in: dhakaTimeZone)
let peakSlots = dailySlots.filter { $0.status == .peak }
assertEqual(peakSlots.count, 2, "Bangladesh day has exactly 2 peak slots")
assertEqual(df.string(from: peakSlots[0].start), "07:00", "First peak starts at 07:00 BDT")
assertEqual(df.string(from: peakSlots[0].end), "10:00", "First peak ends at 10:00 BDT")
assertEqual(df.string(from: peakSlots[1].start), "12:00", "Second peak starts at 12:00 BDT")
assertEqual(df.string(from: peakSlots[1].end), "16:00", "Second peak ends at 16:00 BDT")

// MARK: - 12. Specific Audit Test Scenarios
print("\n[Test Group 12] Specific Audit Verification Scenarios")
// Scenario 1: 2026-10-05 (Monday, National Day Golden Week holiday) -> off-peak all day
let oct5_0200 = makeUTCDate(year: 2026, month: 10, day: 5, hour: 2, minute: 0)
let oct5_0700 = makeUTCDate(year: 2026, month: 10, day: 5, hour: 7, minute: 0)
let oct5_1200 = makeUTCDate(year: 2026, month: 10, day: 5, hour: 12, minute: 0)
assertEqual(calculator.status(at: oct5_0200), .offPeak, "2026-10-05 02:00 UTC (National Day holiday) is Off-Peak")
assertEqual(calculator.status(at: oct5_0700), .offPeak, "2026-10-05 07:00 UTC (National Day holiday) is Off-Peak")
assertEqual(calculator.status(at: oct5_1200), .offPeak, "2026-10-05 12:00 UTC (National Day holiday) is Off-Peak")
assertTrue(calculator.statusInfo(at: oct5_0700).isChineseHoliday, "2026-10-05 is correctly flagged as Chinese Holiday")

// Scenario 2: 2026-10-08 (Thursday) 02:00 UTC -> peak (National Day ends Oct 7)
let oct8_0200 = makeUTCDate(year: 2026, month: 10, day: 8, hour: 2, minute: 0)
assertEqual(calculator.status(at: oct8_0200), .peak, "2026-10-08 02:00 UTC (Thursday, post-holiday) is Peak")

// Scenario 3: 2026-10-08 (Thursday) 05:00 UTC -> off-peak (interim window between 04:00 and 06:00 UTC)
let oct8_0500 = makeUTCDate(year: 2026, month: 10, day: 8, hour: 5, minute: 0)
assertEqual(calculator.status(at: oct8_0500), .offPeak, "2026-10-08 05:00 UTC (Thursday interim) is Off-Peak")

// Scenario 4: 2026-10-10 (Saturday) 02:00 UTC -> off-peak
let oct10_0200 = makeUTCDate(year: 2026, month: 10, day: 10, hour: 2, minute: 0)
assertEqual(calculator.status(at: oct10_0200), .offPeak, "2026-10-10 02:00 UTC (Saturday) is Off-Peak")

// Scenario 5: 2026-10-08 07:00 Asia/Dhaka -> peak
// 07:00 Asia/Dhaka (UTC+6) is 01:00 UTC on Thursday, Oct 8.
var dhakaCalendar = Calendar(identifier: .gregorian)
dhakaCalendar.timeZone = dhakaTimeZone
var oct8DhakaComps = DateComponents()
oct8DhakaComps.year = 2026
oct8DhakaComps.month = 10
oct8DhakaComps.day = 8
oct8DhakaComps.hour = 7
oct8DhakaComps.minute = 0
let oct8Dhaka0700 = dhakaCalendar.date(from: oct8DhakaComps)!
assertEqual(calculator.status(at: oct8Dhaka0700), .peak, "2026-10-08 07:00 Asia/Dhaka (01:00 UTC) is Peak")

// MARK: - 13. Model Discount Rules
print("\n[Test Group 13] Model-Specific Discount Rules")
assertEqual(DeepSeekModel.flash.rawValue, "deepseek-flash", "Flash model raw value matches the official API")
assertEqual(DeepSeekModel.pro.rawValue, "deepseek-v4-pro", "Pro model raw value matches the official API")
for model in DeepSeekModel.allCases {
    assertEqual(model.discountPercentage(for: .offPeak), 50, "\(model.rawValue) gets the official 50% off-peak discount")
    assertEqual(model.discountPercentage(for: .peak), 0, "\(model.rawValue) gets 0% discount in peak")
}

// MARK: - 14. Make-up Workdays Are Not Holidays
print("\n[Test Group 14] Make-up Workdays Do Not Waive Peak")
assertTrue(!HolidayService.shared.isHoliday(dateString: "2026-01-04").isHoliday, "2026-01-04 (Sun) make-up workday is not a holiday")
assertTrue(!HolidayService.shared.isHoliday(dateString: "2026-10-10").isHoliday, "2026-10-10 (Sat) make-up workday is not a holiday")
assertTrue(!HolidayService.shared.isHoliday(dateString: "2025-02-08").isHoliday, "2025-02-08 make-up workday is not a holiday")

// MARK: - 15. Official Holiday Spans
print("\n[Test Group 15] Official Holiday Spans Recognised")
for day in ["2026-02-16", "2026-02-20", "2026-05-04", "2026-10-05", "2025-10-08"] {
    assertTrue(HolidayService.shared.isHoliday(dateString: day).isHoliday, "\(day) recognised as a public holiday")
}
assertEqual(calculator.status(at: makeUTCDate(year: 2026, month: 2, day: 16, hour: 2, minute: 0)), .offPeak, "2026-02-16 02:00 UTC (Spring Festival) is Off-Peak")

// MARK: - 16. Holiday Calendar Validation
print("\n[Test Group 16] Holiday Calendar Validation")
func makeCalendar(_ year: Int, offDays: [String], provisional: Bool = false) -> ChineseHolidayCalendar {
    let holidays = offDays.map { ChineseHoliday(date: $0, name: "Holiday", isOffDay: true) }
    return ChineseHolidayCalendar(country: "CN", year: year, holidays: holidays, source: "test", provisional: provisional)
}
let fullYear = makeCalendar(2026, offDays: [
    "2026-01-01", "2026-05-01", "2026-10-01", "2026-10-02", "2026-10-03",
    "2026-10-04", "2026-10-05", "2026-10-06", "2026-10-07", "2026-10-08"
])
assertTrue(HolidayCalendarValidator.isPlausible(fullYear), "Complete calendar is plausible")
let incomplete = makeCalendar(2026, offDays: [
    "2026-01-01", "2026-02-17", "2026-05-01", "2026-06-19", "2026-09-25", "2026-10-01"
])
assertTrue(!HolidayCalendarValidator.isPlausible(incomplete), "Incomplete (Nager-like) calendar is rejected")
let reduced = makeCalendar(2026, offDays: [
    "2026-01-01", "2026-05-01", "2026-10-01", "2026-10-02", "2026-10-03",
    "2026-10-04", "2026-10-06", "2026-10-07", "2026-10-08", "2026-10-09"
])
assertTrue(!HolidayCalendarValidator.isAcceptable(reduced, comparedToBaseline: fullYear), "Reduced calendar may not replace a complete baseline")
assertTrue(HolidayCalendarValidator.isAcceptable(fullYear, comparedToBaseline: fullYear), "Superset/equal calendar is accepted")
let provisional = makeCalendar(2027, offDays: ["2027-10-01", "2027-10-02", "2027-10-03", "2027-10-04", "2027-10-05", "2027-10-06", "2027-10-07", "2027-10-08", "2027-10-09", "2027-10-10"], provisional: true)
assertTrue(HolidayCalendarValidator.isAcceptable(fullYear, comparedToBaseline: provisional), "Authoritative candidate may replace a provisional baseline")

// MARK: - 17. Remote Parser (State Council mirror)
print("\n[Test Group 17] Remote Holiday Parser")
let fixture = #"{"year":2026,"days":[{"name":"国庆节","date":"2026-10-01","isOffDay":true},{"name":"国庆节","date":"2026-10-10","isOffDay":false}]}"#.data(using: .utf8)!
do {
    let parsed = try RemoteChineseHolidayProvider.parse(data: fixture, year: 2026)
    assertEqual(parsed.year, 2026, "Parser reads year")
    assertEqual(parsed.offDays.count, 1, "Parser keeps one off-day")
    assertEqual(parsed.makeUpWorkdays.count, 1, "Parser keeps one make-up workday")
    assertEqual(parsed.offDays.first?.name ?? "", "National Day", "Chinese name translated to English")
} catch {
    assertTrue(false, "Parser threw: \(error)")
}

// MARK: - 18. Previous Transition
print("\n[Test Group 18] Previous Transition")
let prevForPeak = calculator.previousTransition(before: makeUTCDate(year: 2026, month: 10, day: 12, hour: 2, minute: 0))
assertEqual(prevForPeak, makeUTCDate(year: 2026, month: 10, day: 12, hour: 1, minute: 0), "Previous transition for 02:00 UTC peak is 01:00 UTC")
let prevForOff = calculator.previousTransition(before: makeUTCDate(year: 2026, month: 10, day: 12, hour: 5, minute: 0))
assertEqual(prevForOff, makeUTCDate(year: 2026, month: 10, day: 12, hour: 4, minute: 0), "Previous transition for 05:00 UTC off-peak is 04:00 UTC")

// MARK: - 19. Missing Holiday Data
print("\n[Test Group 19] Missing Holiday Data Handling")
let unknownYearDate = makeUTCDate(year: 2035, month: 1, day: 2, hour: 2, minute: 0)
let unknownInfo = calculator.statusInfo(at: unknownYearDate)
assertTrue(unknownInfo.isHolidayDataMissing, "2035 is flagged as missing holiday data")
assertEqual(calculator.status(at: unknownYearDate), .peak, "Status still computed when holiday data is missing")

// MARK: - 20. Display Timezone in Reason
print("\n[Test Group 20] Peak Reason Uses Display Timezone")
let dhakaPeakInfo = calculator.statusInfo(
    at: makeUTCDate(year: 2026, month: 10, day: 12, hour: 1, minute: 30),
    displayTimeZone: dhakaTimeZone
)
assertTrue(dhakaPeakInfo.reason.contains("07:00") && dhakaPeakInfo.reason.contains("UTC"), "Peak reason contains UTC + Dhaka window: \(dhakaPeakInfo.reason)")

// MARK: - 21. Official Schedule Constants
print("\n[Test Group 21] Official DeepSeek Schedule Constants")
assertEqual(DeepSeekSchedule.peakWindowsUTC, [1..<4, 6..<10], "Official UTC peak windows are 01:00–04:00 and 06:00–10:00")
assertEqual(DeepSeekSchedule.transitionHoursUTC, [1, 4, 6, 10], "Transition hours are 01, 04, 06, 10 UTC")
assertEqual(DeepSeekSchedule.offPeakDiscountPercent, 50, "Off-peak discount is a uniform 50%")
assertEqual(PeakHourCalculator.peakWindowsUTC, [1..<4, 6..<10], "Calculator uses the official windows from DeepSeekSchedule")

print("\n=======================================================")
print("  Test Results: \(testPassed) Passed, \(testFailed) Failed")
print("=======================================================")

if testFailed > 0 {
    exit(1)
} else {
    exit(0)
}
