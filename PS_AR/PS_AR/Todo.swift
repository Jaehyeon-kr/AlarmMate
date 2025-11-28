import Foundation
import GRDB

struct Todo: Codable, FetchableRecord, MutablePersistableRecord, Identifiable {
    var id: Int64?
    var title: String
    var isDone: Bool
    var createdAt: Date

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
