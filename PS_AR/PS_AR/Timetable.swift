//
//  Timetable.swift
//  PS_AR
//
//  Created by 심재현 on 11/29/25.
//


import GRDB

struct Timetable: Codable, FetchableRecord, MutablePersistableRecord, Identifiable {
    var id: Int64?
    var title: String
    var day: String
    var startTime: String
    var endTime: String
    var defaultAlarm: String
    var userAlarm: String?

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }

    var finalAlarm: String {
        userAlarm ?? defaultAlarm
    }
}
