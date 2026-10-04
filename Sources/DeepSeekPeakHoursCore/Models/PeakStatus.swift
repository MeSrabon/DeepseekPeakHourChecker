import Foundation

public enum PeakStatus: String, Codable, Sendable, CustomStringConvertible {
    case peak
    case offPeak

    public var description: String {
        switch self {
        case .peak: return "Peak"
        case .offPeak: return "Off-Peak"
        }
    }

    public var displayTitle: String {
        switch self {
        case .peak: return "PEAK HOURS"
        case .offPeak: return "OFF-PEAK"
        }
    }

    public var accessibilityLabel: String {
        switch self {
        case .peak: return "DeepSeek Peak Hour — Peak"
        case .offPeak: return "DeepSeek Peak Hour — Off-Peak"
        }
    }

    public var symbolName: String {
        switch self {
        case .peak: return "bolt.fill"
        case .offPeak: return "checkmark.circle.fill"
        }
    }
}
