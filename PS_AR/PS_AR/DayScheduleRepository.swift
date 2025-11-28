import Foundation
import GRDB



final class DayScheduleRepository {

    static let shared = DayScheduleRepository()

    private var dbQueue: DatabaseQueue!

    private init() {
        do {
            let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dbURL = doc.appendingPathComponent("schedule.sqlite")

            dbQueue = try DatabaseQueue(path: dbURL.path)

            try dbQueue.write { db in
                try db.create(table: "daySchedule", ifNotExists: true) { t in
                    t.autoIncrementedPrimaryKey("id")
                    t.column("day", .text).notNull()
                    t.column("classTime", .text).notNull()
                    t.column("defaultAlarm", .text).notNull()
                    t.column("userAlarm", .text)
                }
            }

        } catch {
            print("❌ DayScheduleRepository init 실패:", error)
        }
    }
    func fetch(day: String) -> DaySchedule? {
        try? dbQueue.read { db in
            try DaySchedule
                .filter(Column("day") == day)
                .fetchOne(db)
        }
    }

    // 전체 삭제
    func deleteAll() {
        try? dbQueue.write { db in
            try DaySchedule.deleteAll(db)
        }
    }

    // 저장
    func insert(_ item: DaySchedule) {
        try? dbQueue.write { db in
            var row = item
            try row.insert(db)
        }
    }

    // 특정 요일 가져오기
    func fetchForDay(_ day: String) -> DaySchedule? {
        try? dbQueue.read { db in
            try DaySchedule.filter(Column("day") == day).fetchOne(db)
        }
    }

    // 유저 알람 수정
    func updateUserAlarm(day: String, newTime: String) {
        try? dbQueue.write { db in
            if var item = try DaySchedule.filter(Column("day") == day).fetchOne(db) {
                item.userAlarm = newTime
                try item.update(db)
            }
        }
    }
}
