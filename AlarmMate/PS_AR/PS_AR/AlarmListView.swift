import SwiftUI

struct AlarmListView: View {
    @Binding var weeklyAlarms: [String : Date]
    let days = ["월","화","수","목","금"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("요일별 알람 시간")) {
                    ForEach(days, id: \.self) { day in
                        HStack {
                            Text(day)
                            Spacer()
                            
                            DatePicker(
                                "",
                                selection: Binding(
                                    get: { weeklyAlarms[day] ?? Date() },
                                    set: { weeklyAlarms[day] = $0 }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                        }
                    }
                }
            }
            .navigationTitle("요일별 알람")
        }
    }
}
