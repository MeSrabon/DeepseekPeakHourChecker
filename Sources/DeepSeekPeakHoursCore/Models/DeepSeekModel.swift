import Foundation

/// Current DeepSeek API models as listed in the official documentation
/// (<https://api-docs.deepseek.com/quick_start/pricing>, retrieved 2026-10-05).
///
/// The legacy `deepseek-chat` (V3) and `deepseek-reasoner` (R1) names are no longer offered;
/// their successors are `deepseek-flash` and `deepseek-v4-pro`.
public enum DeepSeekModel: String, CaseIterable, Identifiable, Sendable {
    case flash = "deepseek-flash"
    case pro = "deepseek-v4-pro"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .flash: return "deepseek-flash (V4.1)"
        case .pro: return "deepseek-v4-pro"
        }
    }

    /// Discount applied during off-peak periods according to official DeepSeek documentation.
    /// Off-peak rates are half of peak rates, i.e. a uniform 50% discount for every model.
    public func discountPercentage(for status: PeakStatus) -> Int {
        switch status {
        case .peak:
            return 0
        case .offPeak:
            return DeepSeekSchedule.offPeakDiscountPercent
        }
    }

    public func discountLabel(for status: PeakStatus) -> String {
        switch status {
        case .peak:
            return "Standard Rate"
        case .offPeak:
            return "\(discountPercentage(for: status))% Off"
        }
    }
}

public struct DeepSeekPricingRule: Sendable {
    public static func discountSummary(for status: PeakStatus) -> String {
        switch status {
        case .peak:
            return "100% Rate"
        case .offPeak:
            return "\(DeepSeekSchedule.offPeakDiscountPercent)% Off"
        }
    }

    public static func detailedDiscount(for status: PeakStatus) -> String {
        switch status {
        case .peak:
            return "Standard rates apply for all models"
        case .offPeak:
            return "Off-peak rates are 50% of peak for deepseek-flash and deepseek-v4-pro"
        }
    }
}
