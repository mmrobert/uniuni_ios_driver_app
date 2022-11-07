//
//  FailedDeliveryNavigator.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-08-21.
//

import Foundation
import UIKit
import Combine
import SwiftUI
import PhotosUI
import MapKit

class FailedDeliveryNavigator: NSObject, TakePhotosViewControllerNavigator {
    
    private struct Constants {
        static let bizMsgSuccess = "DELIVERY.SUBMIT.SUCCESS"
        static let bizMsgRetrySuccess = "DELIVERY.RETRY.SUCCESS"
    }
    
    private var packageViewModel: PackageViewModel
    private var failedReason: FailedReasonDelivery
    
    private weak var presenter: UIViewController?
    
    private weak var failedDetailViewController: UIViewController?
    private var photoTakingViewController: UIViewController?
    private var photoReviewHostViewController: UIViewController?
    
    @Published var photos: [UIImage] = []
    @Published var photoTaken: UIImage?
    @Published var photoTakingFlow: PhotoTakingFlow = .taking
    
    private var disposables = Set<AnyCancellable>()
    
    @Published var showingBackground = false
    @Published var showingProgressView: Bool = false
    @Published var showingSuccessfulAlert: Bool = false
    @Published var showingNetworkErrorAlert: Bool = false
    @Published var showingSaveErrorAlert: Bool = false
    
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation = CLLocation(latitude: 49.14, longitude: -122.98)
    
    init(presenter: UIViewController?, packageViewModel: PackageViewModel, failedReason: FailedReasonDelivery, currentLocation: CLLocation? = nil) {
        self.presenter = presenter
        self.packageViewModel = packageViewModel
        self.failedReason = failedReason
        self.currentLocation = currentLocation ?? CLLocation(latitude: 49.14, longitude: -122.98)
        super.init()
        self.locationManager.delegate = self
        self.startLocationManager()
        CoreDataManager.shared.$saveFailedUploadedError
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] error in
                guard let strongSelf = self else { return }
                if let err = error {
                    switch err {
                    case .saveFailedUploaded:
                        strongSelf.showingBackground = true
                        strongSelf.showingSaveErrorAlert = true
                    case .fetch:
                        break
                    }
                } else {
                    strongSelf.back()
                }
            })
            .store(in: &disposables)
    }
    
    private func startLocationManager() {
        let authStatus = locationManager.authorizationStatus
        if authStatus == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
    }
    
    func getPackageViewModel() -> PackageViewModel {
        self.packageViewModel
    }
    
    func getFailedReason() -> FailedReasonDelivery {
        self.failedReason
    }
    
    func presentFailedDetail() {
        let contentView = FailedPackageDetailView(navigator: self)
        let host = UIHostingController(rootView: contentView)
        self.failedDetailViewController = host
        self.presenter?.present(host, animated: true)
    }
    
    func startPhotoTakingFlow() {
        self.photoTakingFlow = .taking
        self.presentTakePhotoViewController()
    }
    
    func startPhotoReviewFlow(index: Int) {
        self.photoTakingFlow = .review(index)
        self.photoTaken = self.photos[index]
        self.presentPhotoReviewViewController()
    }
    
    func presentTakePhotoViewController() {
        let takePhoto = TakePhotosViewController(navigator: self)
        self.photoTakingViewController = takePhoto
        takePhoto.modalPresentationStyle = .fullScreen
        takePhoto.modalTransitionStyle = .crossDissolve
        
        switch self.photoTakingFlow {
        case .taking:
            self.failedDetailViewController?.present(takePhoto, animated: true)
        case .review(_):
            self.photoReviewHostViewController?.present(takePhoto, animated: true)
        }
    }
    
    func presentPhotoReviewViewController() {
        let contentView = PhotoReviewView(navigator: self)
        let host = UIHostingController(rootView: contentView)
        self.photoReviewHostViewController = host
        host.modalPresentationStyle = .fullScreen
        host.modalTransitionStyle = .crossDissolve
        
        switch self.photoTakingFlow {
        case .taking:
            self.photoTakingViewController?.present(host, animated: true)
        case .review(_):
            self.failedDetailViewController?.present(host, animated: true)
        }
    }
    
    func presentPhotoPickerViewController() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        switch self.photoTakingFlow {
        case .taking:
            
            switch failedReason {
            case .redelivery:
                configuration.selectionLimit = 1 - self.photos.count
            case .failedContactCustomer:
                configuration.selectionLimit = 2 - self.photos.count
            case .wrongAddress, .poBox:
                break
            }
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.photoTakingViewController?.present(picker, animated: true)
        case .review(_):
            configuration.selectionLimit = 1
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.photoTakingViewController?.present(picker, animated: true)
        }
    }
    
    func failedDelivery() {
        
        guard let orderID = self.packageViewModel.order_id else {
            return
        }
        var podImages: [Data]? = nil
        var failed: Int? = nil
        switch self.failedReason {
        case .redelivery:
            break
        case .failedContactCustomer:
            failed = 1
            podImages = self.photos.compactMap {
                $0.compressImageTo(expectedSizeInMB: 0.14)?.jpegData(compressionQuality: 1)
            }
        case .wrongAddress:
            failed = 2
        case .poBox:
            failed = 3
        }
        NetworkService.shared.completeDelivery(orderID: orderID, deliveryResult: 1, podImages: podImages, failedReason: failed, longitude: self.currentLocation.coordinate.longitude, latitude: self.currentLocation.coordinate.latitude)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                guard let strongSelf = self else { return }
                switch value {
                case .failure(let error):
                    switch error {
                    case .invalidURL( _):
                        self?.showingNetworkErrorAlert = true
                    case .netConnection( _):
                        self?.showingNetworkErrorAlert = true
                    case .failStatusCode( _):
                        self?.showingNetworkErrorAlert = true
                    default:
                        break
                    }
                    strongSelf.showingProgressView = false
                case .finished:
                    strongSelf.showingProgressView = false
                }
            }, receiveValue: { [weak self] response in
                guard let strongSelf = self else { return }
                if response.biz_code?.lowercased() == Constants.bizMsgSuccess.lowercased() {
                    strongSelf.showingSuccessfulAlert = true
                } else {
                    strongSelf.showingSuccessfulAlert = false
                    strongSelf.showingNetworkErrorAlert = true
                }
                strongSelf.showingProgressView = false
            })
            .store(in: &disposables)
    }
    
    func failedReDeliveryTry() {
        guard let orderID = self.packageViewModel.order_id else {
            return
        }
        let lat = self.currentLocation.coordinate.latitude
        let lng = self.currentLocation.coordinate.longitude
        let podImages = self.photos.compactMap {
            $0.compressImageTo(expectedSizeInMB: 0.14)?.jpegData(compressionQuality: 1)
        }
        NetworkService.shared.reDeliveryTry(driverID: AppConfigurator.shared.driverID, orderID: orderID, latitude: lat, longitude: lng, podImages: podImages)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                guard let strongSelf = self else { return }
                switch value {
                case .failure(let error):
                    switch error {
                    case .invalidURL( _):
                        self?.showingNetworkErrorAlert = true
                    case .netConnection( _):
                        self?.showingNetworkErrorAlert = true
                    case .failStatusCode( _):
                        self?.showingNetworkErrorAlert = true
                    default:
                        break
                    }
                    strongSelf.showingProgressView = false
                case .finished:
                    strongSelf.showingProgressView = false
                }
            }, receiveValue: { [weak self] response in
                guard let strongSelf = self else { return }
                if response.biz_code?.lowercased() == Constants.bizMsgRetrySuccess.lowercased() {
                    strongSelf.showingSuccessfulAlert = true
                } else {
                    strongSelf.showingSuccessfulAlert = false
                    strongSelf.showingNetworkErrorAlert = true
                }
                strongSelf.showingProgressView = false
            })
            .store(in: &disposables)
    }
    
    func saveFailedUploadedToCoreData() {
        guard let orderID = self.packageViewModel.order_id else {
            return
        }
        let podImages = self.photos.compactMap {
            $0.compressImageTo(expectedSizeInMB: 0.14)?.jpegData(compressionQuality: 1)
        }
        CoreDataManager.shared.saveFailedUploaded(orderID: orderID, deliveryResult: 0, podImages: podImages, failedReason: nil)
    }
    
    func back() {
        self.failedDetailViewController?.dismiss(animated: true)
    }
    
    func backToDeliveryList() {
        self.failedDetailViewController?.dismiss(animated: true) {
            self.presenter?.navigationController?.popViewController(animated: true)
        }
    }
    
    func dismissPhotoTaking(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.photoTakingViewController?.dismiss(animated: animated, completion: completion)
    }
    
    func dismissPhotoReview(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.photoReviewHostViewController?.dismiss(animated: animated, completion: completion)
    }
    
    deinit {
        print("🍎 FailedDeliveryNavigator - deinit")
    }
}

extension FailedDeliveryNavigator: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLo = locations.first else {
            return
        }
        self.currentLocation = latestLo
    }
}

extension FailedDeliveryNavigator: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let imageItems = results
            .map { $0.itemProvider }
            .filter { $0.canLoadObject(ofClass: UIImage.self) }
        
        let dispatchGroup = DispatchGroup()
        var images = [UIImage]()
        
        for imageItem in imageItems {
            dispatchGroup.enter()
            imageItem.loadObject(ofClass: UIImage.self) { image, _ in
                if let image = image as? UIImage {
                    images.append(image)
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            switch strongSelf.photoTakingFlow {
            case .taking:
                for image in images {
                    if strongSelf.photos.count < 2 {
                        strongSelf.photos.append(image)
                        strongSelf.photoTaken = image
                    }
                }
                if let photoTakingVC = strongSelf.photoTakingViewController as? TakePhotosViewController<FailedDeliveryNavigator> {
                    photoTakingVC.updateTitle()
                }
                switch strongSelf.failedReason {
                case .redelivery:
                    if strongSelf.photos.count >= 1 {
                        strongSelf.dismissPhotoTaking()
                    }
                case .failedContactCustomer:
                    if strongSelf.photos.count >= 2 {
                        strongSelf.dismissPhotoTaking()
                    }
                case .wrongAddress, .poBox:
                    break
                }
            case .review(let index):
                if images.count > 0 {
                    strongSelf.photos[index] = images[0]
                    strongSelf.photoTaken = images[0]
                }
                strongSelf.dismissPhotoTaking(animated: false) {
                    strongSelf.dismissPhotoReview(animated: false)
                }
            }
        }
    }
}

enum FailedReasonDelivery {
    case redelivery
    case failedContactCustomer
    case wrongAddress
    case poBox
    
    func displayString() -> String {
        switch self {
        case .redelivery:
            return String.redeliveryStr
        case .failedContactCustomer:
            return String.failToContactCustomerStr
        case .wrongAddress:
            return String.wrongAddressStr
        case .poBox:
            return String.POBoxStr
        }
    }
}
