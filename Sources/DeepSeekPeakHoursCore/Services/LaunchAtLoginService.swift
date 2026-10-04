import Foundation
import ServiceManagement

public final class LaunchAtLoginService: Sendable {
    public static let shared = LaunchAtLoginService()

    public init() {}

    public var isAvailable: Bool {
        if #available(macOS 13.0, *) {
            return true
        }
        return false
    }

    public var isEnabled: Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }

    @discardableResult
    public func setEnabled(_ enabled: Bool) -> Bool {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    if SMAppService.mainApp.status != .enabled {
                        try SMAppService.mainApp.register()
                    }
                } else {
                    if SMAppService.mainApp.status == .enabled {
                        try SMAppService.mainApp.unregister()
                    }
                }
                return true
            } catch {
                print("Failed to update LaunchAtLogin via SMAppService: \(error.localizedDescription)")
                return false
            }
        }
        return false
    }
}
