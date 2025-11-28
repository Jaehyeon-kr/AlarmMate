import SwiftUI
import AVFoundation

struct AlarmRingingView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Text("⏰ 알람 울림!")
                .font(.largeTitle.bold())

            Button {
                // 1) 알람 사운드 정지
                AlarmAudioManager.shared.stopAlarmSound()

                // 2) 화면 닫기
                dismiss()
            } label: {
                Text("알람 종료")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }
}
