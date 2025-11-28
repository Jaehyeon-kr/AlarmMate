import Foundation
import GRDB

final class TodoRepository {

    static let shared = TodoRepository()

    private var dbQueue: DatabaseQueue!

    private init() {
        do {
            let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dbURL = doc.appendingPathComponent("todos.sqlite")

            dbQueue = try DatabaseQueue(path: dbURL.path)

            try dbQueue.write { db in
                try db.create(table: "todos", ifNotExists: true) { t in
                    t.autoIncrementedPrimaryKey("id")
                    t.column("title", .text).notNull()
                    t.column("isDone", .boolean).notNull().defaults(to: false)
                    t.column("createdAt", .date).notNull()
                }
            }

        } catch {
            print("❌ TodoRepository init 실패:", error)
        }
    }

    // CREATE
    func insert(title: String) {
        try? dbQueue.write { db in
            var item = Todo(id: nil, title: title, isDone: false, createdAt: Date())
            try item.insert(db)
        }
    }

    // READ
    func fetchAll() -> [Todo] {
        (try? dbQueue.read { db in
            try Todo.order(Column("createdAt").desc).fetchAll(db)
        }) ?? []
    }

    // UPDATE
    func toggleDone(id: Int64) {
        try? dbQueue.write { db in
            if var item = try Todo.filter(key: id).fetchOne(db) {
                item.isDone.toggle()
                try item.update(db)
            }
        }
    }

    // DELETE
    func delete(id: Int64) {
        try? dbQueue.write { db in
            _ = try Todo.deleteOne(db, key: id)
        }
    }
}
