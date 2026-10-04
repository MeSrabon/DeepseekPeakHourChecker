import AppKit
import SwiftUI
import Combine
import DeepSeekPeakHoursCore

@MainActor
public final class StatusBarController: NSObject, NSPopoverDelegate {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let viewModel: StatusViewModel
    private var cancellables = Set<AnyCancellable>()
    private var settingsWindow: NSWindow?

    public init(viewModel: StatusViewModel? = nil) {
        let vm = viewModel ?? .shared
        self.viewModel = vm
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()
        super.init()

        setupPopover()
        setupStatusButton()
        bindViewModel()
        updateStatusIcon()
    }

    private func setupPopover() {
        popover.contentSize = NSSize(width: 350, height: 460)
        popover.behavior = .transient
        popover.animates = true
        popover.delegate = self

        let menuBarView = MenuBarView(viewModel: viewModel) { [weak self] in
            self?.openSettings()
        }
        popover.contentViewController = NSHostingController(rootView: menuBarView)
    }

    private func setupStatusButton() {
        guard let button = statusItem.button else { return }
        button.target = self
        button.action = #selector(statusBarButtonClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    private func bindViewModel() {
        viewModel.$status
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusIcon()
            }
            .store(in: &cancellables)

        viewModel.$timeRemainingString
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateTooltip()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: NSNotification.Name("UpdateMenuBarIcon"))
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusIcon()
            }
            .store(in: &cancellables)
    }

    private func updateStatusIcon() {
        guard let button = statusItem.button else { return }

        let isPeak = (viewModel.status == .peak)
        let style = AppSettings.shared.menuBarIconStyle
        let icon = DeepSeekLogo.menuBarIcon(isPeak: isPeak, style: style)

        button.image = icon
        button.imagePosition = .imageOnly

        let label = isPeak ? "DeepSeek Peak Hour — Peak" : "DeepSeek Peak Hour — Off-Peak"
        button.setAccessibilityLabel(label)
        updateTooltip()
    }

    private func updateTooltip() {
        guard let button = statusItem.button else { return }
        let statusStr = viewModel.status == .peak ? "Peak" : "Off-Peak"
        button.toolTip = "DeepSeek: \(statusStr) (\(viewModel.timeRemainingString) remaining)"
    }

    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            showContextMenu(sender)
        } else {
            togglePopover(sender)
        }
    }

    private func togglePopover(_ sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            viewModel.refreshState()
            if let hosting = popover.contentViewController {
                let fitting = hosting.view.fittingSize
                let targetHeight = max(fitting.height, 460)
                popover.contentSize = NSSize(width: 350, height: targetHeight)
            }
            popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func showContextMenu(_ sender: NSStatusBarButton) {
        let menu = NSMenu()

        let statusTitle = "Status: \(viewModel.status.displayTitle)"
        let statusItem = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu.addItem(statusItem)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettingsAction), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Refresh Status", action: #selector(refreshStatusAction), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Open DeepSeek", action: #selector(openDeepSeekAction), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit DeepSeek Peak Hours", action: #selector(quitAction), keyEquivalent: "q"))

        for item in menu.items {
            item.target = self
        }

        statusItem.target = nil
        self.statusItem.menu = menu
        self.statusItem.button?.performClick(nil)
        self.statusItem.menu = nil // Restore click handling
    }

    @objc private func openSettingsAction() {
        openSettings()
    }

    @objc private func refreshStatusAction() {
        viewModel.refreshState()
    }

    @objc private func openDeepSeekAction() {
        viewModel.openDeepSeek()
    }

    @objc private func quitAction() {
        viewModel.quitApp()
    }

    public func openSettings() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView(viewModel: viewModel)
        let hostingController = NSHostingController(rootView: settingsView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 480),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Settings"
        window.contentViewController = hostingController
        window.isReleasedWhenClosed = false
        window.level = .floating

        self.settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - NSPopoverDelegate
    public func popoverWillShow(_ notification: Notification) {
        viewModel.isPopoverOpen = true
    }

    public func popoverDidClose(_ notification: Notification) {
        viewModel.isPopoverOpen = false
    }
}

extension NSImage {
    func tinted(with color: NSColor) -> NSImage {
        guard let copied = self.copy() as? NSImage else { return self }
        copied.lockFocus()
        color.set()
        let imageRect = NSRect(origin: .zero, size: copied.size)
        imageRect.fill(using: .sourceAtop)
        copied.unlockFocus()
        copied.isTemplate = false
        return copied
    }
}
