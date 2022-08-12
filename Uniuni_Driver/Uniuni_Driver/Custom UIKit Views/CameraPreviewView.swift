//
//  CameraPreviewView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-08-09.
//

import Foundation
import UIKit
import AVFoundation

class CameraPreviewView: UIView {
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected AVCaptureVideoPreviewLayer type for layer.")
        }
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return cameraPreviewLayer.session
        }
        set {
            cameraPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
