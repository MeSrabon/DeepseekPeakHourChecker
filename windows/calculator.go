package main

import (
	"fmt"
	"time"
)

type StatusType int

const (
	StatusOffPeak StatusType = 0
	StatusPeak    StatusType = 1
)

type StatusInfo struct {
	Status           StatusType
	Title            string
	Reason           string
	DiscountText     string
	NextTransition   time.Time
	TimeRemaining    time.Duration
	IsChineseHoliday bool
	HolidayName      string
}

type PeakHourCalculator struct {
	holidays *HolidayDatabase
}

func NewCalculator(holidays *HolidayDatabase) *PeakHourCalculator {
	return &PeakHourCalculator{holidays: holidays}
}

// IsPeakAt determines if the specified UTC time falls in DeepSeek Peak pricing.
func (c *PeakHourCalculator) IsPeakAt(t time.Time) (bool, string, bool, string) {
	utc := t.UTC()
	weekday := utc.Weekday()

	// Check Chinese statutory public holiday (full-day waiver)
	if c.holidays != nil {
		if isHoliday, name := c.holidays.IsChineseHoliday(utc); isHoliday {
			return false, fmt.Sprintf("Chinese Statutory Holiday (%s) — Peak hours waived", name), true, name
		}
	}

	// Weekend: Saturday and Sunday are always Off-Peak
	if weekday == time.Saturday || weekday == time.Sunday {
		return false, "Weekend — Off-Peak pricing active", false, ""
	}

	secOfDay := utc.Hour()*3600 + utc.Minute()*60 + utc.Second()

	// Peak 1: 01:00 to 04:00 UTC (3600 <= sec < 14400)
	if secOfDay >= 3600 && secOfDay < 14400 {
		return true, "Peak Window 1 (01:00–04:00 UTC)", false, ""
	}

	// Peak 2: 06:00 to 10:00 UTC (21600 <= sec < 36000)
	if secOfDay >= 21600 && secOfDay < 36000 {
		return true, "Peak Window 2 (06:00–10:00 UTC)", false, ""
	}

	// Weekday between or after peaks
	if secOfDay < 3600 {
		return false, "Weekday Pre-Peak — Off-Peak discount active", false, ""
	} else if secOfDay < 21600 {
		return false, "Weekday Midday Interval — Off-Peak discount active", false, ""
	} else {
		return false, "Weekday Evening — Off-Peak discount active", false, ""
	}
}

// NextTransition calculates the exact next second when pricing status changes.
func (c *PeakHourCalculator) NextTransition(t time.Time) time.Time {
	utc := t.UTC()
	currentPeak, _, _, _ := c.IsPeakAt(utc)

	// Step forward candidate transition points (01:00, 04:00, 06:00, 10:00 UTC)
	// Iterate day by day up to 8 days
	for d := 0; d < 8; d++ {
		baseDate := time.Date(utc.Year(), utc.Month(), utc.Day(), 0, 0, 0, 0, time.UTC).AddDate(0, 0, d)
		candidateHours := []int{1, 4, 6, 10}

		for _, h := range candidateHours {
			cand := baseDate.Add(time.Duration(h) * time.Hour)
			if !cand.After(utc) {
				continue
			}

			isPeak, _, _, _ := c.IsPeakAt(cand)
			if isPeak != currentPeak {
				return cand
			}
		}
	}

	return utc.Add(1 * time.Hour)
}

func (c *PeakHourCalculator) StatusInfo(t time.Time) StatusInfo {
	isPeak, reason, isHol, holName := c.IsPeakAt(t)
	nextT := c.NextTransition(t)

	status := StatusOffPeak
	title := "OFF-PEAK"
	discount := "50% OFF"
	if isPeak {
		status = StatusPeak
		title = "PEAK HOURS"
		discount = "Standard Rate"
	}

	diff := nextT.Sub(t.UTC())
	if diff < 0 {
		diff = 0
	}

	return StatusInfo{
		Status:           status,
		Title:            title,
		Reason:           reason,
		DiscountText:     discount,
		NextTransition:   nextT,
		TimeRemaining:    diff,
		IsChineseHoliday: isHol,
		HolidayName:      holName,
	}
}

func formatDuration(d time.Duration) string {
	d = d.Round(time.Second)
	h := int(d.Hours())
	m := int(d.Minutes()) % 60
	s := int(d.Seconds()) % 60

	if h > 0 {
		return fmt.Sprintf("%dh %02dm %02ds", h, m, s)
	}
	if m > 0 {
		return fmt.Sprintf("%dm %02ds", m, s)
	}
	return fmt.Sprintf("%ds", s)
}
