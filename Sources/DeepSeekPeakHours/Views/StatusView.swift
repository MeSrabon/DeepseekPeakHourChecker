import SwiftUI
import DeepSeekPeakHoursCore

public struct StatusView: View {
    @ObservedObject var viewModel: StatusViewModel

    public init(viewModel: StatusViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Main status badge
            StatusBadgeView(
                status: viewModel.status,
                isHoliday: viewModel.statusInfo.isChineseHoliday
            )

            // Countdown & Next Transition Card
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.status == .peak ? "PEAK HOURS END IN" : "NEXT PEAK HOURS IN")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .tracking(0.4)

                Text(viewModel.timeRemainingString)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.primary)

                // Dedicated Next Transition Sub-Banner (Full Width, Never Truncated)
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: viewModel.status == .peak ? "arrow.down.right.circle.fill" : "calendar.badge.clock")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(viewModel.status == .peak ? .green : .accentColor)
                        .padding(.top, 1)

                    Text(viewModel.nextTransitionExplanation)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.8))
                )
            }
            .padding(.horizontal, 2)

            // Holiday explanation if active
            if viewModel.statusInfo.isChineseHoliday, let holidayName = viewModel.statusInfo.holidayName {
                HolidayExplainerView(
                    holidayName: holidayName,
                    nextResumeDescription: viewModel.nextTransitionExplanation
                )
            }

            // Missing holiday-calendar warning
            if let warning = viewModel.holidayDataWarning {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.orange)
                    Text(warning)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.orange.opacity(0.1))
                )
            }

            // Current Time & Timezone section
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current Time")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.3)

                        Text(viewModel.currentTimeString)
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Timezone")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.3)

                        Text(viewModel.timeZoneDisplayName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }

                Text(viewModel.currentDateString)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
            )
        }
    }
}
