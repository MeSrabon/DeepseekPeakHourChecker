import Foundation
import AppKit

public final class TimeService: @unchecked Sendable {
    public static let shared = TimeService()

    public var onTick: (@Sendable () -> Void)?
    public var onTransition: (@Sendable () -> Void)?

    private var transitionTimer: Timer?
    private var liveTickTimer: Timer?
    private let lock = NSLock()
    private var isLiveTickActive = false

    public init() {
        setupSystemObservers()
    }

    deinit {
        stopAllTimers()
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    private func setupSystemObservers() {
        // Observe Mac wake from sleep
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleSystemEvent()
        }

        // Observe system clock modifications
        NotificationCenter.default.addObserver(
            forName: Notification.Name.NSSystemClockDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleSystemEvent()
        }

        // Observe calendar day changed (midnight)
        NotificationCenter.default.addObserver(
            forName: Notification.Name.NSCalendarDayChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleSystemEvent()
        }

        // Observe timezone modifications
        NotificationCenter.default.addObserver(
            forName: Notification.Name.NSSystemTimeZoneDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleSystemEvent()
        }

        // Observe holiday updates
        NotificationCenter.default.addObserver(
            forName: HolidayService.didUpdateHolidaysNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleSystemEvent()
        }
    }

    private func handleSystemEvent() {
        DispatchQueue.main.async { [weak self] in
            self?.onTransition?()
            self?.onTick?()
        }
    }

    /// Schedules a timer to fire precisely at the next status transition date.
    public func scheduleNextTransitionTimer(at transitionDate: Date) {
        lock.lock()
        defer { lock.unlock() }

        transitionTimer?.invalidate()
        let interval = max(0.5, transitionDate.timeIntervalSince(Date()) + 0.1)

        let timer = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.onTransition?()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.transitionTimer = timer
    }

    /// Sets whether the live 1-second UI countdown timer is active (only needed when popover is open).
    public func setLiveTickActive(_ active: Bool) {
        lock.lock()
        defer { lock.unlock() }

        guard active != isLiveTickActive else { return }
        isLiveTickActive = active

        if active {
            liveTickTimer?.invalidate()
            let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.onTick?()
                }
            }
            RunLoop.main.add(timer, forMode: .common)
            self.liveTickTimer = timer
        } else {
            liveTickTimer?.invalidate()
            liveTickTimer = nil
        }
    }

    public func stopAllTimers() {
        lock.lock()
        defer { lock.unlock() }
        transitionTimer?.invalidate()
        transitionTimer = nil
        liveTickTimer?.invalidate()
        liveTickTimer = nil
        isLiveTickActive = false
    }
}
