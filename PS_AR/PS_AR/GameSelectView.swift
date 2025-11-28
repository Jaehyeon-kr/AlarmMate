//
//  GameSelectView.swift
//  PS_AR
//
//  Created by 심재현 on 11/25/25.
//


import SwiftUI

struct GameSelectView: View {

    @Binding var selectedGame: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                gameRow("TapGame", label: "빠르게 버튼 누르기")
                gameRow("CarDodgeGame", label: "자동차 게임")
                gameRow("ColorMatch", label: "색 구분 게임")
                gameRow("MathGame", label: "산수 게임")
            }
            .navigationTitle("게임 선택")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") { dismiss() }
                }
            }
        }
    }

    func gameRow(_ id: String, label: String) -> some View {
        Button {
            selectedGame = id
        } label: {
            HStack {
                Text(label)
                Spacer()
                if selectedGame == id {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
