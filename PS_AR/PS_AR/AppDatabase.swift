import Foundation
import GRDB

class AppDatabase {
    static let shared = AppDatabase()
    let dbQueue: DatabaseQueue

    private init() {
        let fileManager = FileManager.default
        
        // 앱 내 문서폴더에 DB 생성
        let folderURL = try! fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dbURL = folderURL.appendingPathComponent("schedule.sqlite")

        dbQueue = try! DatabaseQueue(path: dbURL.path)

        // 테이블 생성
        try! dbQueue.write { db in
            try db.create(table: "daySchedule", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("day", .text).notNull()
                t.column("classTime", .text).notNull()
                t.column("defaultAlarm", .text).notNull()
                t.column("userAlarm", .text)
            }
        }
    }
}
