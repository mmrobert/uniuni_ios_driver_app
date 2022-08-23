//
//  UIImage-Extension.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-18.
//

import Foundation
import UIKit

extension UIImage {
    static let delivery: UIImage? = UIImage(named: "icon-delivery")
    static let scan: UIImage? = UIImage(named: "icon-scan")
    static let dollar: UIImage? = UIImage(named: "icon-dollar")
    static let burger: UIImage? = UIImage(named: "icon-burger")
    static let route: UIImage? = UIImage(named: "icon-route")
    static let search: UIImage? = UIImage(named: "icon-search")
    static let sort: UIImage? = UIImage(named: "icon-sort")
    static let iconMedicalCross: UIImage? = UIImage(named: "icon-medical-cross")
    static let mapPinBlack: UIImage? = UIImage(named: "map-pin-black")
    static let mapPinOrange: UIImage? = UIImage(named: "map-pin-orange")
    static let mapPinRed: UIImage? = UIImage(named: "map-pin-red")
    static let mapServiceBlack: UIImage? = UIImage(named: "map-service-black")
    static let mapServiceOrange: UIImage? = UIImage(named: "map-service-orange")
    static let circledCheckmark: UIImage? = UIImage(named: "circled-checkmark")
    static let camera: UIImage? = UIImage(named: "icon-camera")
    static let iconBack: UIImage? = UIImage(named: "icon-back")
    static let cameraToggle: UIImage? = UIImage(named: "camera-toggle")
    static let cross: UIImage? = UIImage(named: "cross")
    static let flashAuto: UIImage? = UIImage(named: "flash-auto")
    static let flashLock: UIImage? = UIImage(named: "flash-lock")
    static let flashOpen: UIImage? = UIImage(named: "flash-open")
    static let gallary: UIImage? = UIImage(named: "gallary")
    static let cameraClick: UIImage? = UIImage(named: "camera-click")
    
    func compressImageTo(expectedSizeInMB: Double) -> UIImage? {
        
        let sizeInBytes = Int(expectedSizeInMB * 1024 * 1024)
        var compressingQuality: CGFloat = 1.0
        var needCompress:Bool = true
        guard var imageData = self.jpegData(compressionQuality: compressingQuality) else {
            return nil
        }
        while needCompress && compressingQuality > 0.0 {
            if let data = self.jpegData(compressionQuality: compressingQuality) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imageData = data
                } else {
                    compressingQuality -= 0.1
                }
            }
        }
        if (imageData.count < sizeInBytes) {
            return UIImage(data: imageData)
        } else {
            return nil
        }
    }
}
