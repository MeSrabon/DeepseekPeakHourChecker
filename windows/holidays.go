package main

import (
	"embed"
	"encoding/json"
	"fmt"
	"time"
)

//go:embed holidays/*.json
var holidayFS embed.FS

type HolidayDay struct {
	Date     string `json:"date"`
	Name     string `json:"name"`
	IsOffDay bool   `json:"isOffDay"`
}

type HolidayDatabase struct {
	holidaysByDate map[string]HolidayDay
}

var globalHolidays *HolidayDatabase

func initHolidayDatabase() (*HolidayDatabase, error) {
	db := &HolidayDatabase{
		holidaysByDate: make(map[string]HolidayDay),
	}

	years := []int{2025, 2026, 2027, 2028}
	for _, year := range years {
		filename := fmt.Sprintf("holidays/china-%d.json", year)
		data, err := holidayFS.ReadFile(filename)
		if err != nil {
			continue
		}

		var days []HolidayDay
		if err := json.Unmarshal(data, &days); err != nil {
			continue
		}

		for _, day := range days {
			db.holidaysByDate[day.Date] = day
		}
	}

	return db, nil
}

func (db *HolidayDatabase) IsChineseHoliday(t time.Time) (bool, string) {
	utc := t.UTC()
	dateStr := utc.Format("2006-01-02")
	if day, ok := db.holidaysByDate[dateStr]; ok && day.IsOffDay {
		return true, day.Name
	}
	return false, ""
}
