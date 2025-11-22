//import SwiftUI
//import CoreML
//import UIKit
//import Accelerate
//import CoreVideo
//import CoreGraphics
//
//// =========================================
//// MARK: - Image Picker (사진 선택)
//// =========================================
//struct ImagePicker: UIViewControllerRepresentable {
//    @Environment(\.dismiss) var dismiss
//    var sourceType: UIImagePickerController.SourceType = .photoLibrary
//    @Binding var selectedImage: UIImage?
//
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.sourceType = sourceType
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator { Coordinator(self) }
//
//    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//        let parent: ImagePicker
//        init(_ parent: ImagePicker) { self.parent = parent }
//
//        func imagePickerController(
//            _ picker: UIImagePickerController,
//            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
//        ) {
//            if let img = info[.originalImage] as? UIImage {
//                parent.selectedImage = img
//            }
//            parent.dismiss()
//        }
//    }
//}
//
//// =========================================
//// MARK: - Detection 구조체
//// =========================================
//struct Detection: Identifiable {
//    let id = UUID()
//    let classIndex: Int
//    let score: Float
//    let x: Float
//    let y: Float
//    let w: Float
//    let h: Float
//}
//
//extension Detection {
//    func toCGRect(imageWidth: CGFloat, imageHeight: CGFloat) -> CGRect {
//        let scaleX = imageWidth / 640
//        let scaleY = imageHeight / 640
//
//        return CGRect(
//            x: CGFloat(x - w/2) * scaleX,
//            y: CGFloat(y - h/2) * scaleY,
//            width: CGFloat(w) * scaleX,
//            height: CGFloat(h) * scaleY
//        )
//    }
//}
//
//// =========================================
//// MARK: - MAIN VIEW
//// =========================================
//import SwiftUI
//import CoreML
//import UserNotifications
//import UIKit
//
//struct ContentView: View {
//
//    @State private var detections: [Detection] = []
//    @State private var schedule: [String: Int?] = [:]
//
//    @State private var selectedImage: UIImage? = nil
//    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
//    @State private var showPicker = false
//
//    @State private var showAlarmSheet = false
//    @State private var selectedDay: String = "월"
//
//    let model = try! best1(configuration: MLModelConfiguration())
//
//    var body: some View {
//        VStack(spacing: 0) {
//
//            // ============================================
//            //   🔵 상단 배너 (다크모드 자동 반영)
//            // ============================================
//            HStack {
//                Image(systemName: "alarm")
//                    .font(.largeTitle)
//                    .foregroundColor(.blue)
//
//                VStack(alignment: .leading) {
//                    Text("자동 시간표 → 알람 생성기")
//                        .font(.title2).bold()
//                    Text("YOLO 기반 자동 분석")
//                        .font(.footnote)
//                        .foregroundColor(.secondary)
//                }
//                Spacer()
//            }
//            .padding()
//            .background(
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color(.secondarySystemBackground))
//                    .shadow(radius: 2)
//            )
//            .padding(.horizontal)
//            .padding(.top, 12)
//
//            Divider().padding(.vertical, 8)
//
//            // ============================================
//            //   이미지 영역
//            // ============================================
//            ZStack {
//                if let img = selectedImage {
//                    Image(uiImage: img)
//                        .resizable()
//                        .scaledToFit()
//                } else {
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(Color.gray.opacity(0.2))
//                        .overlay(Text("이미지를 선택하세요").foregroundColor(.secondary))
//                }
//
//                GeometryReader { geo in
//                    ForEach(detections) { det in
//                        let rect = det.toCGRect(
//                            imageWidth: geo.size.width,
//                            imageHeight: geo.size.height
//                        )
//                        Rectangle()
//                            .stroke(det.classIndex == 0 ? .green : .blue, lineWidth: 2)
//                            .frame(width: rect.width, height: rect.height)
//                            .position(x: rect.midX, y: rect.midY)
//                    }
//                }
//            }
//            .frame(height: 400)
//            .padding(.horizontal)
//
//            // ============================================
//            //   버튼 영역
//            // ============================================
//            HStack(spacing: 20) {
//
//                Button {
//                    pickerSource = .photoLibrary
//                    showPicker = true
//                } label: {
//                    Label("앨범", systemImage: "photo")
//                }
//
//                Button {
//                    pickerSource = .camera
//                    showPicker = true
//                } label: {
//                    Label("카메라", systemImage: "camera")
//                }
//            }
//            .buttonStyle(.borderedProminent)
//            .padding(.top, 8)
//
//            Button("🔍 시간표 분석하기") {
//                if let img = selectedImage {
//                    runYOLO(image: img)
//                }
//            }
//            .buttonStyle(.bordered)
//            .padding(.top, 4)
//
//            Divider().padding(.vertical, 8)
//
//            // ============================================
//            //   요일별 첫 수업
//            // ============================================
//            VStack(alignment: .leading) {
//                ForEach(["월","화","수","목","금"], id: \.self) { d in
//                    let t = schedule[d] ?? nil
//                    Text("• \(d)요일 → \(t == nil ? "수업 없음" : "\(t!)시")")
//                }
//            }
//            .padding(.horizontal)
//
//            // ============================================
//            //   알람 세팅 버튼
//            // ============================================
//            Button("⏰ 알람 설정하기") {
//                showAlarmSheet = true
//            }
//            .buttonStyle(.borderedProminent)
//            .padding(.vertical, 16)
//        }
//        .sheet(isPresented: $showPicker) {
//            ImagePicker(sourceType: pickerSource, selectedImage: $selectedImage)
//        }
//        .sheet(isPresented: $showAlarmSheet) {
//            AlarmSetupView(schedule: schedule)
//        }
//    }
//
//    // ========================================
//    // MARK: YOLO 실행
//    // ========================================
//    func runYOLO(image: UIImage) {
//        guard let resized = image.resizeTo(size: CGSize(width: 640, height: 640)),
//              let buffer = resized.toCVPixelBuffer()
//        else { return }
//
//        guard let output = try? model.prediction(image: buffer) else { return }
//
//        let arr = output.var_913
//        let dets = parseYOLOOutput(arr)
//        self.detections = dets
//        self.schedule = computeSchedule(from: dets)
//    }
//
//    // MARK: 시간표 해석 로직
//    // ========================================
//    func computeSchedule(from dets: [Detection]) -> [String: Int?] {
//
//        let timeBoxes = dets.filter { $0.classIndex == 1 }.sorted { $0.y < $1.y }
//        let TIME_LABELS = [9,10,11,12,1,2,3,4,5]
//
//        let classBoxes = dets.filter { $0.classIndex == 0 }
//        let dayWidth: Float = 640 / 5.0
//
//        func getDay(_ x: Float) -> Int {
//            min(4, max(0, Int(x / dayWidth)))
//        }
//
//        var dict: [Int:[Detection]] = [0:[],1:[],2:[],3:[],4:[]]
//        for c in classBoxes {
//            let d = getDay(c.x)
//            dict[d]?.append(c)
//        }
//
//        func nearestTime(_ y: Float) -> Int? {
//            guard !timeBoxes.isEmpty else { return nil }
//            let idx = timeBoxes.enumerated().min { abs($0.element.y - y) < abs($1.element.y - y) }?.offset
//            if let i = idx, i < TIME_LABELS.count { return TIME_LABELS[i] }
//            return nil
//        }
//
//        var result: [String: Int?] = [:]
//        let mapDay = ["월","화","수","목","금"]
//
//        for d in 0..<5 {
//            let times = dict[d]?.compactMap { nearestTime($0.y) } ?? []
//            result[mapDay[d]] = times.min()
//        }
//        return result
//    }
//}
//
//
//struct AlarmSetupView: View {
//
//    let schedule: [String: Int?]
//    @Environment(\.dismiss) var dismiss
//
//    @State private var selectedDay = "월"
//    @State private var recommendedTime = Date()
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("요일 선택")) {
//                    Picker("요일", selection: $selectedDay) {
//                        ForEach(["월","화","수","목","금"], id: \.self) { d in
//                            Text(d).tag(d)
//                        }
//                    }
//                    .pickerStyle(.segmented)
//                    .onChange(of: selectedDay) { _ in
//                        updateRecommendedTime()
//                    }
//                }
//
//                Section(header: Text("자동 추천 알람 시간")) {
//                    DatePicker("알람 시간", selection: $recommendedTime, displayedComponents: .hourAndMinute)
//                }
//
//                Button("⏰ 알람 등록하기") {
//                    registerLocalNotification()
//                    dismiss()
//                }
//            }
//            .navigationTitle("알람 설정")
//            .onAppear { updateRecommendedTime() }
//        }
//    }
//
//    func updateRecommendedTime() {
//        let start = schedule[selectedDay] ?? nil
//        let hour = start ?? 9
//        let alarmHour = max(hour - 1, 6)
//
//        var comp = Calendar.current.dateComponents([.year,.month,.day], from: Date())
//        comp.hour = alarmHour
//        comp.minute = 0
//        recommendedTime = Calendar.current.date(from: comp) ?? Date()
//    }
//
//    func registerLocalNotification() {
//        let content = UNMutableNotificationContent()
//        content.title = "수업 알람"
//        content.body = "\(selectedDay)요일 첫 수업 전 알람입니다."
//        content.sound = .default
//
//        let triggerDate = Calendar.current.dateComponents([.hour,.minute], from: recommendedTime)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
//
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request)
//    }
//}
//
//
//
//// =========================================
//// MARK: YOLO Output Parser
//// =========================================
//func parseYOLOOutput(_ mlArray: MLMultiArray) -> [Detection] {
//    let ptr = UnsafeMutablePointer<Float32>(OpaquePointer(mlArray.dataPointer))
//    var dets: [Detection] = []
//
//    let conf: Float = 0.40   // ← 적당히 낮춰서 감지 잘 되게
//
//    for i in 0..<8400 {
//        let x = ptr[i]
//        let y = ptr[8400 + i]
//        let w = ptr[16800 + i]
//        let h = ptr[25200 + i]
//        let score = ptr[33600 + i]
//        let cls = Int(ptr[42000 + i])
//
//        if score > conf {
//            dets.append(Detection(classIndex: cls, score: score, x: x, y: y, w: w, h: h))
//        }
//    }
//    return dets.sorted { $0.score > $1.score }
//}
//
//// =========================================
//// MARK: UIImage → PixelBuffer / Resize
//// =========================================
//extension UIImage {
//    func resizeTo(size: CGSize) -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
//        draw(in: CGRect(origin: .zero, size: size))
//        let result = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return result
//    }
//
//    func toCVPixelBuffer() -> CVPixelBuffer? {
//        let width = Int(size.width)
//        let height = Int(size.height)
//
//        let attrs: [String: Any] = [
//            kCVPixelBufferCGImageCompatibilityKey as String: true,
//            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
//        ]
//
//        var pb: CVPixelBuffer?
//        CVPixelBufferCreate(kCFAllocatorDefault, width, height,
//                            kCVPixelFormatType_32BGRA, attrs as CFDictionary, &pb)
//
//        guard let pixelBuffer = pb else { return nil }
//        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
//
//        let context = CGContext(
//            data: CVPixelBufferGetBaseAddress(pixelBuffer),
//            width: width,
//            height: height,
//            bitsPerComponent: 8,
//            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
//            space: CGColorSpaceCreateDeviceRGB(),
//            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
//        )
//
//        if let cg = self.cgImage {
//            context?.draw(cg, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
//        }
//        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
//        return pixelBuffer
//    }
//}
