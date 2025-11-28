//
//  PS.swift
//  PS_AR
//
//  Created by 심재현 on 11/29/25.
//


import SwiftUI

@main
struct PS_ARApp: App {

    @StateObject var schemeManager = ColorSchemeManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(schemeManager)
                .preferredColorScheme(schemeManager.scheme)
        }
    }
}

