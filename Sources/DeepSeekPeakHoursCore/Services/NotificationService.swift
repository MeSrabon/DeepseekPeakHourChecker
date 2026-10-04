import Foundation
import UserNotifications

public final class NotificationService: @unchecked Sendable {
    public static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()
    private let settings: AppSettings

    public init(settings: AppSettings = .shared) {
        self.settings = settings
    }

    public func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("Notification authorization error: \(error)")
            }
        }
    }

    public func notifyStatusChange(to newStatus: PeakStatus, nextTransition: Date, timeZone: TimeZone) {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.timeStyle = .short
        let nextFormatted = formatter.string(from: nextTransition)

        let content = UNMutableNotificationContent()
        content.sound = .default

        switch newStatus {
        case .peak:
            guard settings.notifyOnPeakStart else { return }
            content.title = "🔴 DeepSeek Peak Hours Started"
            content.body = "Peak hours are now active.\nNext off-peak period: \(nextFormatted)"

        case .offPeak:
            guard settings.notifyOnPeakEnd else { return }
            content.title = "🟢 DeepSeek Off-Peak Started"
            content.body = "DeepSeek is now in off-peak hours.\nNext peak: \(nextFormatted)"
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "DeepSeekStatusChange-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                print("Error delivering notification: \(error)")
            }
        }
    }

    public func schedulePreWarnings(for nextPeakDate: Date, timeZone: TimeZone) {
        center.removePendingNotificationRequests(withIdentifiers: ["warning-15m", "warning-30m"])

        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.timeStyle = .short
        let peakTimeStr = formatter.string(from: nextPeakDate)

        if settings.notify15MinBeforePeak {
            let warn15 = nextPeakDate.addingTimeInterval(-15 * 60)
            if warn15 > now {
                let diff = warn15.timeIntervalSince(now)
                let content = UNMutableNotificationContent()
                content.title = "⏰ Peak Hours Starting in 15 Minutes"
                content.body = "DeepSeek peak hours will start at \(peakTimeStr)."
                content.sound = .default
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: diff, repeats: false)
                let req = UNNotificationRequest(identifier: "warning-15m", content: content, trigger: trigger)
                center.add(req)
            }
        }

        if settings.notify30MinBeforePeak {
            let warn30 = nextPeakDate.addingTimeInterval(-30 * 60)
            if warn30 > now {
                let diff = warn30.timeIntervalSince(now)
                let content = UNMutableNotificationContent()
                content.title = "⏰ Peak Hours Starting in 30 Minutes"
                content.body = "DeepSeek peak hours will start at \(peakTimeStr)."
                content.sound = .default
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: diff, repeats: false)
                let req = UNNotificationRequest(identifier: "warning-30m", content: content, trigger: trigger)
                center.add(req)
            }
        }
    }
}
