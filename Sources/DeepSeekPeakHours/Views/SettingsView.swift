import SwiftUI
import DeepSeekPeakHoursCore

public enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case notifications = "Notifications"
    case timeZone = "Timezone"
    case holidays = "Holidays"
    case about = "About"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .general: return "gearshape.fill"
        case .notifications: return "bell.badge.fill"
        case .timeZone: return "globe"
        case .holidays: return "calendar"
        case .about: return "info.circle.fill"
        }
    }
}

public struct SettingsView: View {
    @ObservedObject var viewModel: StatusViewModel

    @State private var selectedTab: SettingsTab = .general

    @State private var launchAtLogin: Bool = AppSettings.shared.launchAtLogin
    @State private var showMenuBarIcon: Bool = AppSettings.shared.showMenuBarIcon
    @State private var menuBarIconStyle: MenuBarIconStyle = AppSettings.shared.menuBarIconStyle
    @State private var showDockIcon: Bool = AppSettings.shared.showDockIcon

    @State private var notifyOnPeakStart: Bool = AppSettings.shared.notifyOnPeakStart
    @State private var notifyOnPeakEnd: Bool = AppSettings.shared.notifyOnPeakEnd
    @State private var notify15MinBeforePeak: Bool = AppSettings.shared.notify15MinBeforePeak
    @State private var notify30MinBeforePeak: Bool = AppSettings.shared.notify30MinBeforePeak

    @State private var timeZoneSelection: TimeZoneSelection = AppSettings.shared.timeZoneSelection
    @State private var customTimeZoneIdentifier: String = AppSettings.shared.customTimeZoneIdentifier

    @State private var refreshMessage: String?

    public init(viewModel: StatusViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Native Centered Settings Tab Bar
            HStack(spacing: 8) {
                ForEach(SettingsTab.allCases) { tab in
                    let isSelected = (selectedTab == tab)
                    Button(action: { selectedTab = tab }) {
                        HStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 12, weight: .semibold))
                            Text(tab.rawValue)
                                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(isSelected ? Color.accentColor : Color(nsColor: .controlBackgroundColor).opacity(0.6))
                        )
                        .foregroundColor(isSelected ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // Active Tab Content
            Group {
                switch selectedTab {
                case .general:
                    generalTab
                case .notifications:
                    notificationsTab
                case .timeZone:
                    timeZoneTab
                case .holidays:
                    holidaysTab
                case .about:
                    aboutTab
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(16)
        }
        .frame(width: 560, height: 480)
    }

    // MARK: - General Tab
    private var generalTab: some View {
        Form {
            Section {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        AppSettings.shared.launchAtLogin = newValue
                        LaunchAtLoginService.shared.setEnabled(newValue)
                    }

                Toggle("Show Menu Bar Icon", isOn: $showMenuBarIcon)
                    .onChange(of: showMenuBarIcon) { newValue in
                        AppSettings.shared.showMenuBarIcon = newValue
                    }

                Toggle("Show Dock Icon", isOn: $showDockIcon)
                    .onChange(of: showDockIcon) { newValue in
                        AppSettings.shared.showDockIcon = newValue
                        if newValue {
                            NSApp.setActivationPolicy(.regular)
                        } else {
                            NSApp.setActivationPolicy(.accessory)
                        }
                    }
            } header: {
                Text("Application Startup & Visibility")
                    .font(.headline)
            }

            Section {
                Picker("Icon Style", selection: $menuBarIconStyle) {
                    ForEach(MenuBarIconStyle.allCases) { style in
                        Text(style.displayName).tag(style)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: menuBarIconStyle) { newValue in
                    AppSettings.shared.menuBarIconStyle = newValue
                    NotificationCenter.default.post(name: NSNotification.Name("UpdateMenuBarIcon"), object: nil)
                }

                Text("Choose between a minimal monochrome whale logo with an active status dot, pure white/monochrome, or an accent-colored whale.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Menu Bar Appearance")
                    .font(.headline)
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Notifications Tab
    private var notificationsTab: some View {
        Form {
            Section {
                Toggle("Notify when peak hours start", isOn: $notifyOnPeakStart)
                    .onChange(of: notifyOnPeakStart) { newValue in
                        AppSettings.shared.notifyOnPeakStart = newValue
                        if newValue {
                            NotificationService.shared.requestAuthorization()
                        }
                    }

                Toggle("Notify when peak hours end", isOn: $notifyOnPeakEnd)
                    .onChange(of: notifyOnPeakEnd) { newValue in
                        AppSettings.shared.notifyOnPeakEnd = newValue
                        if newValue {
                            NotificationService.shared.requestAuthorization()
                        }
                    }
            } header: {
                Text("Transition Alerts")
                    .font(.headline)
            }

            Section {
                Toggle("Notify 15 minutes before peak", isOn: $notify15MinBeforePeak)
                    .onChange(of: notify15MinBeforePeak) { newValue in
                        AppSettings.shared.notify15MinBeforePeak = newValue
                        viewModel.refreshState()
                    }

                Toggle("Notify 30 minutes before peak", isOn: $notify30MinBeforePeak)
                    .onChange(of: notify30MinBeforePeak) { newValue in
                        AppSettings.shared.notify30MinBeforePeak = newValue
                        viewModel.refreshState()
                    }
            } header: {
                Text("Pre-Warning Alerts")
                    .font(.headline)
            } footer: {
                Text("Pre-warning alerts remind you before high-rate periods begin so you can plan batch requests.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - TimeZone Tab
    private var timeZoneTab: some View {
        Form {
            Section {
                Picker("Timezone Mode", selection: $timeZoneSelection) {
                    ForEach(TimeZoneSelection.allCases) { tz in
                        Text(tz.rawValue).tag(tz)
                    }
                }
                .pickerStyle(.radioGroup)
                .onChange(of: timeZoneSelection) { newValue in
                    AppSettings.shared.timeZoneSelection = newValue
                    viewModel.refreshState()
                }

                if timeZoneSelection == .custom {
                    TextField("Timezone Identifier", text: $customTimeZoneIdentifier)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            AppSettings.shared.customTimeZoneIdentifier = customTimeZoneIdentifier
                            viewModel.refreshState()
                        }
                    Text("e.g., Asia/Dhaka, Europe/London, America/New_York")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Display Timezone")
                    .font(.headline)
            }

            Section {
                LabeledContent("Active Timezone", value: viewModel.activeTimeZone.identifier)
                let offset = viewModel.activeTimeZone.secondsFromGMT()
                let offsetH = offset / 3600
                let offsetM = abs((offset % 3600) / 60)
                LabeledContent("UTC Offset", value: String(format: "%+03d:%02d", offsetH, offsetM))
            } header: {
                Text("Current Timezone Information")
                    .font(.headline)
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Holidays Tab
    private var holidaysTab: some View {
        Form {
            Section {
                LabeledContent("Provider", value: "Automatic (Local bundled + Remote sync)")
                LabeledContent("Status", value: viewModel.holidayStatusDescription)

                HStack {
                    Button(action: {
                        Task {
                            let updated = await viewModel.refreshHolidaysOnline()
                            if updated {
                                refreshMessage = "Holiday calendar updated successfully."
                            } else {
                                refreshMessage = viewModel.holidayRefreshError ?? "No complete holiday calendar could be retrieved. Bundled data kept."
                            }
                        }
                    }) {
                        if viewModel.isRefreshingHolidays {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text("Refresh Holiday Calendar")
                        }
                    }
                    .disabled(viewModel.isRefreshingHolidays)

                    if let msg = refreshMessage {
                        Text(msg)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("Chinese Public Holidays Calendar")
                    .font(.headline)
            } footer: {
                Text("Source: official State Council schedule (mirror: NateScarlet/holiday-cn). Bundled data covers 2025–2028; incomplete upstream responses are rejected and never overwrite validated data. Peak hours are waived for the entire duration of each public holiday.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - About Tab
    private var aboutTab: some View {
        VStack(spacing: 16) {
            Image(systemName: "bolt.badge.clock.fill")
                .font(.system(size: 40))
                .foregroundColor(.accentColor)

            Text("DeepSeek Peak Hour Checker")
                .font(.title2)
                .bold()

            Text("Version 1.0.0 · Native macOS Menu Bar Utility")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("Official DeepSeek Schedule (UTC):")
                    .font(.subheadline)
                    .bold()
                Text("• 01:00–04:00 UTC (07:00–10:00 Bangladesh Time)")
                    .font(.caption)
                Text("• 06:00–10:00 UTC (12:00–16:00 Bangladesh Time)")
                    .font(.caption)
                Text("• Monday through Friday, excluding Chinese public holidays.")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)

            HStack {
                Button("Open DeepSeek Website") {
                    viewModel.openDeepSeek()
                }

                Button("Pricing Documentation") {
                    viewModel.openPricingDocs()
                }
            }

            Spacer()
        }
        .padding(16)
    }
}
