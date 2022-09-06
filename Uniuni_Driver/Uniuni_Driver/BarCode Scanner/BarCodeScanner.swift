//
//  BarCodeScanner.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-01.
//

import Foundation
import AVFoundation
import Combine

protocol BarCodeScannerProtocol: ObservableObject {
    var isSessionRunning: Bool { get }
    var hasCamera: Bool { get }
    var didGrantCameraPermission: Bool { get }
    var previewLayer: AVCaptureVideoPreviewLayer { get }
    var barCodeDetected: String? { get set }
    var codeScannerError: BarCodeScannerError? { get set }
    
    func startRunningCaptureSession()
    func stopRunningCaptureSession()
    func restartCaptureSession()
    func updateScannerRectOfInterest(to rect: CGRect)
}

class BarCodeScanner: NSObject, BarCodeScannerProtocol {
    
    public var isSessionRunning: Bool {
        return self.captureSession.isRunning
    }
    
    public var previewLayer: AVCaptureVideoPreviewLayer
    
    public var hasCamera: Bool {
        return AVCaptureDevice.default(for: .video) != nil
    }
    
    public var didGrantCameraPermission: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    private let metadataObjectTypes: [AVMetadataObject.ObjectType]
    private let captureSession: AVCaptureSession
    private let captureSessionQueue: DispatchQueue = DispatchQueue.init(label: "BarCodeScanner.avCaptureSessionQueue")
    private lazy var metadataProcessingQueue: DispatchQueue = {
        return .init(label: "BarCodeScanner.metadataOutputQueue")
    }()
    private weak var scannerMetadataOutput: AVCaptureMetadataOutput?
    
    @Published var barCodeDetected: String?
    @Published var codeScannerError: BarCodeScannerError?
    
    // MARK: - Initialization
    
    public init(metadataObjectTypes: [AVMetadataObject.ObjectType] = [.qr, .dataMatrix]) {
        self.captureSession = AVCaptureSession()
        self.captureSession.sessionPreset = .photo
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.metadataObjectTypes = metadataObjectTypes
    }
    
    // MARK: - Public
    
    public func startRunningCaptureSession() {
        self.requestCameraPermission { [weak self] result in
            guard let sSelf = self else { return }
            
            if case let .failure(error) = result {
                sSelf.codeScannerError = error as? BarCodeScannerError
                return
            }
            
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                sSelf.codeScannerError = BarCodeScannerError.unsupportedDevice
                return
            }
            
            // remove all inputs and outputs
            sSelf.captureSession.inputs.forEach { sSelf.captureSession.removeInput($0) }
            sSelf.captureSession.outputs.forEach { sSelf.captureSession.removeOutput($0) }
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
                guard sSelf.captureSession.canAddInput(videoInput) else {
                    sSelf.codeScannerError = BarCodeScannerError.canNotAddCaptureSessionInput
                    return
                }
                sSelf.captureSession.addInput(videoInput)
                
                let metadataOutput = AVCaptureMetadataOutput()
                
                guard sSelf.captureSession.canAddOutput(metadataOutput) else {
                    sSelf.codeScannerError = BarCodeScannerError.canNotAddCaptureSessionOutput
                    return
                }
                sSelf.captureSession.addOutput(metadataOutput)
                sSelf.scannerMetadataOutput = metadataOutput
                
                metadataOutput.setMetadataObjectsDelegate(sSelf, queue: sSelf.metadataProcessingQueue)
                metadataOutput.metadataObjectTypes = sSelf.metadataObjectTypes
                
                sSelf.captureSessionQueue.async { [weak self] in
                    self?.captureSession.startRunning()
                }
            } catch {
                sSelf.codeScannerError = BarCodeScannerError.unknown
            }
        }
    }
    
    public func stopRunningCaptureSession() {
        self.captureSessionQueue.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.captureSession.stopRunning()
        }
    }
    
    public func restartCaptureSession() {
        self.captureSessionQueue.async { [weak self] in
            guard let sSelf = self else { return }
            
            guard sSelf.captureSession.isRunning else {
                sSelf.startRunningCaptureSession()
                return
            }
            sSelf.captureSession.stopRunning()
            sSelf.captureSession.startRunning()
        }
    }
    
    public func updateScannerRectOfInterest(to rect: CGRect) {
        self.captureSessionQueue.async { [weak self] in
            guard let sSelf = self else { return }
            
            guard sSelf.isSessionRunning else { return }
            let newRect = sSelf.previewLayer.metadataOutputRectConverted(fromLayerRect: rect)
            sSelf.scannerMetadataOutput?.rectOfInterest = newRect
        }
    }
    
    // MARK: - Private
    
    private func requestCameraPermission(completion: @escaping (Result<Void, Error>) -> Void) {
        let completionOnMainQueue: (Result<Void, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        self.captureSessionQueue.async { [weak self] in
            guard let sSelf = self, sSelf.hasCamera else {
                completionOnMainQueue(.failure(BarCodeScannerError.noCamera))
                return
            }
            
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:
                completionOnMainQueue(.success(()))
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { success in
                    if success {
                        completionOnMainQueue(.success(()))
                    } else {
                        completionOnMainQueue(.failure(BarCodeScannerError.cameraAuthorizationDenied))
                    }
                }
            case .denied, .restricted:
                completionOnMainQueue(.failure(BarCodeScannerError.cameraAuthorizationDenied))
            @unknown default:
                print("⚠️ Camera permission request switch reached unknown case")
                completionOnMainQueue(.failure(BarCodeScannerError.unknown))
            }
        }
    }
}

extension BarCodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard let machineReadableCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = machineReadableCode.stringValue else {
            return
        }
        
        // vibrate
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        DispatchQueue.main.async { [weak self] in
            // notify observer
            self?.barCodeDetected = code
        }
    }
}

public enum BarCodeScannerError: Error {
    case unsupportedDevice
    case canNotAddCaptureSessionInput
    case canNotAddCaptureSessionOutput
    case noCamera
    case cameraAuthorizationDenied
    case unknown
}
