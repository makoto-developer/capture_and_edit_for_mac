import Foundation
import AppKit

struct HistoryItem: Identifiable, Comparable {
    let id: UUID
    let timestamp: Date
    let filePath: String

    init(timestamp: Date, filePath: String, id: UUID = UUID()) {
        self.id = id
        self.timestamp = timestamp
        self.filePath = filePath
    }

    var fileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        let dateString = formatter.string(from: timestamp)
        return "capture_\(dateString).png"
    }

    static func < (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        lhs.timestamp < rhs.timestamp
    }
}
