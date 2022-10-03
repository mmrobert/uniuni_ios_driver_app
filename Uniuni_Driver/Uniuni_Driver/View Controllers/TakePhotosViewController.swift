//
//  TakePhotosViewController.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-08-10.
//

import Foundation
import UIKit
import AVFoundation
import CoreLocation
import Photos

protocol TakePhotosViewControllerNavigator: ObservableObject {
    var photoTaken: UIImage? { get set}
    var photos: [UIImage] { get set }
    var photoTakingFlow: PhotoTakingFlow { get set }
    func getPackageViewModel() -> PackageViewModel
    func presentTakePhotoViewController()
    func presentPhotoPickerViewController()
    func presentPhotoReviewViewController()
    func dismissPhotoTaking(animated: Bool, completion: (() -> Void)?)
    func dismissPhotoReview(animated: Bool, completion: (() -> Void)?)
    
}

class TakePhotosViewController<Navigator>: UIViewController, AVCapturePhotoCaptureDelegate where Navigator: TakePhotosViewControllerNavigator {
    
    enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    // Communicate with the session and other session objects on this queue
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    private var setupResult: SessionSetupResult = .success
    
    private lazy var topContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.cross, for: .normal)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = UIColor.white
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = String.firstPhotoStr
        return label
    }()
    
    private lazy var remindingLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.backgroundColor = UIColor.lightBlackText
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        label.numberOfLines = 1
        label.textAlignment = .center
        label.layer.cornerRadius = 18
        label.layer.masksToBounds = true
        label.padding(top: 0, bottom: 0, left: 20, right: 20)
        return label
    }()
    
    private lazy var flashButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.flashAuto, for: .normal)
        return button
    }()
    
    var previewView: CameraPreviewView = {
        let view = CameraPreviewView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var bottomContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var galleryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.gallary, for: .normal)
        return button
    }()
    
    private lazy var takePhotoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.cameraClick, for: .normal)
        return button
    }()
    
    private lazy var cameraToggleButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.cameraToggle, for: .normal)
        return button
    }()
    
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    private let photoOutput = AVCapturePhotoOutput()
    
    var windowOrientation: UIInterfaceOrientation {
        return view.window?.windowScene?.interfaceOrientation ?? .unknown
    }
    
    private var keyValueObservations = [NSKeyValueObservation]()
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInWideAngleCamera,
                      .builtInDualCamera,
                      .builtInTrueDepthCamera,
                      .builtInDualWideCamera],
        mediaType: .video,
        position: .unspecified
    )
    
    private var cameraFlashMode: CameraFlashMode = .auto
    
    private var photoImage: UIImage?
    
    private var navigator: Navigator
    
    init(navigator: Navigator) {
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupButtonActions()
        previewView.session = session
        previewView.cameraPreviewLayer.videoGravity = .resizeAspectFill
        
        self.checkCameraPermission()
        
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    private func setupButtonActions() {
        self.closeButton.addTarget(self, action: #selector(TakePhotosViewController.dismissSelf), for: .touchUpInside)
        self.takePhotoButton.addTarget(self, action: #selector(TakePhotosViewController.capturePhoto(_:)), for: .touchUpInside)
        self.cameraToggleButton.addTarget(self, action: #selector(TakePhotosViewController.changeCamera(_:)), for: .touchUpInside)
        self.flashButton.addTarget(self, action: #selector(TakePhotosViewController.changeFlash), for: .touchUpInside)
        self.galleryButton.addTarget(self, action: #selector(TakePhotosViewController.pickPhotoFromGallery), for: .touchUpInside)
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                } else {
                    self.setupResult = .success
                }
                self.sessionQueue.resume()
            })
        case .restricted:
            self.setupResult = .notAuthorized
        case .denied:
            self.setupResult = .notAuthorized
        case .authorized:
            self.setupResult = .success
        @unknown default:
            self.setupResult = .notAuthorized
        }
    }
    
    private func configureSession() {
        
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        do {
            var defaultVideoDevice: AVCaptureDevice?
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
                defaultVideoDevice = dualWideCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                defaultVideoDevice = frontCameraDevice
            }
            guard let videoDevice = defaultVideoDevice else {
                print("Default video device is unavailable.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                DispatchQueue.main.async {
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if self.windowOrientation != .unknown {
                        if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: self.windowOrientation) {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    self.previewView.cameraPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                }
            } else {
                print("Couldn't add video device input to the session.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Couldn't create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.maxPhotoQualityPrioritization = .quality
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        session.commitConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch self.navigator.photoTakingFlow {
        case .taking:
            if self.navigator.photos.count == 0 {
                self.titleLabel.text = String.firstPhotoStr
                let remindingText = NSMutableAttributedString(string: String.takeAPhotoOfTheParcelLabelStr)
                let range2 = (String.takeAPhotoOfTheParcelLabelStr as NSString).range(of: String.parcelLabelStr)
                remindingText.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightRed ?? UIColor.white], range: range2)
                self.remindingLabel.attributedText = remindingText
            } else {
                self.titleLabel.text = String.secondPhotoStr
                if navigator.getPackageViewModel().SG == 1 {
                    let remindingText = NSMutableAttributedString(string: String.takeAPhotoOfTheCustomersSignatureStr)
                    let range2 = (String.takeAPhotoOfTheCustomersSignatureStr as NSString).range(of: String.customersSignatureStr)
                    remindingText.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightRed ?? UIColor.white], range: range2)
                    self.remindingLabel.attributedText = remindingText
                } else {
                    self.remindingLabel.isHidden = true
                }
            }
        case .review(let index):
            if index == 0 {
                self.titleLabel.text = String.firstPhotoStr
                let remindingText = NSMutableAttributedString(string: String.takeAPhotoOfTheParcelLabelStr)
                let range2 = (String.takeAPhotoOfTheParcelLabelStr as NSString).range(of: String.parcelLabelStr)
                remindingText.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightRed ?? UIColor.white], range: range2)
                self.remindingLabel.attributedText = remindingText
            } else {
                self.titleLabel.text = String.secondPhotoStr
                if navigator.getPackageViewModel().SG == 1 {
                    let remindingText = NSMutableAttributedString(string: String.takeAPhotoOfTheCustomersSignatureStr)
                    let range2 = (String.takeAPhotoOfTheCustomersSignatureStr as NSString).range(of: String.customersSignatureStr)
                    remindingText.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightRed ?? UIColor.white], range: range2)
                    self.remindingLabel.attributedText = remindingText
                } else {
                    self.remindingLabel.isHidden = true
                }
            }
        }
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
            case .notAuthorized:
                DispatchQueue.main.async {
                    let positiveAction = Action(title: String.OKStr, handler: nil)
                    self.showAlert(title: nil, msg: String.AppHasNoPermissionToUseTheCameraStr, positiveAction: positiveAction, negativeAction: nil)
                }
            case .configurationFailed:
                DispatchQueue.main.async {
                    let positiveAction = Action(title: String.OKStr, handler: nil)
                    self.showAlert(title: nil, msg: String.unableToCaptureMediaStr, positiveAction: positiveAction, negativeAction: nil)
                }
            }
        }
    }
    
    private func addObservers() {
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            DispatchQueue.main.async {
                // Only enable the ability to change camera if the device has more than one camera.
                self.cameraToggleButton.isEnabled = isSessionRunning && self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
                self.takePhotoButton.isEnabled = isSessionRunning
                self.flashButton.isEnabled = isSessionRunning
            }
        }
        keyValueObservations.append(keyValueObservation)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(subjectAreaDidChange),
            name: .AVCaptureDeviceSubjectAreaDidChange,
            object: videoDeviceInput.device
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionRuntimeError),
            name: .AVCaptureSessionRuntimeError,
            object: session
        )
    }
    
    @objc
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    private func focus(with focusMode: AVCaptureDevice.FocusMode,
                       exposureMode: AVCaptureDevice.ExposureMode,
                       at devicePoint: CGPoint,
                       monitorSubjectAreaChange: Bool) {
        sessionQueue.async {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        print("Capture session runtime error: \(error)")
        // If media services were reset, and the last start succeeded, restart the session.
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        super.viewWillDisappear(animated)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let cameraPreviewLayerConnection = previewView.cameraPreviewLayer.connection {
            let deviceOrientation = UIDevice.current.orientation
            guard let newCameraOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation),
                deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
                    return
            }
            
            cameraPreviewLayerConnection.videoOrientation = newCameraOrientation
        }
    }
    
    @objc
    private func changeFlash() {
        self.cameraFlashMode = self.cameraFlashMode.nextMode()
        self.flashButton.setImage(self.cameraFlashMode.flashModeButtonImage(), for: .normal)
    }
    
    @objc
    private func changeCamera(_ cameraToggleButton: UIButton) {
        cameraToggleButton.isEnabled = false
        takePhotoButton.isEnabled = false
        
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position

            let backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera],
                mediaType: .video,
                position: .back
            )
            let frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera],
                mediaType: .video,
                position: .front
            )
            var newVideoDevice: AVCaptureDevice? = nil
            
            switch currentPosition {
            case .unspecified, .front:
                newVideoDevice = backVideoDeviceDiscoverySession.devices.first
            case .back:
                newVideoDevice = frontVideoDeviceDiscoverySession.devices.first
                
            @unknown default:
                print("Unknown capture position. Defaulting to back, dual-camera.")
                newVideoDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
            }
            
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    self.session.beginConfiguration()
                    
                    // Remove the existing device input first, because AVCaptureSession doesn't support
                    // simultaneous use of the rear and front cameras.
                    self.session.removeInput(self.videoDeviceInput)
                    
                    if self.session.canAddInput(videoDeviceInput) {
                        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                        NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
                        
                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.session.addInput(self.videoDeviceInput)
                    }
                    self.photoOutput.isHighResolutionCaptureEnabled = true
                    self.photoOutput.maxPhotoQualityPrioritization = .quality
                    self.session.commitConfiguration()
                } catch {
                    print("Error occurred while creating video device input: \(error)")
                }
            }
            
            DispatchQueue.main.async {
                self.cameraToggleButton.isEnabled = true
                self.takePhotoButton.isEnabled = true
            }
        }
    }
    
    @objc
    private func capturePhoto(_ takePhotoButton: UIButton) {
        
        let videoPreviewLayerOrientation = previewView.cameraPreviewLayer.connection?.videoOrientation
        
        sessionQueue.async {
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
            }
            var photoSettings = AVCapturePhotoSettings()
            
            // Capture HEIF photos when supported. Enable auto-flash and high-resolution photos.
            if  self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            
            if self.videoDeviceInput.device.isFlashAvailable {
                photoSettings.flashMode = self.cameraFlashMode.deviceFlashMode()
            }
            
            photoSettings.isHighResolutionPhotoEnabled = true
            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            
            photoSettings.photoQualityPrioritization = .quality
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    @objc
    private func pickPhotoFromGallery() {
        self.navigator.presentPhotoPickerViewController()
    }
    
    private func showAlert(title: String?, msg: String?, positiveAction: Action?, negativeAction: Action?) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)

        if positiveAction != nil {
            let positiveHandler: (UIAlertAction) -> Void = { alertAction in
                positiveAction?.handler?(alertAction.title)
            }
            alert.addAction(UIAlertAction(title: positiveAction?.title, style: .default, handler: positiveHandler))
        }
        
        if negativeAction != nil {
            let negativeHandler: (UIAlertAction) -> Void = { alertAction in
                negativeAction?.handler?(alertAction.title)
            }
            alert.addAction(UIAlertAction(title: negativeAction?.title, style: .cancel, handler: negativeHandler))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc
    private func dismissSelf() {
        self.dismiss(animated: true)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        if let error = error {
            print("Error capturing photo: \(error)")
            return
        } else {
            guard let data = photo.fileDataRepresentation() else {
                return
            }
            self.photoImage = UIImage(data: data)
            self.navigator.photoTaken = self.photoImage
            
            switch self.navigator.photoTakingFlow {
            case .taking:
                self.navigator.presentPhotoReviewViewController()
            case .review(_):
                self.navigator.dismissPhotoTaking(animated: true, completion: nil)
            }
        }
    }
    
    func updateTitle() {
        switch self.navigator.photoTakingFlow {
        case .taking:
            if self.navigator.photos.count == 0 {
                self.titleLabel.text = String.firstPhotoStr
                let remindingText = NSMutableAttributedString(string: String.takeAPhotoOfTheParcelLabelStr)
                let range2 = (String.takeAPhotoOfTheParcelLabelStr as NSString).range(of: String.parcelLabelStr)
                remindingText.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightRed ?? UIColor.white], range: range2)
                self.remindingLabel.attributedText = remindingText
            } else {
                self.titleLabel.text = String.secondPhotoStr
                if navigator.getPackageViewModel().SG == 1 {
                    let remindingText = NSMutableAttributedString(string: String.takeAPhotoOfTheCustomersSignatureStr)
                    let range2 = (String.takeAPhotoOfTheCustomersSignatureStr as NSString).range(of: String.customersSignatureStr)
                    remindingText.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightRed ?? UIColor.white], range: range2)
                    self.remindingLabel.attributedText = remindingText
                } else {
                    self.remindingLabel.isHidden = true
                }
            }
        case .review(let index):
            if index == 0 {
                self.titleLabel.text = String.firstPhotoStr
                let remindingText = NSMutableAttributedString(string: String.takeAPhotoOfTheParcelLabelStr)
                let range2 = (String.takeAPhotoOfTheParcelLabelStr as NSString).range(of: String.parcelLabelStr)
                remindingText.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightRed ?? UIColor.white], range: range2)
                self.remindingLabel.attributedText = remindingText
            } else {
                self.titleLabel.text = String.secondPhotoStr
                if navigator.getPackageViewModel().SG == 1 {
                    let remindingText = NSMutableAttributedString(string: String.takeAPhotoOfTheCustomersSignatureStr)
                    let range2 = (String.takeAPhotoOfTheCustomersSignatureStr as NSString).range(of: String.customersSignatureStr)
                    remindingText.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightRed ?? UIColor.white], range: range2)
                    self.remindingLabel.attributedText = remindingText
                } else {
                    self.remindingLabel.isHidden = true
                }
            }
        }
    }
    
    deinit {
        print("🍎 TakePhotosViewController - deinit")
    }
}

// setup UI
extension TakePhotosViewController {
    
    private func setupUI() {
        self.view.addSubview(topContainer)
        NSLayoutConstraint.activate(
            [topContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
             topContainer.topAnchor.constraint(equalTo: self.view.topAnchor),
             topContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
             topContainer.heightAnchor.constraint(equalToConstant: 114)]
        )
        self.view.addSubview(bottomContainer)
        NSLayoutConstraint.activate(
            [bottomContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
             bottomContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
             bottomContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
             bottomContainer.heightAnchor.constraint(equalToConstant: 140)]
        )
        
        self.view.addSubview(previewView)
        NSLayoutConstraint.activate(
            [previewView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
             previewView.topAnchor.constraint(equalTo: topContainer.bottomAnchor),
             previewView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
             previewView.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor)]
        )
        
        self.view.addSubview(self.remindingLabel)
        NSLayoutConstraint.activate(
            [remindingLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
             remindingLabel.heightAnchor.constraint(equalToConstant: 36),
             remindingLabel.bottomAnchor.constraint(equalTo: previewView.bottomAnchor, constant: -22)]
        )
        
        self.topContainer.addSubview(self.closeButton)
        self.topContainer.addSubview(self.titleLabel)
        self.topContainer.addSubview(self.flashButton)
        
        NSLayoutConstraint.activate(
            [closeButton.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 30),
             closeButton.widthAnchor.constraint(equalToConstant: 25),
             closeButton.heightAnchor.constraint(equalToConstant: 29),
             closeButton.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor, constant: 20)]
        )
        NSLayoutConstraint.activate(
            [titleLabel.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 10),
             titleLabel.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor, constant: 20)]
        )
        NSLayoutConstraint.activate(
            [flashButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
             flashButton.widthAnchor.constraint(equalToConstant: 25),
             flashButton.heightAnchor.constraint(equalToConstant: 29),
             flashButton.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor, constant: 20),
             flashButton.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: -30)]
        )
        
        self.bottomContainer.addSubview(self.galleryButton)
        self.bottomContainer.addSubview(self.takePhotoButton)
        self.bottomContainer.addSubview(self.cameraToggleButton)
        
        NSLayoutConstraint.activate(
            [galleryButton.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 22),
             galleryButton.widthAnchor.constraint(equalToConstant: 51),
             galleryButton.heightAnchor.constraint(equalToConstant: 43),
             galleryButton.centerYAnchor.constraint(equalTo: bottomContainer.centerYAnchor)]
        )
        NSLayoutConstraint.activate(
            [takePhotoButton.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
             takePhotoButton.centerYAnchor.constraint(equalTo: bottomContainer.centerYAnchor)]
        )
        NSLayoutConstraint.activate(
            [cameraToggleButton.widthAnchor.constraint(equalToConstant: 51),
             cameraToggleButton.heightAnchor.constraint(equalToConstant: 43),
             cameraToggleButton.centerYAnchor.constraint(equalTo: bottomContainer.centerYAnchor),
             cameraToggleButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -22)]
        )
    }
}

extension AVCaptureVideoOrientation {
    
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}

extension AVCaptureDevice.DiscoverySession {
    var uniqueDevicePositionsCount: Int {
        
        var uniqueDevicePositions = [AVCaptureDevice.Position]()
        
        for device in devices where !uniqueDevicePositions.contains(device.position) {
            uniqueDevicePositions.append(device.position)
        }
        
        return uniqueDevicePositions.count
    }
}

enum CameraFlashMode {
    case auto
    case on
    case off
    
    func nextMode() -> CameraFlashMode {
        switch self {
        case .auto:
            return .on
        case .on:
            return .off
        case .off:
            return .auto
        }
    }
    
    func flashModeButtonImage() -> UIImage? {
        switch self {
        case .auto:
            return UIImage.flashAuto
        case .on:
            return UIImage.flashOpen
        case .off:
            return UIImage.flashLock
        }
    }
    
    func deviceFlashMode() -> AVCaptureDevice.FlashMode {
        switch self {
        case .auto:
            return AVCaptureDevice.FlashMode.auto
        case .on:
            return AVCaptureDevice.FlashMode.on
        case .off:
            return AVCaptureDevice.FlashMode.off
        }
    }
}

enum PhotoTakingFlow {
    case taking
    case review(Int)
}
