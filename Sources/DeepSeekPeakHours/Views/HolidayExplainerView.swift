import SwiftUI
import DeepSeekPeakHoursCore

public struct HolidayExplainerView: View {
    let holidayName: String
    let nextResumeDescription: String

    public init(holidayName: String, nextResumeDescription: String) {
        self.holidayName = holidayName
        self.nextResumeDescription = nextResumeDescription
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.orange)
                    .font(.system(size: 13, weight: .semibold))

                Text("Chinese Public Holiday")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer()

                Text("All-Day Off-Peak")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.orange.opacity(0.18))
                    .foregroundColor(.orange)
                    .clipShape(Capsule())
            }

            Text(holidayName)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.primary)

            let resumeDetail = nextResumeDescription.replacingOccurrences(of: "Peak resumes: ", with: "")
            Text("DeepSeek peak hours are waived on statutory Chinese holidays. Normal peak schedule resumes \(resumeDetail).")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                )
        )
    }
}
