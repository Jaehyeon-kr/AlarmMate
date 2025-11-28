import SwiftUI

struct CarDodgeGameView: View {

    var onClear: (() -> Void)? = nil
    
    @State private var carX: CGFloat = 0
    @State private var obstacleY: CGFloat = -200
    @State private var obstacleX: CGFloat = 0
    @State private var avoidCount = 0
    @State private var goal = 7
    @State private var timer: Timer? = nil
    @State private var hasMoved = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()

            GeometryReader { geo in
                ZStack {

                    // 배경
                    Image("car_background")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
                        .clipped()

                    // 자동차
                    Image("car")
                        .resizable()
                        .frame(width: 80, height: 120)
                        .position(
                            x: geo.size.width/2 + carX,
                            y: geo.size.height - 140
                        )

                    // 장애물
                    Image("obstacle")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .position(
                            x: geo.size.width/2 + obstacleX,
                            y: obstacleY
                        )

                    // 회피 카운트 UI
                    VStack {
                        HStack {
                            Text("회피: \(avoidCount) / \(goal)")
                                .foregroundColor(.white)
                                .font(.title2.bold())
                                .padding(.top, 20)
                                .padding(.leading, 20)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }

            // 좌우 이동 버튼
            VStack {
                Spacer()
                HStack(spacing: 60) {
                    Button(action: {
                        moveCar(-60)
                        hasMoved = true
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    Button(action: {
                        moveCar(60)
                        hasMoved = true
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 40)
            }

        }
        .onAppear { startGameLoop() }
        .onDisappear { timer?.invalidate() }
    }

    // 자동차 이동 로직
    func moveCar(_ dx: CGFloat) {
        let newX = carX + dx
        let limit: CGFloat = 140
        if abs(newX) <= limit {
            carX = newX
        }
    }

    // 장애물 스폰(자동차 정면에서)
    func spawnObstacle() {
        obstacleY = -200
        obstacleX = carX       // ← ★ 항상 자동차 위치 기준
        hasMoved = false
    }

    // 메인 게임 루프
    func startGameLoop() {
        timer?.invalidate()

        spawnObstacle()

        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { t in
            obstacleY += 9

            let screenH = UIScreen.main.bounds.height

            // 🔥 충돌 판정 — 가만히 있으면 100% 충돌
            if abs(obstacleX - carX) < 50 && obstacleY > screenH - 300 {

                // ⭐ 충돌 → 회피 카운트 초기화 ⭐
                avoidCount = 0

                // 다시 시작
                spawnObstacle()
                return
            }

            // 🔥 회피 성공 판정
            if obstacleY > screenH {

                if hasMoved {
                    avoidCount += 1
                }

                // 7번 회피 완성 → 알람 종료
                if avoidCount >= goal {
                    t.invalidate()
                    onClear?()
                    return
                }

                // 다음 장애물 생성
                spawnObstacle()
            }
        }
    }
}
