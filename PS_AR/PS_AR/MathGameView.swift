import SwiftUI

struct MathGameView: View {

    /// 🔥 게임 성공 시 알람 종료 콜백
    var onClear: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    @State private var question = ""
    @State private var answer = 0
    @State private var choices: [Int] = []
    @State private var score = 0
    @State private var gameFinished = false

    var body: some View {
        VStack(spacing: 40) {

            Text("🧮 계산 게임")
                .font(.largeTitle.bold())

            Text("간단한 계산 문제를 풀고 5개 맞추세요!")
                .font(.callout)
                .foregroundColor(.gray)

            Text("정답: \(score) / 5")
                .font(.title3)

            // 문제
            Text(question)
                .font(.system(size: 60).bold())

            // 선택지
            VStack(spacing: 20) {
                ForEach(choices, id: \.self) { c in
                    Button(action: {
                        checkAnswer(c)
                    }) {
                        Text("\(c)")
                            .font(.title.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }

            // 성공 UI
            if gameFinished {
                VStack(spacing: 20) {
                    Text("🎉 성공!")
                        .font(.largeTitle.bold())

                    Button("알람 끄기") {
                        onClear?()    // 🔥 HomeView에게 “알람 종료해!” 신호 전달
                        dismiss()     // sheet 닫힘
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
            generateQuestion()
        }
    }

    // MARK: - 문제 생성
    func generateQuestion() {
        let a = Int.random(in: 1...20)
        let b = Int.random(in: 1...20)
        let op = ["+", "-", "×"].randomElement()!

        switch op {
        case "+":
            answer = a + b
        case "-":
            answer = a - b
        default:
            answer = a * b
        }

        question = "\(a) \(op) \(b)"

        var list = [answer]
        while list.count < 4 {
            let r = Int.random(in: answer-10...answer+10)
            if r != answer {
                list.append(r)
            }
        }

        choices = list.shuffled()
    }

    // MARK: - 정답 체크
    func checkAnswer(_ c: Int) {
        if c == answer {
            score += 1
            if score >= 5 {
                gameFinished = true
                return
            }
        }
        
        generateQuestion()
    }
}
