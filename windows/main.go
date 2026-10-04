package main

import (
	"log"
)

func main() {
	holidayDb, err := initHolidayDatabase()
	if err != nil {
		log.Printf("Warning: failed to load embedded holidays: %v", err)
	}

	calc := NewCalculator(holidayDb)
	app, err := NewTrayApp(calc)
	if err != nil {
		log.Fatalf("Failed to initialize Windows tray app: %v", err)
	}

	app.Run()
}
