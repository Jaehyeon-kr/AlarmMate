//
//  TimetableRepository.swift
//  PS_AR
//
//  Created by 심재현 on 11/29/25.
//


import GRDB

class TimetableRepository {
    static let shared = TimetableRepository()
    private init() {}

    private var db: DatabaseQueue { AppDatabase.shared.dbQueue }

    // 저장
    func insert(_ item: Timetable) {
        try? db.write { db in
            var copy = item
            try copy.insert(db)
        }
    }

    // 전체 불러오기
    func fetchAll() -> [Timetable] {
        (try? db.read { db in
            try Timetable.fetchAll(db)
        }) ?? []
    }

    // 요일별 가져오기
    func fetchForDay(_ day: String) -> [Timetable] {
        (try? db.read { db in
            try Timetable
                .filter(sql: "day = ?", arguments: [day])
                .fetchAll(db)
        }) ?? []
    }

    // 알람 수정 (유저가 바꾼 것)
    func updateUserAlarm(id: Int64, newTime: String) {
        try? db.write { db in
            if var item = try Timetable.fetchOne(db, key: id) {
                item.userAlarm = newTime
                try item.update(db)
            }
        }
    }

    // 삭제
    func deleteAll() {
        try? db.write { db in
            _ = try Timetable.deleteAll(db)
        }
    }
}
