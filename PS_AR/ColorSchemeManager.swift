//
//  ColorSchemeManager.swift
//  PS_AR
//
//  Created by 심재현 on 11/29/25.
//


import SwiftUI

class ColorSchemeManager: ObservableObject {
    @Published var scheme: ColorScheme? = nil   // light, dark, nil(시스템)
}