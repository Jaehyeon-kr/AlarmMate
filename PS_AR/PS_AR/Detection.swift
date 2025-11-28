
//
//  Detection.swift
//  PS_AR
//
//  Created by 심재현 on 11/22/25.
//


import Foundation
import CoreML
import UIKit
import CoreVideo
import Accelerate

// ---------------------------------------------------------
// MARK: - Detection 구조체
// ---------------------------------------------------------
struct Detection: Identifiable {
    let id = UUID()
    let classIndex: Int   // 0 = CLASS, 1 = TIME
    let score: Float
    let xc: Float
    let yc: Float
    let w: Float
    let h: Float
}

extension Detection {
    /// 640x640 기준 YOLO 좌표 → SwiftUI 화면 좌표 변환
    func toCGRect(imageWidth: CGFloat, imageHeight: CGFloat) -> CGRect {
        let scaleX = imageWidth / 640
        let scaleY = imageHeight / 640
        
        return CGRect(
            x: CGFloat(xc - w/2) * scaleX,
            y: CGFloat(yc - h/2) * scaleY,
            width: CGFloat(w) * scaleX,
            height: CGFloat(h) * scaleY
        )
    }
}

// ---------------------------------------------------------
// MARK: - YOLOEngine
// ---------------------------------------------------------
class YOLOEngine {
    
    static let shared = YOLOEngine()
    private let model: best3
    
    private init() {
        model = try! best3(configuration: MLModelConfiguration())
    }
    
    // -----------------------------------------------------
    // MARK: - YOLO 실행
    // -----------------------------------------------------
    func runYOLO(image: UIImage) -> [Detection] {
        
        guard let resized = image.resizeTo(size: CGSize(width: 640, height: 640)),
              let pixelBuffer = resized.toCVPixelBuffer()
        else { return [] }
        
        guard let output = try? model.prediction(image: pixelBuffer) else {
            print("❌ 모델 예측 실패")
            return []
        }
        
        return parseYOLOOutput(output.var_1226)
    }
    
    
    // -----------------------------------------------------
    // MARK: - YOLO Output Parser
    // -----------------------------------------------------
    func parseYOLOOutput(_ mlArray: MLMultiArray) -> [Detection] {
        
        let ptr = UnsafeMutablePointer<Float32>(OpaquePointer(mlArray.dataPointer))
        var result: [Detection] = []
        
        let numAnchors = 8400
        let confTh: Float = 0.45
        
        for i in 0..<numAnchors {
            
            let x = ptr[i]
            let y = ptr[i + numAnchors]
            let w = ptr[i + numAnchors * 2]
            let h = ptr[i + numAnchors * 3]
            let conf = ptr[i + numAnchors * 4]
            let classIdx = Int(ptr[i + numAnchors * 5])   // ← 정확한 위치
            
            if conf > confTh {
                let det = Detection(
                    classIndex: classIdx,
                    score: conf,
                    xc: x, yc: y, w: w, h: h
                )
                result.append(det)
            }
        }
        
        return result.sorted { $0.score > $1.score }
    }
    
    
    // -----------------------------------------------------
    // MARK: - 시간표 해석
    // -----------------------------------------------------
    // -----------------------------------------------------
    // MARK: - 시간표 해석 (최신 버전)
    // -----------------------------------------------------
    func computeSchedule(
        from dets: [Detection],
        imageWidth: CGFloat = 640,
        imageHeight: CGFloat = 640
    ) -> [String: Int?] {
        
        let days = ["월","화","수","목","금"]
        
        // -----------------------------------
        // 1) 요일줄(dayline) 박스 (classIndex = 1)
        // -----------------------------------
        let daylineDet = dets.first(where: { $0.classIndex == 1 })
        
        let yDaylineBottom: CGFloat
        if let dayline = daylineDet {
            // YOLO 좌표 640기준 → 실제 이미지 y 변환
            yDaylineBottom = CGFloat(dayline.yc + dayline.h/2) * (imageHeight / 640)
        } else {
            // ⚠ 요일 박스 검출 실패 → fallback: 이미지 맨 위가 요일줄이라고 가정
            print("⚠ 요일 박스 없음 → 이미지 맨 위를 기준으로 사용")
            
            // 네 시간표 이미지 구조상 요일줄은 거의 최상단에 있음
            // 보통 y = 0~80 영역이 요일줄이므로,
            // 이미지 조건 통일을 위해 적당한 기본값을 정해주면 됨
            
            yDaylineBottom = 80    // ★ 여기 필요하면 조정 가능
        }

        // -----------------------------------
        // 2) 강의칸(classIndex = 0)
        // -----------------------------------
        let classBoxes = dets.filter { $0.classIndex == 0 }

        // -----------------------------------
        // 3) 요일 계산 = x축 5등분
        // -----------------------------------
        func estimateDay(xc: CGFloat) -> Int? {
            let LEFT_MARGIN: CGFloat = 120
            let numDays = 5
            let dayWidth = (imageWidth - LEFT_MARGIN) / CGFloat(numDays)
            
            let d = Int((xc - LEFT_MARGIN) / dayWidth)
            return (0..<numDays).contains(d) ? d : nil
        }

        // -----------------------------------
        // 4) 시간 계산 = 요일줄 아래 y-distance 기반
        // -----------------------------------
        func estimateTime(yc: CGFloat) -> Int {
            let timeHeight = imageHeight - yDaylineBottom
            var rel = (yc - yDaylineBottom) / timeHeight
            rel = min(max(rel, 0), 1)
            
            var idx = Int(round(rel * 8))  // 0~8
            
            // ⭐ 한 시간씩 밀림 보정
            idx -= 1
            
            idx = min(max(idx, 0), 8)
            return 9 + idx   // 9~17시
        }
        
        // -----------------------------------
        // 5) 요일별 첫 수업 찾기
        // -----------------------------------
        var daily: [Int: [Int]] = [0:[],1:[],2:[],3:[],4:[]]
        
        for c in classBoxes {
            let xcReal = CGFloat(c.xc) * (imageWidth / 640)
            let ycReal = CGFloat(c.yc) * (imageHeight / 640)
            
            if let day = estimateDay(xc: xcReal) {
                let t = estimateTime(yc: ycReal)
                daily[day]?.append(t)
            }
        }
        
        var result: [String: Int?] = [:]
        for d in 0..<5 {
            if let arr = daily[d], arr.count > 0 {
                result[days[d]] = arr.min()
            } else {
                result[days[d]] = nil
            }
        }
        
        return result
    }

}



// -----------------------------------------------------
// MARK: - UIImage Extensions
// -----------------------------------------------------
extension UIImage {

    func resizeTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        draw(in: CGRect(origin: .zero, size: size))
        let out = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return out
    }

    
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let width = Int(self.size.width)
        let height = Int(self.size.height)

        let attributes : [String:Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String : true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String : true
        ]

        var pb: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault,
                            width,
                            height,
                            kCVPixelFormatType_32BGRA,
                            attributes as CFDictionary,
                            &pb)

        guard let pixelBuffer = pb else { return nil }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )

        guard let cgImage = self.cgImage else { return nil }

        context?.draw(cgImage,
                      in: CGRect(x: 0, y: 0,
                                 width: width,
                                 height: height))

        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])

        return pixelBuffer
    }
}
