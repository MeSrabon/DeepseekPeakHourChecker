import AppKit
import SwiftUI
import DeepSeekPeakHoursCore

public final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Enforce accessory mode (menu bar only, no dock icon) unless user opted-in
        let showDock = AppSettings.shared.showDockIcon
        NSApp.setActivationPolicy(showDock ? .regular : .accessory)

        // Request notification authorization on launch
        NotificationService.shared.requestAuthorization()

        // Initialize status bar controller
        self.statusBarController = StatusBarController(viewModel: .shared)
    }

    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // As a menu-bar accessory, we do not quit when utility windows (e.g. settings) close
        return false
    }
}

@main
struct DeepSeekPeakHoursApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}
