# DeepSeek Peak Hour Checker

A lightweight, native macOS menu-bar utility that continuously monitors DeepSeek's pricing schedule and indicates whether the service is currently in **Peak Hours** or **Off-Peak Hours**.

Lives entirely in the macOS menu bar (`LSUIElement = true`) with a native SwiftUI popover, real-time countdown, dynamic timezone conversion, Chinese statutory public holiday recognition, and transition notifications.

---

## Features

- **Menu Bar Indicator**:
  - 🔴 **Red status dot**: DeepSeek Peak Hours (100% rate).
  - 🟢 **Green status dot**: DeepSeek Off-Peak Hours (off-peak rates are 50% of peak — a uniform 50% discount across all current models).
  - High-DPI Retina custom status item with accessibility labels and tooltips.
- **Authoritative UTC Source of Truth**:
  - DeepSeek canonical schedule:
    - **01:00–04:00 UTC** (Peak)
    - **06:00–10:00 UTC** (Peak)
    - Monday through Friday, excluding Chinese public holidays.
    - All other times, including weekends and statutory Chinese holidays, are **Off-Peak**.
- **Dynamic Timezone Conversion**:
  - Automatically calculates schedule in the user's local timezone using Apple Foundation `Calendar` and `TimeZone`.
  - For Bangladesh (`Asia/Dhaka`, UTC+6):
    - **07:00–10:00 BDT** (Peak)
    - **10:00–12:00 BDT** (Off-peak)
    - **12:00–16:00 BDT** (Peak)
    - **16:00–07:00 BDT** (Off-peak)
- **Chinese Public Holiday Engine**:
  - Modular `HolidayProvider` architecture with bundled offline data (`china-2025.json` … `china-2028.json`).
  - Remote updater pulls the official State Council schedule (mirror: `NateScarlet/holiday-cn`) and caches it in `~/Library/Application Support/DeepSeekPeakHours/Holidays/`.
  - **Data integrity guard**: every bundled, cached, or downloaded calendar is validated (`HolidayCalendarValidator`). Incomplete upstream responses are rejected, so they can never overwrite validated data. The legacy Nager.Date source returned only six single days and dropped Golden Week — that class of regression is now impossible.
  - Make-up working days (调休) are stored for completeness but never waive peak pricing.
  - Contextual popover explanation whenever a holiday is active (e.g. National Day Golden Week).
- **System Event Awareness**:
  - Automatically recalculates on `NSWorkspace.didWakeNotification`, `NSSystemClockDidChange`, `NSCalendarDayChanged`, and `NSSystemTimeZoneDidChange`.
- **Power Efficient**:
  - Zero polling. Uses a discrete single timer scheduled precisely at `nextTransition`.
  - Live 1Hz countdown runs **only** while the popover dropdown is open.
- **Native macOS Notifications**:
  - Sends alerts when peak hours start and end.
  - Optional 15-minute and 30-minute advance warnings before peak pricing begins.
- **Launch at Login**:
  - Integrated via Apple's modern `SMAppService.mainApp` API.
- **Settings Window**:
  - Tabbed settings for General (launch at login, dock icon), Notifications, Timezone selection (Automatic, Bangladesh, UTC, Custom), and Holidays.

---

## Architecture

```
DeepSeekPeakHours/
├── Package.swift                                      # SPM package definition
├── DeepSeekPeakHours.xcodeproj/                       # Xcode project
├── Sources/
│   ├── DeepSeekPeakHoursCore/                         # Business Logic & Core Library
│   │   ├── Models/
│   │   │   ├── PeakStatus.swift                      # .peak, .offPeak
│   │   │   ├── PeakPeriod.swift                      # Interval model
│   │   │   ├── ChineseHoliday.swift                  # Holiday structures
│   │   │   ├── PeakStatusInfo.swift                  # Diagnostic explanation & bounds
│   │   │   ├── DeepSeekSchedule.swift                # Schedule constants & discounts
│   │   │   ├── DeepSeekModel.swift                   # DeepSeek model definitions
│   │   │   └── AppSettings.swift                     # Preferences wrapper
│   │   ├── Services/
│   │   │   ├── PeakHourCalculator.swift              # Authoritative UTC calculator
│   │   │   ├── HolidayProvider.swift                 # Local/Remote holiday providers
│   │   │   ├── HolidayCalendarValidator.swift        # Plausibility / no-regression guard
│   │   │   ├── HolidayService.swift                  # Holiday cache coordinator
│   │   │   ├── NotificationService.swift             # UNUserNotificationCenter
│   │   │   ├── TimeService.swift                     # Sleep/wake, timers, clock changes
│   │   │   └── LaunchAtLoginService.swift            # SMAppService wrapper
│   │   ├── ViewModels/
│   │   │   └── StatusViewModel.swift                 # Main observable state controller
│   │   └── Resources/Holidays/                       # Bundled Chinese holiday calendars
│   │       ├── china-2025.json
│   │       ├── china-2026.json
│   │       ├── china-2027.json
│   │       └── china-2028.json
│   └── DeepSeekPeakHours/                            # macOS App & Presentation
│       ├── App/
│       │   ├── DeepSeekPeakHoursApp.swift            # Main entry point & lifecycle
│       │   └── StatusBarController.swift             # NSStatusItem, NSPopover, icons
│       └── Views/
│           ├── DeepSeekLogo.swift                    # Vector DeepSeek whale & status icons
│           ├── MenuBarView.swift                     # Popover root view
│           ├── StatusView.swift                      # Big status & countdown
│           ├── StatusBadgeView.swift                 # Glow pill badge
│           ├── ScheduleView.swift                    # Today's interval timeline
│           ├── HolidayExplainerView.swift            # Holiday callout banner
│           └── SettingsView.swift                    # Preferences window
├── Tests/
│   └── DeepSeekPeakHoursTests/
│       └── main.swift                                # 73 comprehensive tests
├── Support/
│   ├── Info.plist                                    # App metadata (LSUIElement=true)
│   ├── AppIcon.icns                                  # Native multi-res macOS icon
│   ├── AppIcon-1024.png                              # 1024x1024 master icon
│   ├── deepseek-logo.svg                             # Original DeepSeek SVG
│   └── deepseek-whale.svg                            # Extracted whale SVG
└── scripts/
    ├── build_app.sh                                  # Compiles & bundles .app
    ├── create_dmg.sh                                 # Packages into .dmg installer
    ├── generate_icon.swift                           # Generates AppIcon
    └── generate_xcodeproj.py                         # Generates Xcode project
```

---

## Building and Running

### 1. Run Unit Tests

Execute the comprehensive test suite (covering Monday peaks, interim off-peaks, Friday-to-Monday transitions, Chinese public holidays and make-up workdays, calendar validation, midnight boundaries, and Bangladesh timezone calculations):

```bash
swift run DeepSeekPeakHoursTests
```

### 2. Build Release Application

Compile and package `DeepSeek Peak Hours.app` with icons, resources, and ad-hoc code signature:

```bash
./scripts/build_app.sh
```

The resulting application is placed in `build/DeepSeek Peak Hours.app`.

### 3. Create DMG Installer

Generate a release disk image installer with a drag-and-drop link to `/Applications`:

```bash
./scripts/create_dmg.sh
```

The installer is generated at `build/DeepSeek-Peak-Hours.dmg`.

### 4. Running the App

You can launch the built application directly from Terminal or Finder:

```bash
open "build/DeepSeek Peak Hours.app"
```

Or copy it to your Applications folder:

```bash
cp -R "build/DeepSeek Peak Hours.app" /Applications/
```

### 5. Opening in Xcode

You can open the project in Xcode using either:

```bash
open DeepSeekPeakHours.xcodeproj
```

Or open the Swift Package directly:

```bash
open Package.swift
```

---

## License

MIT License. DeepSeek is a trademark of DeepSeek. This project is an independent community utility.
