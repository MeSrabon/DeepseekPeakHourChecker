import Foundation

/// Canonical DeepSeek pricing schedule — the single source of truth for this app.
///
/// Source of truth: official DeepSeek API documentation
/// <https://api-docs.deepseek.com/quick_start/pricing>
///
/// Official wording (retrieved 2026-10-05):
/// *"Off-peak rates are half of the peak rates. Peak hours are 01:00 - 04:00 and 06:00 - 10:00
/// UTC, Monday through Friday, excluding Chinese public holidays. All other hours are off-peak,
/// including weekends and Chinese public holidays in full."*
///
/// All instants are evaluated in UTC. Display layers may project them into a local timezone.
public enum DeepSeekSchedule {

    /// Peak windows expressed in UTC as half-open ranges `[startHour, endHour)`.
    ///
    /// These values are the contract verified against the official documentation:
    /// `01:00–04:00 UTC` and `06:00–10:00 UTC`.
    public static let peakWindowsUTC: [Range<Int>] = [1..<4, 6..<10]

    /// The UTC hours at which the status can change, in chronological order.
    public static var transitionHoursUTC: [Int] {
        peakWindowsUTC.flatMap { [$0.lowerBound, $0.upperBound] }.sorted()
    }

    /// Off-peak discount applied to every current model. Off-peak rates are half of peak
    /// rates, i.e. a uniform 50% discount for both `deepseek-flash` and `deepseek-v4-pro`.
    public static let offPeakDiscountPercent = 50

    /// Human-readable schedule summary for diagnostics and documentation.
    public static let peakWindowsDescription = "01:00–04:00 and 06:00–10:00 UTC, Monday–Friday (excluding Chinese public holidays)"

    public static let documentationURL = "https://api-docs.deepseek.com/quick_start/pricing"
    public static let scheduleRetrievedAt = "2026-10-05"
}
