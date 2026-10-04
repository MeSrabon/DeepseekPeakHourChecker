import SwiftUI
import DeepSeekPeakHoursCore

public struct MenuBarView: View {
    @ObservedObject var viewModel: StatusViewModel
    var onOpenSettings: () -> Void

    public init(viewModel: StatusViewModel, onOpenSettings: @escaping () -> Void = {}) {
        self.viewModel = viewModel
        self.onOpenSettings = onOpenSettings
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Header Bar
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    DeepSeekLogoView(size: 18, status: viewModel.status, showStatusRing: true)

                    Text("DeepSeek Hours")
                        .font(.system(size: 13, weight: .bold))
                }

                Spacer()

                HStack(spacing: 6) {
                    Button(action: onOpenSettings) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .frame(width: 26, height: 26)
                            .background(
                                Circle()
                                    .fill(Color(nsColor: .controlBackgroundColor))
                            )
                    }
                    .buttonStyle(.plain)
                    .help("Open Settings (⌘,)")

                    Button(action: { viewModel.quitApp() }) {
                        Image(systemName: "power")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.red.opacity(0.85))
                            .frame(width: 26, height: 26)
                            .background(
                                Circle()
                                    .fill(Color(nsColor: .controlBackgroundColor))
                            )
                    }
                    .buttonStyle(.plain)
                    .help("Quit Application (⌘Q)")
                }
            }

            // Status Card with Countdown
            StatusView(viewModel: viewModel)

            Divider()

            // Today's Detailed Schedule
            ScheduleView(
                periods: viewModel.todaySchedule,
                currentTime: Date(),
                timeZone: viewModel.activeTimeZone
            )

            Divider()

            // Action & Utility Footer
            HStack(spacing: 10) {
                Button(action: { viewModel.openDeepSeek() }) {
                    Label("DeepSeek", systemImage: "arrow.up.right.square")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.link)

                Button(action: { viewModel.openPricingDocs() }) {
                    Label("Docs", systemImage: "doc.text")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.link)

                Spacer()

                Button(action: onOpenSettings) {
                    HStack(spacing: 4) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 11))
                        Text("Settings")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Settings (⌘,)")

                Button(action: { viewModel.quitApp() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "power")
                            .font(.system(size: 11, weight: .bold))
                        Text("Quit")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.red.opacity(0.85))
                }
                .buttonStyle(.plain)
                .help("Quit DeepSeek Peak Hours (⌘Q)")
            }
        }
        .padding(14)
        .frame(width: 350)
        .onAppear {
            viewModel.isPopoverOpen = true
        }
        .onDisappear {
            viewModel.isPopoverOpen = false
        }
    }
}
