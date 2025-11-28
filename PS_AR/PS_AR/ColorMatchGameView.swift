import SwiftUI

struct ColorMatchGameView: View {

    /// 🔥 알람 성공 시 호출되는 콜백
    var onClear: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    let colors: [(name: String, color: Color)] = [
        ("RED", .red),
        ("GREEN", .green),
        ("BLUE", .blue),
        ("YELLOW", .yellow),
        ("PURPLE", .purple)
    ]

    @State private var currentText = "RED"
    @State private var currentColor: Color = .blue
    @State private var score = 0
    @State private var gameFinished = false

    var body: some View {
        VStack(spacing: 40) {
            Text("🎨 색 구분 게임")
                .font(.largeTitle.bold())

            Text("정답: \(score) / 5")
                .font(.title3)

            // 문제
            Text(currentText)
                .font(.system(size: 60).bold())
                .foregroundColor(currentColor)

            // 선택지 (일치 / 불일치)
            HStack(spacing: 40) {
                Button("일치") { checkAnswer(true) }
                    .font(.title)
                    .padding()
                    .frame(width: 120)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                Button("불일치") { checkAnswer(false) }
                    .font(.title)
                    .padding()
                    .frame(width: 120)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            if gameFinished {
                VStack(spacing: 20) {
                    Text("🎉 성공!")
                        .font(.largeTitle.bold())

                    Button("알람 끄기") {
                        onClear?()   // 🔥 HomeView에게 알람 종료 전달
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
        .onAppear {
            generateProblem()
        }
    }

    func generateProblem() {
        let random = colors.randomElement()!
        currentText = random.name
        currentColor = colors.randomElement()!.color
    }

    func checkAnswer(_ answer: Bool) {
        let isMatch = colors.first(where: {$0.name == currentText})!.color == currentColor

        if answer == isMatch {
            score += 1
            if score >= 5 {
                gameFinished = true
                return
            }
        }

        generateProblem()
    }
}
