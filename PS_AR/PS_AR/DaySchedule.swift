import Foundation
import GRDB

struct DaySchedule: Codable, FetchableRecord, MutablePersistableRecord, Identifiable {
    var id: Int64?
    var day: String       // 월, 화, 수, ...
    var classTime: String // "09:00"
    var defaultAlarm: String
    var userAlarm: String?

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension DaySchedule {
    var finalAlarm: String {
        userAlarm ?? defaultAlarm
    }
}
