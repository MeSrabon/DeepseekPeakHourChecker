import Foundation

public enum TimeZoneSelection: String, CaseIterable, Identifiable, Codable, Sendable {
    case automatic = "Automatic"
    case bangladesh = "Bangladesh (UTC+6)"
    case utc = "UTC"
    case custom = "Custom"

    public var id: String { rawValue }

    public func resolvedTimeZone(customIdentifier: String? = nil) -> TimeZone {
        switch self {
        case .automatic:
            return TimeZone.current
        case .bangladesh:
            return TimeZone(identifier: "Asia/Dhaka") ?? TimeZone(secondsFromGMT: 6 * 3600) ?? .current
        case .utc:
            return TimeZone(secondsFromGMT: 0) ?? .current
        case .custom:
            if let customIdentifier, let tz = TimeZone(identifier: customIdentifier) {
                return tz
            }
            return TimeZone.current
        }
    }
}

public enum MenuBarIconStyle: String, CaseIterable, Identifiable, Codable, Sendable {
    case minimalWithDot = "minimalWithDot"
    case pureMonochrome = "pureMonochrome"
    case statusColored = "statusColored"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .minimalWithDot:
            return "Minimal (White Logo + Status Dot)"
        case .pureMonochrome:
            return "Monochrome (White Logo Only)"
        case .statusColored:
            return "Accent Colored (Green / Red Logo)"
        }
    }
}

public final class AppSettings: @unchecked Sendable {
    public static let shared = AppSettings()

    public enum Keys {
        public static let launchAtLogin = "launchAtLogin"
        public static let showMenuBarIcon = "showMenuBarIcon"
        public static let menuBarIconStyle = "menuBarIconStyle"
        public static let showDockIcon = "showDockIcon"
        public static let notifyOnPeakStart = "notifyOnPeakStart"
        public static let notifyOnPeakEnd = "notifyOnPeakEnd"
        public static let notify15MinBeforePeak = "notify15MinBeforePeak"
        public static let notify30MinBeforePeak = "notify30MinBeforePeak"
        public static let timeZoneSelection = "timeZoneSelection"
        public static let customTimeZoneIdentifier = "customTimeZoneIdentifier"
        public static let lastHolidayRefresh = "lastHolidayRefresh"
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        registerDefaults()
    }

    private func registerDefaults() {
        defaults.register(defaults: [
            Keys.launchAtLogin: false,
            Keys.showMenuBarIcon: true,
            Keys.menuBarIconStyle: MenuBarIconStyle.minimalWithDot.rawValue,
            Keys.showDockIcon: false,
            Keys.notifyOnPeakStart: true,
            Keys.notifyOnPeakEnd: true,
            Keys.notify15MinBeforePeak: false,
            Keys.notify30MinBeforePeak: false,
            Keys.timeZoneSelection: TimeZoneSelection.automatic.rawValue,
            Keys.customTimeZoneIdentifier: "Asia/Dhaka"
        ])
    }

    public var launchAtLogin: Bool {
        get { defaults.bool(forKey: Keys.launchAtLogin) }
        set { defaults.set(newValue, forKey: Keys.launchAtLogin) }
    }

    public var showMenuBarIcon: Bool {
        get { defaults.bool(forKey: Keys.showMenuBarIcon) }
        set { defaults.set(newValue, forKey: Keys.showMenuBarIcon) }
    }

    public var menuBarIconStyle: MenuBarIconStyle {
        get {
            let raw = defaults.string(forKey: Keys.menuBarIconStyle) ?? MenuBarIconStyle.minimalWithDot.rawValue
            return MenuBarIconStyle(rawValue: raw) ?? .minimalWithDot
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.menuBarIconStyle)
        }
    }

    public var showDockIcon: Bool {
        get { defaults.bool(forKey: Keys.showDockIcon) }
        set { defaults.set(newValue, forKey: Keys.showDockIcon) }
    }

    public var notifyOnPeakStart: Bool {
        get { defaults.bool(forKey: Keys.notifyOnPeakStart) }
        set { defaults.set(newValue, forKey: Keys.notifyOnPeakStart) }
    }

    public var notifyOnPeakEnd: Bool {
        get { defaults.bool(forKey: Keys.notifyOnPeakEnd) }
        set { defaults.set(newValue, forKey: Keys.notifyOnPeakEnd) }
    }

    public var notify15MinBeforePeak: Bool {
        get { defaults.bool(forKey: Keys.notify15MinBeforePeak) }
        set { defaults.set(newValue, forKey: Keys.notify15MinBeforePeak) }
    }

    public var notify30MinBeforePeak: Bool {
        get { defaults.bool(forKey: Keys.notify30MinBeforePeak) }
        set { defaults.set(newValue, forKey: Keys.notify30MinBeforePeak) }
    }

    public var timeZoneSelection: TimeZoneSelection {
        get {
            let raw = defaults.string(forKey: Keys.timeZoneSelection) ?? TimeZoneSelection.automatic.rawValue
            return TimeZoneSelection(rawValue: raw) ?? .automatic
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.timeZoneSelection)
        }
    }

    public var customTimeZoneIdentifier: String {
        get { defaults.string(forKey: Keys.customTimeZoneIdentifier) ?? "Asia/Dhaka" }
        set { defaults.set(newValue, forKey: Keys.customTimeZoneIdentifier) }
    }

    public var lastHolidayRefresh: Date? {
        get { defaults.object(forKey: Keys.lastHolidayRefresh) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastHolidayRefresh) }
    }
}
