//
//  TimetableAlarmApp.swift
//  PS_AR
//
//  Created by 심재현 on 11/22/25.
//


import SwiftUI


struct TimetableApp: App {

    @AppStorage("colorScheme") private var colorScheme: String = "system"

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(
                    colorScheme == "system" ? nil :
                    (colorScheme == "dark" ? .dark : .light)
                )
        }
    }
}
