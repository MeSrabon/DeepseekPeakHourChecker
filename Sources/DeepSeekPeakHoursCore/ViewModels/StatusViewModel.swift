import Foundation
import Combine
import AppKit

@MainActor
public final class StatusViewModel: ObservableObject {
    public static let shared = StatusViewModel()

    @Published public private(set) var status: PeakStatus = .offPeak
    @Published public private(set) var statusInfo: PeakStatusInfo
    @Published public private(set) var currentTimeString: String = ""
    @Published public private(set) var currentDateString: String = ""
    @Published public private(set) var timeZoneDisplayName: String = ""
    @Published public private(set) var timeRemainingString: String = ""
    @Published public private(set) var nextTransitionExplanation: String = ""
    @Published public private(set) var todaySchedule: [PeakPeriod] = []
    @Published public private(set) var isRefreshingHolidays: Bool = false
    @Published public private(set) var holidayStatusDescription: String = ""
    @Published public private(set) var holidayDataWarning: String?

    public var isPopoverOpen: Bool = false {
        didSet {
            timeService.setLiveTickActive(isPopoverOpen)
            if isPopoverOpen {
                refreshState()
            }
        }
    }

    private let calculator: PeakHourCalculator
    private let timeService: TimeService
    private let notificationService: NotificationService
    private let holidayService: HolidayService
    private var lastRecordedStatus: PeakStatus?

    public init(
        calculator: PeakHourCalculator = .shared,
        timeService: TimeService = .shared,
        notificationService: NotificationService = .shared,
        holidayService: HolidayService = .shared
    ) {
        self.calculator = calculator
        self.timeService = timeService
        self.notificationService = notificationService
        self.holidayService = holidayService

        let initialDate = Date()
        let initialInfo = calculator.statusInfo(at: initialDate)
        self.statusInfo = initialInfo
        self.status = initialInfo.status
        self.lastRecordedStatus = initialInfo.status

        setupCallbacks()
        refreshState()
    }

    private func setupCallbacks() {
        timeService.onTick = { [weak self] in
            Task { @MainActor in
                self?.refreshTick()
            }
        }

        timeService.onTransition = { [weak self] in
            Task { @MainActor in
                self?.handleTransition()
            }
        }
    }

    public var activeTimeZone: TimeZone {
        AppSettings.shared.timeZoneSelection.resolvedTimeZone(
            customIdentifier: AppSettings.shared.customTimeZoneIdentifier
        )
    }

    public func refreshState() {
        let now = Date()
        let currentTz = activeTimeZone
        let info = calculator.statusInfo(at: now, displayTimeZone: currentTz)

        self.statusInfo = info
        self.status = info.status
        self.holidayStatusDescription = holidayService.statusDescription
        self.holidayDataWarning = info.isHolidayDataMissing
            ? holidayService.missingDataDescription(for: Int(info.utcCalendarDateString.prefix(4)) ?? 0)
            : nil

        // Format times
        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = currentTz
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.dateFormat = "HH:mm:ss"
        self.currentTimeString = timeFormatter.string(from: now)

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = currentTz
        dateFormatter.dateStyle = .full
        self.currentDateString = dateFormatter.string(from: now)

        let offsetSeconds = currentTz.secondsFromGMT(for: now)
        let offsetHours = offsetSeconds / 3600
        let offsetMinutes = abs((offsetSeconds % 3600) / 60)
        let offsetSign = offsetHours >= 0 ? "+" : "-"
        let offsetStr = String(format: "UTC%@%02d:%02d", offsetSign, abs(offsetHours), offsetMinutes)
        self.timeZoneDisplayName = "\(currentTz.identifier) (\(offsetStr))"

        // Schedule next transition timer
        timeService.scheduleNextTransitionTimer(at: info.nextTransition)

        // Schedule warnings for upcoming peak if currently off-peak
        if info.status == .offPeak && info.nextStatus == .peak {
            notificationService.schedulePreWarnings(for: info.nextTransition, timeZone: currentTz)
        }

        updateCountdownAndTransition(now: now, timeZone: currentTz)
        updateSchedule(for: now, timeZone: currentTz)
    }

    public func refreshTick() {
        let now = Date()
        let currentTz = activeTimeZone

        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = currentTz
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.dateFormat = "HH:mm:ss"
        self.currentTimeString = timeFormatter.string(from: now)

        updateCountdownAndTransition(now: now, timeZone: currentTz)

        // If we crossed a transition boundary during tick
        if now >= statusInfo.nextTransition {
            handleTransition()
        }
    }

    private func handleTransition() {
        refreshState()

        if let last = lastRecordedStatus, last != self.status {
            notificationService.notifyStatusChange(
                to: self.status,
                nextTransition: statusInfo.nextTransition,
                timeZone: activeTimeZone
            )
        }
        lastRecordedStatus = self.status
    }

    private func updateCountdownAndTransition(now: Date, timeZone: TimeZone) {
        let remainingSeconds = max(0, Int(statusInfo.nextTransition.timeIntervalSince(now)))
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60

        if hours > 0 {
            self.timeRemainingString = String(format: "%02dh %02dm %02ds", hours, minutes, seconds)
        } else {
            self.timeRemainingString = String(format: "%02dm %02ds", minutes, seconds)
        }

        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = timeZone
        timeFormatter.timeStyle = .short

        var displayCalendar = Calendar(identifier: .gregorian)
        displayCalendar.timeZone = timeZone
        let isToday = displayCalendar.isDate(statusInfo.nextTransition, inSameDayAs: now)
        let tomorrow = displayCalendar.date(byAdding: .day, value: 1, to: now) ?? now
        let isTomorrow = displayCalendar.isDate(statusInfo.nextTransition, inSameDayAs: tomorrow)

        let targetTime = timeFormatter.string(from: statusInfo.nextTransition)

        switch statusInfo.status {
        case .peak:
            if isToday {
                self.nextTransitionExplanation = "Off-peak at \(targetTime)"
            } else {
                self.nextTransitionExplanation = "Off-peak at \(targetTime) tomorrow"
            }
        case .offPeak:
            if statusInfo.isChineseHoliday {
                let dayFormatter = DateFormatter()
                dayFormatter.timeZone = timeZone
                dayFormatter.dateFormat = "EEEE, MMM d"
                let nextDayStr = dayFormatter.string(from: statusInfo.nextTransition)
                self.nextTransitionExplanation = "Peak resumes: \(nextDayStr) at \(targetTime)"
            } else if statusInfo.isWeekend {
                self.nextTransitionExplanation = "Peak starts Monday at \(targetTime)"
            } else if isToday {
                self.nextTransitionExplanation = "Peak starts today at \(targetTime)"
            } else if isTomorrow {
                self.nextTransitionExplanation = "Peak starts tomorrow at \(targetTime)"
            } else {
                let dayFormatter = DateFormatter()
                dayFormatter.timeZone = timeZone
                dayFormatter.dateFormat = "EEEE at HH:mm"
                self.nextTransitionExplanation = "Peak starts \(dayFormatter.string(from: statusInfo.nextTransition))"
            }
        }
    }

    private func updateSchedule(for date: Date, timeZone: TimeZone) {
        self.todaySchedule = calculator.dailySchedule(for: date, in: timeZone)
    }

    @discardableResult
    public func refreshHolidaysOnline() async -> Bool {
        isRefreshingHolidays = true
        defer { isRefreshingHolidays = false }

        let updated = await holidayService.refreshHolidays()
        holidayStatusDescription = holidayService.statusDescription
        refreshState()
        return updated
    }

    public var holidayRefreshError: String? {
        holidayService.lastError
    }

    public func openDeepSeek() {
        if let url = URL(string: "https://chat.deepseek.com") {
            NSWorkspace.shared.open(url)
        }
    }

    public func openPricingDocs() {
        if let url = URL(string: "https://api-docs.deepseek.com/quick_start/pricing") {
            NSWorkspace.shared.open(url)
        }
    }

    public func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
