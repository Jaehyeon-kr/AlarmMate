//
//  SplashView.swift
//  PS_AR
//
//  Created by 심재현 on 11/22/25.
//


import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 16) {
                Text("📅 Timetable Alarm")
                    .font(.largeTitle)
                    .foregroundColor(.white)

                ProgressView()
                    .tint(.white)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            HomeView()
        }
    }
}
