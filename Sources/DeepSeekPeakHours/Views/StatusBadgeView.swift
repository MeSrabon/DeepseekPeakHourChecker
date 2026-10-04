import SwiftUI
import DeepSeekPeakHoursCore

public struct StatusBadgeView: View {
    let status: PeakStatus
    let isHoliday: Bool

    public init(status: PeakStatus, isHoliday: Bool = false) {
        self.status = status
        self.isHoliday = isHoliday
    }

    public var body: some View {
        HStack(spacing: 8) {
            DeepSeekLogoView(size: 26, status: status, showStatusRing: true)

            VStack(alignment: .leading, spacing: 1) {
                Text(status.displayTitle)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(statusColor)

                if isHoliday {
                    Text("Chinese Holiday Active")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(DeepSeekPricingRule.discountSummary(for: status))
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(statusColor.opacity(0.12))
                .foregroundColor(statusColor)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private var statusColor: Color {
        switch status {
        case .peak:
            return Color.red
        case .offPeak:
            return Color.green
        }
    }
}
