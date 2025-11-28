import SwiftUI

struct StairGameView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var steps: [Bool] = []
    @State private var currentIndex = 0
    @State private var isFinished = false

    let totalSteps = 10

    var body: some View {
        VStack(spacing: 25) {

            Text("🏃 계단 오르기")
                .font(.largeTitle.bold())

            Text("진행: \(currentIndex) / \(totalSteps)")
                .font(.headline)

            // 🔥 Crash 방지 조건: currentIndex < totalSteps 일 때만 출력
            if currentIndex < totalSteps {
                VStack {
                    Text(steps[currentIndex] ? "➡️" : "⬅️")
                        .font(.system(size: 80))
                    Text("이 방향으로 눌러!")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<currentIndex, id: \.self) { i in
                        HStack {
                            if steps[i] == false { Spacer() }
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 150, height: 20)
                                .cornerRadius(6)
                            if steps[i] == true { Spacer() }
                        }
                    }
                }
            }
            .frame(height: 260)

            HStack(spacing: 70) {
                Button("⬅️") { press(false) }
                    .font(.system(size: 50))

                Button("➡️") { press(true) }
                    .font(.system(size: 50))
            }

            if isFinished {
                VStack(spacing: 20) {
                    Text("🎉 성공!")
                        .font(.largeTitle.bold())

                    Button("알람 끄기") {
                        dismiss()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.top, 20)
            }

            Spacer()
        }
        .padding()
        .onAppear { generateSteps() }
    }

    func generateSteps() {
        steps = (0..<totalSteps).map { _ in Bool.random() }
    }

    func press(_ direction: Bool) {
        guard !isFinished else { return }

        if steps[currentIndex] == direction {
            currentIndex += 1

            if currentIndex == totalSteps {
                isFinished = true
            }

        } else {
            currentIndex = 0
        }
    }
}
