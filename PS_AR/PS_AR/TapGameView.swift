import SwiftUI

struct TapGameView: View {

    /// 🔥 게임 성공 시 알람 종료 콜백
    var onClear: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var count = 0
    @State private var timeLeft: Double = 5.0
    @State private var gameFinished = false

    var body: some View {
        VStack(spacing: 40) {

            Text("⚡ 빠르게 버튼 누르기")
                .font(.largeTitle.bold())

            Text("남은 시간: \(String(format: "%.1f", timeLeft))초")
                .font(.title2)

            Text("누른 횟수: \(count)")
                .font(.title.bold())

            // 메인 버튼
            Button(action: {
                if !gameFinished {
                    count += 1
                    if count >= 15 {
                        gameFinished = true
                    }
                }
            }) {
                Text("누르기")
                    .font(.largeTitle.bold())
                    .padding()
                    .frame(width: 200, height: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(100)
            }

            // 성공 UI
            if gameFinished {
                VStack(spacing: 20) {
                    Text("🎉 성공!")
                        .font(.largeTitle.bold())

                    Button("알람 끄기") {
                        onClear?()    // 🔥 HomeView에 알람 종료 알려줌
                        dismiss()     // sheet 닫힘
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.top, 30)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            startTimer()
        }
    }

    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard !gameFinished else {
                timer.invalidate()
                return
            }

            timeLeft -= 0.1

            if timeLeft <= 0 {
                timeLeft = 0
                timer.invalidate()
                // 실패 상태 → 게임을 다시 시작할지 말지 결정 가능
            }
        }
    }
}
