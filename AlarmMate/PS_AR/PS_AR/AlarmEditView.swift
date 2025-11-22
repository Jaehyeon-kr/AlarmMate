import SwiftUI

struct AlarmEditView: View {
    @Binding var selectedTime: Date
    var onSave: (Date) -> Void       // ← 추가됨

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("알람 시간 변경")) {
                    DatePicker(
                        "알람 시간",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                }

                Button("저장") {
                    onSave(selectedTime)   // ← 저장 시 반드시 호출
                }
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("알람 설정")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
