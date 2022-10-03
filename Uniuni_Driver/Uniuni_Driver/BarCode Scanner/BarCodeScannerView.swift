//
//  BarCodeScannerView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-06.
//

import Foundation
import SwiftUI

struct BarCodeScannerView: UIViewRepresentable {
    
    typealias UIViewType = CameraView
    
    private var barCodeScanner: BarCodeScanner
    
    @Binding var focusViewHiden: Bool
    
    init(barCodeScanner: BarCodeScanner, focusViewHiden: Binding<Bool>) {
        self.barCodeScanner = barCodeScanner
        self._focusViewHiden = focusViewHiden
    }
    
    func makeUIView(context: UIViewRepresentableContext<BarCodeScannerView>) -> CameraView {
        let cameraView = CameraView(barCodeScanner: self.barCodeScanner)
        return cameraView
    }
    
    func updateUIView(_ uiView: CameraView, context: UIViewRepresentableContext<BarCodeScannerView>) {
        if focusViewHiden {
            uiView.updateView(focusHiden: true)
        } else {
            uiView.updateView(focusHiden: false)
        }
    }
    
    static func dismantleUIView(_ uiView: CameraView, coordinator: ()) {
        uiView.stopSessionRunning()
    }
}
