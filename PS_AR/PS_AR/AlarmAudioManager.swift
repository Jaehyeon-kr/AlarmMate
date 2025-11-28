//
//  AlarmAudioManager.swift
//  PS_AR
//
//  Created by 심재현 on 11/29/25.
//


import AVFoundation

class AlarmAudioManager: NSObject {
    static let shared = AlarmAudioManager()

    private var silentPlayer: AVAudioPlayer?
    private var alarmPlayer: AVAudioPlayer?

    func startSilentMode() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback,
                                    mode: .default,
                                    options: [.mixWithOthers])
            try session.setActive(true)

            guard let url = Bundle.main.url(forResource: "silent", withExtension: "wav") else {
                print("❌ silent.wav 파일 없음")
                return
            }

            silentPlayer = try AVAudioPlayer(contentsOf: url)
            silentPlayer?.numberOfLoops = -1
            silentPlayer?.volume = 0.0
            silentPlayer?.prepareToPlay()
            silentPlayer?.play()

            print("🔈 무음재생 시작됨 → 백그라운드 유지 OK")

        } catch {
            print("❌ 오류: \(error)")
        }
    }

    func stopSilentMode() {
        silentPlayer?.stop()
        silentPlayer = nil
    }

    func playAlarmSound() {
        do {
            guard let url = Bundle.main.url(forResource: "alarm", withExtension: "wav") else {
                print("❌ alarm.wav 없음")
                return
            }

            alarmPlayer = try AVAudioPlayer(contentsOf: url)
            alarmPlayer?.numberOfLoops = -1
            alarmPlayer?.volume = 1.0
            alarmPlayer?.play()

            print("⏰ 알람 재생 시작!")

        } catch {
            print("❌ 알람 재생 오류: \(error)")
        }
    }

    func stopAlarmSound() {
        alarmPlayer?.stop()
        alarmPlayer = nil
    }
}
