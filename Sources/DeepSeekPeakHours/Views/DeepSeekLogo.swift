import AppKit
import SwiftUI
import DeepSeekPeakHoursCore

/// High-performance vector rendering for the official DeepSeek whale logo and status bar badge.
public enum DeepSeekLogo {
    /// DeepSeek official brand blue (#4D6BFE)
    public static let brandBlue = NSColor(calibratedRed: 0.302, green: 0.420, blue: 0.996, alpha: 1.0)
    public static let brandBlueColor = Color(red: 0.302, green: 0.420, blue: 0.996)

    /// Off-peak emerald green (#22C55E)
    public static let offPeakGreen = NSColor(calibratedRed: 0.133, green: 0.773, blue: 0.369, alpha: 1.0)
    /// Peak coral red (#EF4444)
    public static let peakRed = NSColor(calibratedRed: 0.937, green: 0.267, blue: 0.267, alpha: 1.0)

    /// Raw SVG path for the DeepSeek whale silhouette extracted from the official Wikimedia icon.
    private static let rawWhalePath = "M440.898 139.167c-4.001-1.961-5.723 1.776-8.062 3.673-.801.612-1.479 1.407-2.154 2.141-5.848 6.246-12.681 10.349-21.607 9.859-13.048-.734-24.192 3.368-34.04 13.348-2.093-12.307-9.048-19.658-19.635-24.37-5.54-2.449-11.141-4.9-15.02-10.227-2.708-3.795-3.447-8.021-4.801-12.185-.861-2.509-1.725-5.082-4.618-5.512-3.139-.49-4.372 2.142-5.601 4.349-4.925 9.002-6.833 18.921-6.647 28.962.432 22.597 9.972 40.597 28.932 53.397 2.154 1.47 2.707 2.939 2.032 5.082-1.293 4.41-2.832 8.695-4.186 13.105-.862 2.817-2.157 3.429-5.172 2.205-10.402-4.346-19.391-10.778-27.332-18.553-13.481-13.044-25.668-27.434-40.873-38.702a177.614 177.614 0 00-10.834-7.409c-15.512-15.063 2.032-27.434 6.094-28.902 4.247-1.532 1.478-6.797-12.251-6.736-13.727.061-26.285 4.653-42.288 10.777-2.34.92-4.801 1.593-7.326 2.142-14.527-2.756-29.608-3.368-45.367-1.593-29.671 3.305-53.368 17.329-70.788 41.272-20.928 28.785-25.854 61.482-19.821 95.59 6.34 35.943 24.683 65.704 52.876 88.974 29.239 24.123 62.911 35.943 101.32 33.677 23.329-1.346 49.307-4.468 78.607-29.27 7.387 3.673 15.142 5.144 28.008 6.246 9.911.92 19.452-.49 26.839-2.019 11.573-2.449 10.773-13.166 6.586-15.124-33.915-15.797-26.47-9.368-33.24-14.573 17.235-20.39 43.213-41.577 53.369-110.222.8-5.448.121-8.877 0-13.287-.061-2.692.553-3.734 3.632-4.041 8.494-.981 16.742-3.305 24.314-7.471 21.975-12.002 30.84-31.719 32.933-55.355.307-3.612-.061-7.348-3.879-9.245v-.003zM249.4 351.89c-32.872-25.838-48.814-34.352-55.4-33.984-6.155.368-5.048 7.41-3.694 12.002 1.415 4.532 3.264 7.654 5.848 11.634 1.785 2.634 3.017 6.551-1.784 9.493-10.587 6.55-28.993-2.205-29.856-2.635-21.421-12.614-39.334-29.269-51.954-52.047-12.187-21.924-19.267-45.435-20.435-70.542-.308-6.061 1.478-8.207 7.509-9.307 7.94-1.471 16.127-1.778 24.068-.615 33.547 4.9 62.108 19.902 86.054 43.66 13.666 13.531 24.007 29.699 34.658 45.496 11.326 16.778 23.514 32.761 39.026 45.865 5.479 4.592 9.848 8.083 14.035 10.656-12.62 1.407-33.673 1.714-48.075-9.676zm15.899-102.519c.521-2.111 2.421-3.658 4.722-3.658a4.74 4.74 0 011.661.305c.678.246 1.293.614 1.786 1.163.861.859 1.354 2.083 1.354 3.368 0 2.695-2.154 4.837-4.862 4.837a4.748 4.748 0 01-4.738-4.034 5.01 5.01 0 01.077-1.981zm47.208 26.915c-2.606.996-5.2 1.778-7.707 1.88-4.679.244-9.787-1.654-12.556-3.981-4.308-3.612-7.386-5.631-8.679-11.941-.554-2.695-.247-6.858.246-9.246 1.108-5.144-.124-8.451-3.754-11.451-2.954-2.449-6.711-3.122-10.834-3.122-1.539 0-2.954-.673-4.001-1.224-1.724-.856-3.139-3-1.785-5.634.432-.856 2.525-2.939 3.018-3.305 5.6-3.185 12.065-2.144 18.034.244 5.54 2.266 9.727 6.429 15.759 12.307 6.155 7.102 7.263 9.063 10.773 14.39 2.771 4.163 5.294 8.451 7.018 13.348.877 2.561.071 4.74-2.341 6.277-.981.625-2.109 1.044-3.191 1.458z"

    // Tight viewBox with no extra whitespace (whale is 382 x 282)
    public static func tightWhaleSvg(fillColorHex: String) -> String {
        """
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="65 113 382 282" fill="\(fillColorHex)">
        <path fill-rule="nonzero" d="\(rawWhalePath)"/>
        </svg>
        """
    }

    // Cache rendered whale images
    private static var cachedTightWhaleWhite: NSImage?
    private static var cachedTightWhaleBlack: NSImage?
    private static var cachedTightWhaleBlue: NSImage?
    private static var cachedTightWhaleGreen: NSImage?
    private static var cachedTightWhaleRed: NSImage?

    /// Returns a vector NSImage of the whale with tight bounds in the requested color.
    public static func tightWhaleImage(color: NSColor = .white) -> NSImage {
        if color == .white, let cached = cachedTightWhaleWhite { return cached }
        if color == .black, let cached = cachedTightWhaleBlack { return cached }
        if color == brandBlue, let cached = cachedTightWhaleBlue { return cached }
        if color == offPeakGreen, let cached = cachedTightWhaleGreen { return cached }
        if color == peakRed, let cached = cachedTightWhaleRed { return cached }

        let hex: String
        if color == .white {
            hex = "#FFFFFF"
        } else if color == .black {
            hex = "#000000"
        } else if color == offPeakGreen {
            hex = "#22C55E"
        } else if color == peakRed {
            hex = "#EF4444"
        } else {
            hex = "#4D6BFE"
        }

        let svg = tightWhaleSvg(fillColorHex: hex)
        if let data = svg.data(using: .utf8), let img = NSImage(data: data) {
            img.size = NSSize(width: 382, height: 282)
            if color == .white { cachedTightWhaleWhite = img }
            else if color == .black { cachedTightWhaleBlack = img }
            else if color == brandBlue { cachedTightWhaleBlue = img }
            else if color == offPeakGreen { cachedTightWhaleGreen = img }
            else if color == peakRed { cachedTightWhaleRed = img }
            return img
        }

        return NSImage()
    }

    /// Renders a prominent, clean, native macOS menu-bar icon that matches system monochrome aesthetics.
    public static func menuBarIcon(
        isPeak: Bool,
        style: MenuBarIconStyle = .minimalWithDot
    ) -> NSImage {
        let size = NSSize(width: 22, height: 18)
        let statusColor = isPeak ? peakRed : offPeakGreen

        switch style {
        case .pureMonochrome:
            // Pure clean template silhouette (macOS automatically inverts in dark/light mode)
            let img = NSImage(size: size, flipped: false) { rect in
                let whale = tightWhaleImage(color: .white)
                let whaleW: CGFloat = 18.0
                let whaleH: CGFloat = 13.3
                let whaleX: CGFloat = (size.width - whaleW) / 2.0
                let whaleY: CGFloat = (size.height - whaleH) / 2.0
                whale.draw(in: NSRect(x: whaleX, y: whaleY, width: whaleW, height: whaleH))
                return true
            }
            img.isTemplate = true
            return img

        case .statusColored:
            // Whale glyph tinted directly with Peak (Red) / Off-Peak (Green)
            let img = NSImage(size: size, flipped: false) { rect in
                let whale = tightWhaleImage(color: statusColor)
                let whaleW: CGFloat = 18.0
                let whaleH: CGFloat = 13.3
                let whaleX: CGFloat = (size.width - whaleW) / 2.0
                let whaleY: CGFloat = (size.height - whaleH) / 2.0
                whale.draw(in: NSRect(x: whaleX, y: whaleY, width: whaleW, height: whaleH))
                return true
            }
            img.isTemplate = false
            return img

        case .minimalWithDot:
            // Clean white/black whale with a minimal glowing status pip in the corner
            let img = NSImage(size: size, flipped: false) { rect in
                guard let ctx = NSGraphicsContext.current?.cgContext else { return false }

                // Check appearance for contrast: pure white in dark menu bar, dark in light
                let isDark: Bool
                if let appearance = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .vibrantDark, .aqua, .vibrantLight]) {
                    isDark = (appearance == .darkAqua || appearance == .vibrantDark)
                } else {
                    isDark = true
                }

                let whaleImg = isDark ? tightWhaleImage(color: .white) : tightWhaleImage(color: .black)

                // Large, prominent whale filling the status item
                let whaleW: CGFloat = 17.5
                let whaleH: CGFloat = 12.9
                let whaleX: CGFloat = 0.6
                let whaleY: CGFloat = 2.4
                whaleImg.draw(in: NSRect(x: whaleX, y: whaleY, width: whaleW, height: whaleH))

                // Status Indicator Pip in bottom right corner
                let dotSize: CGFloat = 4.8
                let dotX: CGFloat = size.width - dotSize - 0.5
                let dotY: CGFloat = 1.3
                let dotRect = NSRect(x: dotX, y: dotY, width: dotSize, height: dotSize)

                // Clear cutout separator ring to detach the pip cleanly from the whale's fin
                let cutoutRect = dotRect.insetBy(dx: -0.9, dy: -0.9)
                ctx.saveGState()
                ctx.setBlendMode(.clear)
                ctx.fillEllipse(in: cutoutRect)
                ctx.restoreGState()

                // Status dot fill
                statusColor.setFill()
                let pipPath = NSBezierPath(ovalIn: dotRect)
                pipPath.fill()

                return true
            }
            img.isTemplate = false
            return img
        }
    }
}

/// SwiftUI View representation of the DeepSeek Whale Logo with optional status indicator.
public struct DeepSeekLogoView: View {
    public let size: CGFloat
    public let status: PeakStatus?
    public let showStatusRing: Bool

    public init(size: CGFloat = 24, status: PeakStatus? = nil, showStatusRing: Bool = false) {
        self.size = size
        self.status = status
        self.showStatusRing = showStatusRing
    }

    private var statusColor: Color {
        guard let status else { return DeepSeekLogo.brandBlueColor }
        return status == .peak ? Color.red : Color.green
    }

    public var body: some View {
        ZStack {
            if showStatusRing, status != nil {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: size, height: size)

                Circle()
                    .stroke(statusColor.opacity(0.85), lineWidth: max(1.2, size * 0.06))
                    .frame(width: size, height: size)
            }

            Image(nsImage: DeepSeekLogo.tightWhaleImage(color: DeepSeekLogo.brandBlue))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: showStatusRing ? size * 0.68 : size, height: showStatusRing ? size * 0.68 : size)

            if status != nil, showStatusRing {
                Circle()
                    .fill(statusColor)
                    .frame(width: max(5, size * 0.26), height: max(5, size * 0.26))
                    .overlay(
                        Circle()
                            .stroke(Color(nsColor: .windowBackgroundColor), lineWidth: 1.2)
                    )
                    .overlay(
                        Circle()
                            .fill(Color.white.opacity(0.85))
                            .frame(width: max(2, size * 0.1), height: max(2, size * 0.1))
                    )
                    .offset(x: size * 0.32, y: size * 0.32)
            }
        }
        .frame(width: size, height: size)
    }
}
