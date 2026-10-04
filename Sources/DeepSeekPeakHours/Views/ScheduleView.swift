import SwiftUI
import DeepSeekPeakHoursCore

public struct ScheduleView: View {
    let periods: [PeakPeriod]
    let currentTime: Date
    let timeZone: TimeZone

    public init(periods: [PeakPeriod], currentTime: Date = Date(), timeZone: TimeZone = .current) {
        self.periods = periods
        self.currentTime = currentTime
        self.timeZone = timeZone
    }

    private var timeFormatter: DateFormatter {
        let df = DateFormatter()
        df.timeZone = timeZone
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "HH:mm"
        return df
    }

    private var isAllDayPeriod: (PeakPeriod) -> Bool {
        return { period in
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = timeZone
            let startHour = cal.component(.hour, from: period.start)
            let startMin = cal.component(.minute, from: period.start)
            let endHour = cal.component(.hour, from: period.end)
            let endMin = cal.component(.minute, from: period.end)

            // If it starts at 00:00 and ends at 00:00 next day (duration >= 23h 59m)
            let duration = period.end.timeIntervalSince(period.start)
            return (startHour == 0 && startMin == 0 && endHour == 0 && endMin == 0 && duration >= 86000)
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Today's Schedule")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.3)

                Spacer()

                Text(timeZone.identifier)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 5) {
                if periods.isEmpty {
                    Text("No schedule available for today.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                } else {
                    ForEach(periods) { period in
                        let isActive = period.contains(currentTime)
                        let isAllDay = isAllDayPeriod(period)

                        HStack(spacing: 8) {
                            Circle()
                                .fill(period.status == .peak ? Color.red : Color.green)
                                .frame(width: 8, height: 8)

                            if isAllDay {
                                Text("Full Day · 00:00 → 24:00")
                                    .font(.system(size: 12, weight: isActive ? .bold : .medium, design: .monospaced))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                            } else {
                                HStack(spacing: 5) {
                                    Text(timeFormatter.string(from: period.start))
                                        .font(.system(size: 12, weight: isActive ? .bold : .medium, design: .monospaced))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)

                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 9, weight: .semibold))
                                        .foregroundColor(.secondary)

                                    let endString: String = {
                                        var cal = Calendar(identifier: .gregorian)
                                        cal.timeZone = timeZone
                                        if cal.component(.hour, from: period.end) == 0 && cal.component(.minute, from: period.end) == 0 {
                                            return "24:00"
                                        }
                                        return timeFormatter.string(from: period.end)
                                    }()

                                    Text(endString)
                                        .font(.system(size: 12, weight: isActive ? .bold : .medium, design: .monospaced))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                }
                                .fixedSize(horizontal: true, vertical: false)
                            }

                            Spacer()

                            Text(period.status == .peak ? "Peak" : "Off-peak")
                                .font(.system(size: 11, weight: isActive ? .bold : .medium))
                                .foregroundColor(period.status == .peak ? .red : .green)
                                .lineLimit(1)

                            if isActive {
                                Text("NOW")
                                    .font(.system(size: 9, weight: .heavy))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.accentColor.opacity(0.18))
                                    .foregroundColor(.accentColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(isActive ? Color.accentColor.opacity(0.09) : Color(nsColor: .controlBackgroundColor).opacity(0.4))
                        )
                    }
                }
            }
        }
    }
}
