//
//  AlarmScheduler.swift
//  PS_AR
//
//  Created by 심재현 on 11/29/25.
//


import Foundation
import BackgroundTasks

class AlarmScheduler: ObservableObject {

    static let shared = AlarmScheduler()

    private var timer: Timer?
    private var targetTime: Date?

    func scheduleAlarm(for date: Date) {
        targetTime = date
        startTimer()
        AlarmAudioManager.shared.startSilentMode() // 무음 재생 시작
        print("⏰ 알람 예약: \(date)")
    }

    private func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard let target = self.targetTime else { return }
            if Date() >= target {
                self.triggerAlarm()
            }
        }

        RunLoop.current.add(timer!, forMode: .common)
    }

    private func triggerAlarm() {
        print("🚨 알람 트리거됨!")

        timer?.invalidate()
        timer = nil
        AlarmAudioManager.shared.stopSilentMode()
        AlarmAudioManager.shared.playAlarmSound()

        NotificationCenter.default.post(name: NSNotification.Name("AlarmDidFire"), object: nil)
    }
}
