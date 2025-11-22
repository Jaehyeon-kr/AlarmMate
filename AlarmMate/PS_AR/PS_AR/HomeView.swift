import SwiftUI

import Foundation

/// "08:00" → Date
func stringToDate(_ timeString: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.date(from: timeString) ?? Date()
}

/// Date → "08:00"
func dateToString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}

struct SideMenu: View {
    @Binding var isOpen: Bool
    @Binding var weeklyAlarms: [String : Date]
    @State private var showAlarmList = false

    var body: some View {
        ZStack(alignment: .leading) {
            if isOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { isOpen = false } }

                VStack(alignment: .leading, spacing: 22) {
                    Text("Settings")
                        .font(.title2.bold())
                        .padding(.top, 40)

                    Button("Light Mode") {
                        UserDefaults.standard.set("light", forKey: "colorScheme")
                    }
                    Button("Dark Mode") {
                        UserDefaults.standard.set("dark", forKey: "colorScheme")
                    }
                    Button("System Default") {
                        UserDefaults.standard.set("system", forKey: "colorScheme")
                    }

                    Divider().padding(.vertical, 10)

                    Button {
                        showAlarmList = true
                    } label: {
                        HStack {
                            Image(systemName: "alarm")
                            Text("요일별 알람 보기")
                        }
                        .font(.headline)
                    }
                    .sheet(isPresented: $showAlarmList) {
                        AlarmListView(weeklyAlarms: $weeklyAlarms)
                            .id(UUID())
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(width: 260)
                .frame(maxHeight: .infinity)
                .background(Color(.secondarySystemBackground))
                .transition(.move(edge: .leading))
                .shadow(radius: 6)
            }
        }
        .animation(.easeInOut, value: isOpen)
    }
}

struct TopRightBanner: View {
    var time: Date
    var onTap: () -> Void

    var body: some View {
        Button(action: { onTap() }) {
            VStack(alignment: .trailing, spacing: 2) {
                Text("⏰ Today Alarm")
                    .font(.caption)
                    .foregroundColor(.white)

                Text(timeString(time))
                    .font(.headline.bold())
                    .foregroundColor(.white)
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .shadow(radius: 3)
        }
        .buttonStyle(.plain)
        .padding(.trailing, 16)
        .padding(.top, 16)
    }

    func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}

struct HomeView: View {

    @State private var selectedImage: UIImage?
    @State private var showPicker = false
    @State private var goAnalysis = false
    @State private var showMenu = false
    @State private var showAlarmEditor = false
    @State private var alarmTime: Date = Date()
    @State private var alarmIsRinging = false

    @State private var weeklyAlarms: [String : Date] = [
        "월": stringToDate("08:00"),
        "화": stringToDate("08:00"),
        "수": stringToDate("08:00"),
        "목": stringToDate("08:00"),
        "금": stringToDate("08:00")
    ]

    func getTodayAlarm() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"

        let today = formatter.string(from: Date())

        let mapping = [
            "Mon": "월",
            "Tue": "화",
            "Wed": "수",
            "Thu": "목",
            "Fri": "금"
        ]

        if let kor = mapping[today] {
            return weeklyAlarms[kor] ?? Date()
        }
        return Date()
    }

    func getTodayKoreanDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"

        let en = formatter.string(from: Date())

        return [
            "Mon": "월",
            "Tue": "화",
            "Wed": "수",
            "Thu": "목",
            "Fri": "금"
        ][en] ?? "월"
    }

    var body: some View {
        NavigationStack {
            ZStack {

                Color(.systemBackground).ignoresSafeArea()

                SideMenu(isOpen: $showMenu, weeklyAlarms: $weeklyAlarms)
                    .zIndex(50)

                VStack(spacing: 24) {

                    VStack(spacing: 6) {
                        Text("Put your TimeTable.")
                            .font(.largeTitle.bold())
                        Text("Auto Scheduling Alarm")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 120)

                    Group {
                        if let img = selectedImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(radius: 4)
                        } else {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.secondary.opacity(0.15))
                                .frame(height: 300)
                                .overlay(
                                    VStack {
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(.secondary)
                                        Text("Choose your timetable photo")
                                            .foregroundColor(.secondary)
                                    }
                                )
                                .padding(.horizontal)
                        }
                    }

                    VStack(spacing: 16) {
                        Button {
                            showPicker = true
                        } label: {
                            Label("Select Photo", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        Button {
                            if selectedImage != nil { goAnalysis = true }
                        } label: {
                            Label("AI Auto Scheduling", systemImage: "bolt.circle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedImage == nil ? Color.gray : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(selectedImage == nil)
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 20)
                }
                .zIndex(1)

                VStack {
                    Spacer()

                    Button("알람 테스트 화면 띄우기") {
                        alarmIsRinging = true
                    }
                    .font(.headline)
                    .padding()
                }

                VStack {
                    HStack {
                        Button {
                            withAnimation { showMenu.toggle() }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 26))
                                .padding(12)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .zIndex(100)

                VStack {
                    HStack {
                        Spacer()
                        TopRightBanner(time: getTodayAlarm()) {
                            showAlarmEditor = true
                        }
                    }
                    Spacer()
                }
                .zIndex(100)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Menu {
                            Button("Light") {
                                UserDefaults.standard.set("light", forKey: "colorScheme")
                            }
                            Button("Dark") {
                                UserDefaults.standard.set("dark", forKey: "colorScheme")
                            }
                            Button("System Default") {
                                UserDefaults.standard.set("system", forKey: "colorScheme")
                            }
                        } label: {
                            Image(systemName: "circle.lefthalf.filled")
                                .font(.system(size: 22))
                                .foregroundColor(.primary)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
                .zIndex(100)

            }
            .sheet(isPresented: $showPicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $alarmIsRinging) {
                AlarmRingingView()
            }
            .sheet(isPresented: $showAlarmEditor) {
                AlarmEditView(
                    selectedTime: $alarmTime,
                    onSave: { newTime in
                        alarmTime = newTime

                        let today = getTodayKoreanDay()
                        weeklyAlarms[today] = newTime

                        showAlarmEditor = false
                    }
                )
            }
            .navigationDestination(isPresented: $goAnalysis) {
                if let img = selectedImage {
                    AnalysisView(
                        inputImage: img,
                        weeklyAlarms: $weeklyAlarms   // ← 여기가 핵심!!
                    )
                }
            }
        }
    }
}
