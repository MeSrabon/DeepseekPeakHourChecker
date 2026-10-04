package main

import (
	_ "embed"
	"fmt"
	"os/exec"
	"syscall"
	"time"
	"unsafe"
)

//go:embed assets/icon_offpeak.ico
var iconOffPeakICO []byte

//go:embed assets/icon_peak.ico
var iconPeakICO []byte

const (
	WM_USER            = 0x0400
	WM_TRAYICON        = WM_USER + 1
	WM_COMMAND         = 0x0111
	WM_RBUTTONUP       = 0x0205
	WM_LBUTTONUP       = 0x0202
	NIM_ADD            = 0x00000000
	NIM_MODIFY         = 0x00000001
	NIM_DELETE         = 0x00000002
	NIF_MESSAGE        = 0x00000001
	NIF_ICON           = 0x00000002
	NIF_TIP            = 0x00000004
	NIF_INFO           = 0x00000010
	NIIF_INFO          = 0x00000001
	MF_STRING          = 0x00000000
	MF_SEPARATOR       = 0x00000800
	MF_GRAYED          = 0x00000001
	MF_DISABLED        = 0x00000002
	TPM_BOTTOMALIGN    = 0x0020
	TPM_LEFTALIGN      = 0x0000
	TPM_RIGHTBUTTON    = 0x0002
	LR_DEFAULTCOLOR    = 0x0000
)

const (
	IDM_STATUS = 1001 + iota
	IDM_REMAINING
	IDM_SCHEDULE1
	IDM_SCHEDULE2
	IDM_HOLIDAY
	IDM_OPEN_DEEPSEEK
	IDM_OPEN_DOCS
	IDM_REFRESH
	IDM_EXIT
)

var (
	modUser32  = syscall.NewLazyDLL("user32.dll")
	modShell32 = syscall.NewLazyDLL("shell32.dll")
	modKernel  = syscall.NewLazyDLL("kernel32.dll")

	procRegisterClassExW        = modUser32.NewProc("RegisterClassExW")
	procCreateWindowExW         = modUser32.NewProc("CreateWindowExW")
	procDefWindowProcW          = modUser32.NewProc("DefWindowProcW")
	procDestroyWindow           = modUser32.NewProc("DestroyWindow")
	procPostQuitMessage         = modUser32.NewProc("PostQuitMessage")
	procGetMessageW             = modUser32.NewProc("GetMessageW")
	procTranslateMessage        = modUser32.NewProc("TranslateMessage")
	procDispatchMessageW        = modUser32.NewProc("DispatchMessageW")
	procCreatePopupMenu         = modUser32.NewProc("CreatePopupMenu")
	procAppendMenuW             = modUser32.NewProc("AppendMenuW")
	procTrackPopupMenu          = modUser32.NewProc("TrackPopupMenu")
	procDestroyMenu             = modUser32.NewProc("DestroyMenu")
	procSetForegroundWindow     = modUser32.NewProc("SetForegroundWindow")
	procGetCursorPos            = modUser32.NewProc("GetCursorPos")
	procCreateIconFromResourceEx= modUser32.NewProc("CreateIconFromResourceEx")
	procDestroyIcon             = modUser32.NewProc("DestroyIcon")
	procShellNotifyIconW        = modShell32.NewProc("Shell_NotifyIconW")
	procGetModuleHandleW        = modKernel.NewProc("GetModuleHandleW")
)

type POINT struct {
	X, Y int32
}

type WNDCLASSEXW struct {
	CbSize        uint32
	Style         uint32
	LpfnWndProc   uintptr
	CbClsExtra    int32
	CbWndExtra    int32
	HInstance     uintptr
	HIcon         uintptr
	HCursor       uintptr
	HbrBackground uintptr
	LpszMenuName  *uint16
	LpszClassName *uint16
	HIconSm       uintptr
}

type NOTIFYICONDATAW struct {
	CbSize           uint32
	HWnd             uintptr
	UID              uint32
	UFlags           uint32
	UCallbackMessage uint32
	HIcon            uintptr
	SzTip            [128]uint16
	DwState          uint32
	DwStateMask      uint32
	SzInfo           [256]uint16
	UTimeoutOrVersion uint32
	SzInfoTitle      [64]uint16
	DwInfoFlags      uint32
	GuidItem         [16]byte
	HBalloonIcon     uintptr
}

type MSG struct {
	HWnd    uintptr
	Message uint32
	WParam  uintptr
	LParam  uintptr
	Time    uint32
	Pt      POINT
}

type TrayApp struct {
	hwnd         uintptr
	nid          NOTIFYICONDATAW
	calculator   *PeakHourCalculator
	hIconOffPeak uintptr
	hIconPeak    uintptr
	currentInfo  StatusInfo
	lastStatus   StatusType
}

var globalApp *TrayApp

func utf16Ptr(s string) *uint16 {
	p, _ := syscall.UTF16PtrFromString(s)
	return p
}

func copyUTF16(dst []uint16, src string) {
	u, _ := syscall.UTF16FromString(src)
	copy(dst, u)
}

func loadIconFromBytes(icoData []byte) uintptr {
	if len(icoData) < 22 {
		return 0
	}
	// ICO structure: 6 bytes header + 16 bytes directory entry = 22 bytes offset to image data
	imgBytes := icoData[22:]
	hIcon, _, _ := procCreateIconFromResourceEx.Call(
		uintptr(unsafe.Pointer(&imgBytes[0])),
		uintptr(len(imgBytes)),
		1, // TRUE = icon
		0x00030000,
		32, 32,
		LR_DEFAULTCOLOR,
	)
	return hIcon
}

func wndProc(hwnd uintptr, msg uint32, wParam uintptr, lParam uintptr) uintptr {
	switch msg {
	case WM_TRAYICON:
		if lParam == WM_RBUTTONUP || lParam == WM_LBUTTONUP {
			if globalApp != nil {
				globalApp.showContextMenu()
			}
			return 0
		}
	case WM_COMMAND:
		id := int(wParam & 0xFFFF)
		if globalApp != nil {
			globalApp.handleCommand(id)
		}
		return 0
	case 0x0002: // WM_DESTROY
		procPostQuitMessage.Call(0)
		return 0
	}

	ret, _, _ := procDefWindowProcW.Call(hwnd, uintptr(msg), wParam, lParam)
	return ret
}

func NewTrayApp(calc *PeakHourCalculator) (*TrayApp, error) {
	app := &TrayApp{
		calculator:   calc,
		hIconOffPeak: loadIconFromBytes(iconOffPeakICO),
		hIconPeak:    loadIconFromBytes(iconPeakICO),
	}
	globalApp = app

	className := "DeepSeekPeakHoursTrayClass"
	hInstance, _, _ := procGetModuleHandleW.Call(0)

	var wc WNDCLASSEXW
	wc.CbSize = uint32(unsafe.Sizeof(wc))
	wc.LpfnWndProc = syscall.NewCallback(wndProc)
	wc.HInstance = hInstance
	wc.LpszClassName = utf16Ptr(className)

	procRegisterClassExW.Call(uintptr(unsafe.Pointer(&wc)))

	hwnd, _, _ := procCreateWindowExW.Call(
		0,
		uintptr(unsafe.Pointer(utf16Ptr(className))),
		uintptr(unsafe.Pointer(utf16Ptr("DeepSeek Peak Hours"))),
		0,
		0, 0, 0, 0,
		0, 0, hInstance, 0,
	)

	app.hwnd = hwnd

	app.nid.CbSize = uint32(unsafe.Sizeof(app.nid))
	app.nid.HWnd = hwnd
	app.nid.UID = 1
	app.nid.UFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP
	app.nid.UCallbackMessage = WM_TRAYICON

	info := calc.StatusInfo(time.Now())
	app.currentInfo = info
	app.lastStatus = info.Status

	if info.Status == StatusPeak {
		app.nid.HIcon = app.hIconPeak
	} else {
		app.nid.HIcon = app.hIconOffPeak
	}

	tip := fmt.Sprintf("DeepSeek: %s (%s remaining)", info.Title, formatDuration(info.TimeRemaining))
	copyUTF16(app.nid.SzTip[:], tip)

	procShellNotifyIconW.Call(NIM_ADD, uintptr(unsafe.Pointer(&app.nid)))

	return app, nil
}

func (a *TrayApp) Update() {
	now := time.Now()
	info := a.calculator.StatusInfo(now)
	a.currentInfo = info

	a.nid.UFlags = NIF_ICON | NIF_TIP
	if info.Status == StatusPeak {
		a.nid.HIcon = a.hIconPeak
	} else {
		a.nid.HIcon = a.hIconOffPeak
	}

	tip := fmt.Sprintf("DeepSeek: %s (%s remaining)", info.Title, formatDuration(info.TimeRemaining))
	copyUTF16(a.nid.SzTip[:], tip)

	// Transition notification balloon
	if info.Status != a.lastStatus {
		a.nid.UFlags |= NIF_INFO
		a.nid.DwInfoFlags = NIIF_INFO
		if info.Status == StatusPeak {
			copyUTF16(a.nid.SzInfoTitle[:], "DeepSeek Peak Hours Started ⚠️")
			copyUTF16(a.nid.SzInfo[:], "Peak pricing is now in effect (Standard Rates). Off-peak resumes at 10:00 UTC.")
		} else {
			copyUTF16(a.nid.SzInfoTitle[:], "DeepSeek Off-Peak Started 🎉")
			copyUTF16(a.nid.SzInfo[:], "50% discount is now active across DeepSeek API models!")
		}
		a.lastStatus = info.Status
	}

	procShellNotifyIconW.Call(NIM_MODIFY, uintptr(unsafe.Pointer(&a.nid)))
}

func (a *TrayApp) showContextMenu() {
	hMenu, _, _ := procCreatePopupMenu.Call()

	// Title / Status banner
	statusTitle := fmt.Sprintf("● %s (%s)", a.currentInfo.Title, a.currentInfo.DiscountText)
	procAppendMenuW.Call(hMenu, MF_STRING|MF_DISABLED, IDM_STATUS, uintptr(unsafe.Pointer(utf16Ptr(statusTitle))))

	// Countdown
	remainingStr := fmt.Sprintf("Next: %s remaining", formatDuration(a.currentInfo.TimeRemaining))
	procAppendMenuW.Call(hMenu, MF_STRING|MF_DISABLED, IDM_REMAINING, uintptr(unsafe.Pointer(utf16Ptr(remainingStr))))

	// Holiday notice
	if a.currentInfo.IsChineseHoliday {
		holText := fmt.Sprintf("Holiday: %s (Off-Peak active)", a.currentInfo.HolidayName)
		procAppendMenuW.Call(hMenu, MF_STRING|MF_DISABLED, IDM_HOLIDAY, uintptr(unsafe.Pointer(utf16Ptr(holText))))
	}

	procAppendMenuW.Call(hMenu, MF_SEPARATOR, 0, 0)

	// Local schedule summary
	localTz := time.Local
	now := time.Now().In(localTz)
	tzName, _ := now.Zone()

	procAppendMenuW.Call(hMenu, MF_STRING|MF_DISABLED, 0, uintptr(unsafe.Pointer(utf16Ptr(fmt.Sprintf("Schedule (%s):", tzName)))))
	procAppendMenuW.Call(hMenu, MF_STRING|MF_DISABLED, IDM_SCHEDULE1, uintptr(unsafe.Pointer(utf16Ptr("  Peak 1: 01:00-04:00 UTC"))))
	procAppendMenuW.Call(hMenu, MF_STRING|MF_DISABLED, IDM_SCHEDULE2, uintptr(unsafe.Pointer(utf16Ptr("  Peak 2: 06:00-10:00 UTC"))))

	procAppendMenuW.Call(hMenu, MF_SEPARATOR, 0, 0)

	procAppendMenuW.Call(hMenu, MF_STRING, IDM_OPEN_DEEPSEEK, uintptr(unsafe.Pointer(utf16Ptr("Open DeepSeek Platform"))))
	procAppendMenuW.Call(hMenu, MF_STRING, IDM_OPEN_DOCS, uintptr(unsafe.Pointer(utf16Ptr("Open Pricing Documentation"))))

	procAppendMenuW.Call(hMenu, MF_SEPARATOR, 0, 0)
	procAppendMenuW.Call(hMenu, MF_STRING, IDM_REFRESH, uintptr(unsafe.Pointer(utf16Ptr("Refresh Status"))))
	procAppendMenuW.Call(hMenu, MF_STRING, IDM_EXIT, uintptr(unsafe.Pointer(utf16Ptr("Exit"))))

	var pt POINT
	procGetCursorPos.Call(uintptr(unsafe.Pointer(&pt)))

	procSetForegroundWindow.Call(a.hwnd)
	procTrackPopupMenu.Call(
		hMenu,
		TPM_BOTTOMALIGN|TPM_LEFTALIGN|TPM_RIGHTBUTTON,
		uintptr(pt.X),
		uintptr(pt.Y),
		0,
		a.hwnd,
		0,
	)
	procDestroyMenu.Call(hMenu)
}

func (a *TrayApp) handleCommand(cmdId int) {
	switch cmdId {
	case IDM_OPEN_DEEPSEEK:
		_ = exec.Command("cmd", "/c", "start", "https://platform.deepseek.com").Start()
	case IDM_OPEN_DOCS:
		_ = exec.Command("cmd", "/c", "start", "https://api-docs.deepseek.com/quick_start/pricing").Start()
	case IDM_REFRESH:
		a.Update()
	case IDM_EXIT:
		procShellNotifyIconW.Call(NIM_DELETE, uintptr(unsafe.Pointer(&a.nid)))
		procDestroyWindow.Call(a.hwnd)
		procPostQuitMessage.Call(0)
	}
}

func (a *TrayApp) Run() {
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()

	go func() {
		for range ticker.C {
			a.Update()
		}
	}()

	var msg MSG
	for {
		ret, _, _ := procGetMessageW.Call(uintptr(unsafe.Pointer(&msg)), 0, 0, 0)
		if int32(ret) <= 0 {
			break
		}
		procTranslateMessage.Call(uintptr(unsafe.Pointer(&msg)))
		procDispatchMessageW.Call(uintptr(unsafe.Pointer(&msg)))
	}
}
