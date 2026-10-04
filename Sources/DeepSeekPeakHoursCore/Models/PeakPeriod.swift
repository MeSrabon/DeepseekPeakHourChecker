import Foundation

public struct PeakPeriod: Identifiable, Sendable, Equatable {
    public var id: String { "\(start.timeIntervalSince1970)-\(end.timeIntervalSince1970)-\(status.rawValue)" }
    public let start: Date
    public let end: Date
    public let status: PeakStatus
    public let label: String

    public init(start: Date, end: Date, status: PeakStatus, label: String = "") {
        self.start = start
        self.end = end
        self.status = status
        self.label = label
    }

    public func contains(_ date: Date) -> Bool {
        date >= start && date < end
    }
}
