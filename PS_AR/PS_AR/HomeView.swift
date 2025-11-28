import SwiftUI
import Foundation

import UserNotifications

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .sound, .badge]
    ) { granted, error in
        print("알림 권한: \(granted)")
        if let error = error {
            print("권한 오류: \(error)")
        }
    }
}

func scheduleTestNotification() {
    let content = UNMutableNotificationContent()
    content.title = "알람 테스트"
    content.body = "10초 알람이 정상 작동했습니다!"
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

    let request = UNNotificationRequest(
        identifier: "test_alarm_10_seconds",
        content: content,
        trigger: trigger
    )

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("알람 등록 실패: \(error)")
        } else {
            print("10초 후 알람 등록 완료!")
        }
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
    @State private var showAlarmList = false
    @State private var showGameSelector = false
    @Binding var selectedGame: String
    @Binding var todos: [String]
    @Binding var weeklyAlarms: [String: Date]   // ← 추가!!
    @State private var showTodoList = false
    
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
                    }

                    Button {
                        showGameSelector = true
                    } label: {
                        HStack {
                            Image(systemName: "gamecontroller")
                            Text("알람 게임 선택")
                        }
                        .font(.headline)
                    }
                    .sheet(isPresented: $showGameSelector) {
                        GameSelectView(selectedGame: $selectedGame)
                    }

                    Button {
                        showTodoList = true
                    } label: {
                        HStack {
                            Image(systemName: "checklist")
                            Text("할 일 목록")
                        }
                        .font(.headline)
                    }
                    .sheet(isPresented: $showTodoList) {
                        TodoListView(todos: $todos)
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

struct HomeView: View {

    @State private var selectedImage: UIImage?
    @State private var showPicker = false
    @State private var goAnalysis = false
    @State private var showMenu = false
    @State private var showAlarmEditor = false
    @State private var alarmTime: Date = Date()
    @State private var alarmIsRinging = false
    @AppStorage("selectedGame") var selectedGame: String = "TapGame"
    @State private var todos: [String] = []

    @EnvironmentObject var schemeManager: ColorSchemeManager

    @State private var showRinging = false   // ← 기존 것 유지
    @State private var showAlarmScreen = false  // ← ★ 추가됨 (오류 해결)


    @State private var weeklyAlarms: [String : Date] = [
        "월": stringToDate("08:00"),
        "화": stringToDate("08:00"),
        "수": stringToDate("08:00"),
        "목": stringToDate("08:00"),
        "금": stringToDate("08:00")
    ]

    func getTodayAlarm() -> Date {
        let repo = DayScheduleRepository.shared

        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        let en = formatter.string(from: Date())

        let day = [
            "Mon": "월", "Tue": "화", "Wed": "수",
            "Thu": "목", "Fri": "금"
        ][en] ?? "월"

        if let item = repo.fetch(day: day) {
            return stringToDate(item.finalAlarm)
        }
        return Date() // fallback
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
            "Fri": "금",
            "Sat": "토",
            "Sun": "일"
        ][en] ?? "월"
    }
    func toggleDarkMode() {
        withAnimation(.easeInOut) {
            if schemeManager.scheme == .dark {
                schemeManager.scheme = .light
            } else {
                schemeManager.scheme = .dark
            }
        }
    }

    @ViewBuilder
    func selectedGameView(onClear: @escaping () -> Void) -> some View {
        switch selectedGame {
        case "CarDodgeGame":
            CarDodgeGameView(onClear: onClear)

        case "ColorMatch":
            ColorMatchGameView(onClear: onClear)

        case "MathGame":
            MathGameView(onClear: onClear)

        default:
            TapGameView(onClear: onClear)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {

                Color(.systemBackground).ignoresSafeArea()

                SideMenu(
                    isOpen: $showMenu,
                    selectedGame: $selectedGame,
                    todos: $todos,
                    weeklyAlarms: $weeklyAlarms
                )
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
                        
                        Button("5초 뒤 알람") {
                            let date = Date().addingTimeInterval(5)
                            AlarmScheduler.shared.scheduleAlarm(for: date)
                        }

                    }

                    Spacer(minLength: 20)
                }
                .zIndex(1)

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
                // 🔥 오른쪽 하단 다크모드 버튼
  
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: toggleDarkMode) {
                            Image(systemName: schemeManager.scheme == .dark ? "sun.max.fill" : "moon.fill")
                                .font(.system(size: 20))           // ← 아이콘 크기 축소
                                .foregroundColor(.white)
                                .padding(10)                        // ← 버튼 전체 크기 줄임
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                        .padding(.trailing, 18)
                        .padding(.bottom, 32)
                    }
                }
                .ignoresSafeArea()

            }
            .sheet(isPresented: $showPicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showAlarmEditor) {
                AlarmEditView(
                    selectedTime: $alarmTime,
                    onSave: { newTime in
                        alarmTime = newTime

                        let today = getTodayKoreanDay()
                        weeklyAlarms[today] = newTime

                        // 🔥 알람 스케줄링 추가
                        AlarmScheduler.shared.scheduleAlarm(for: newTime)

                        print("🔔 오늘의 알람 스케줄 예약 완료 → \(newTime)")

                        showAlarmEditor = false
                    }
                )
            }
            .navigationDestination(isPresented: $goAnalysis) {
                if let img = selectedImage {
                    AnalysisView(
                        inputImage: img,
                        weeklyAlarms: $weeklyAlarms
                    )
                }
            }
        } .onAppear {
            AlarmAudioManager.shared.startSilentMode()
        }.onReceive(NotificationCenter.default.publisher(for: Notification.Name("AlarmDidFire"))) { _ in
            alarmIsRinging = true      // ← ★ 여기에 넣는 게 정답
        }
        .sheet(isPresented: $alarmIsRinging) {
            selectedGameView {
                alarmIsRinging = false
                AlarmAudioManager.shared.stopAlarmSound()
            }
        }


    }
}
