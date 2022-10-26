//
//  BusinessPickupScanViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-09.
//

import Foundation
import AVFoundation
import Combine
import UIKit

class BusinessPickupScanViewModel: ObservableObject {
    
    @Published var scannedPackage: ScannedPackage?
    @Published var scannedPackagesList: [ScannedPackage] = []
    @Published var inputedPackagesList: [ScannedPackage] = []
    
    @Published var scanList: [ScanListItem] = []
    @Published var summaryData: BusinessPickupScanSummaryDataModel.SummaryData?
    
    @Published var startNetworking: Bool = false
    @Published var showingProgressView: Bool = false
    
    @Published var showingNetworkErrorAlert: Bool = false
    @Published var showingSuccessfulAlert: Bool = false
    
    @Published var showingWrongPackageAlert: Bool = false
    
    var selectedListItem: BusinessPickupScanViewModel.ScanListItem?
    
    private var scannedBarcode: String?
    
    var signatureView: PencilKitSignatureView?
    
    private var disposables = Set<AnyCancellable>()
    
    var barCodeScanner: BarCodeScanner = BarCodeScanner(metadataObjectTypes: [.code128, .ean8, .ean13, .pdf417])
    var detectionPaused: Bool = false
    
    init() {
        self.observeBarcodeDetected()
    }
    
    private func observeBarcodeDetected() {
        self.barCodeScanner.$barCodeDetected
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] code in
                guard let strongSelf = self else { return }
                if let code = code, code.count > 0 && !strongSelf.detectionPaused {
                    strongSelf.detectionPaused = true
                    strongSelf.startNetworking = true
                    strongSelf.showingProgressView = true
                    strongSelf.scannedBarcode = code
                    strongSelf.checkPickupScanned(trackingNo: code)
                }
            })
            .store(in: &disposables)
    }
    
    func checkPickupScanned(trackingNo: String) {
        let manifestNo = self.selectedListItem?.package.manifest_no ?? ""
        NetworkService.shared.businessPickupScanCheck(driverID: AppConstants.driverID, manifestNo: manifestNo, trackingNo: trackingNo)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.showingProgressView = false
                switch value {
                case .failure(let error):
                    switch error {
                    case .invalidURL( _):
                        strongSelf.showingNetworkErrorAlert = true
                    case .netConnection( _):
                        strongSelf.showingNetworkErrorAlert = true
                    case .failStatusCode( _):
                        strongSelf.showingNetworkErrorAlert = true
                    default:
                        break
                    }
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                guard let strongSelf = self else { return }
                strongSelf.showingProgressView = false
                if response.status?.lowercased() == "success" {
                    if let item = response.data {
                        if let previousPack = strongSelf.scannedPackage, !strongSelf.listContainElement(element: previousPack) {
                            strongSelf.scannedPackagesList.insert(previousPack, at: 0)
                        }
                        strongSelf.scannedPackage = strongSelf.createScannedPackage(package: item, wrongPack: false)
                    }
                    strongSelf.detectionPaused = false
                    strongSelf.startNetworking = false
                } else {
                    strongSelf.showingWrongPackageAlert = true
                }
            })
            .store(in: &disposables)
    }
    
    func checkPickupManualInput(trackingNo: String) {
        let manifestNo = self.selectedListItem?.package.manifest_no ?? ""
        NetworkService.shared.businessPickupScanCheck(driverID: AppConstants.driverID, manifestNo: manifestNo, trackingNo: trackingNo)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.showingProgressView = false
                switch value {
                case .failure(let error):
                    switch error {
                    case .invalidURL( _):
                        strongSelf.showingNetworkErrorAlert = true
                    case .netConnection( _):
                        strongSelf.showingNetworkErrorAlert = true
                    case .failStatusCode( _):
                        strongSelf.showingNetworkErrorAlert = true
                    default:
                        break
                    }
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                guard let strongSelf = self else { return }
                strongSelf.showingProgressView = false
                if response.status?.lowercased() == "success" {
                    if let item = response.data {
                        let inputed = strongSelf.createScannedPackage(package: item, wrongPack: false)
                        if !strongSelf.manualListContainElement(element: inputed) {
                            strongSelf.inputedPackagesList.insert(inputed, at: 0)
                        }
                    }
                } else {
                    strongSelf.showingWrongPackageAlert = true
                }
            })
            .store(in: &disposables)
    }
    
    func fetchScanList() {
        NetworkService.shared.businessPickupScanList(driverID: AppConstants.driverID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.showingProgressView = false
                switch value {
                case .failure(let error):
                    switch error {
                    case .invalidURL( _):
                        break
                    case .netConnection( _):
                        break
                    case .failStatusCode( _):
                        break
                    default:
                        break
                    }
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                guard let strongSelf = self else { return }
                strongSelf.showingProgressView = false
                if response.status?.lowercased() == "success" {
                    if let itemList = response.data {
                        strongSelf.scanList = itemList.map {
                            ScanListItem(package: $0, wrongPackage: false)
                        }
                    }
                } else {}
            })
            .store(in: &disposables)
    }
    
    func fetchSummary() {
        let manifestNo = self.selectedListItem?.package.manifest_no ?? ""
        NetworkService.shared.businessPickupScanSummary(driverID: AppConstants.driverID, manifestNo: manifestNo)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.showingProgressView = false
                switch value {
                case .failure(let error):
                    switch error {
                    case .invalidURL( _):
                        break
                    case .netConnection( _):
                        break
                    case .failStatusCode( _):
                        break
                    default:
                        break
                    }
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                guard let strongSelf = self else { return }
                strongSelf.showingProgressView = false
                if response.status?.lowercased() == "success" {
                    strongSelf.summaryData = response.data
                } else {}
            })
            .store(in: &disposables)
    }
    
    func completeBusinessScan() {
        let manifestNo = self.selectedListItem?.package.manifest_no ?? ""
        let signature = self.signatureView?.signature?.compressImageTo(expectedSizeInMB: 0.6)?.jpegData(compressionQuality: 1)
        
        NetworkService.shared.completeBusinessPickupScan(driverID: AppConstants.driverID, vcode: AppConstants.vcode, manifestNo: manifestNo, signature: signature)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                self?.showingProgressView = false
                switch value {
                case .failure( _):
                    self?.showingNetworkErrorAlert = true
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] res in
                guard let strongSelf = self else { return }
                strongSelf.showingProgressView = false
                strongSelf.showingSuccessfulAlert = true
            })
            .store(in: &disposables)
    }
    
    private func createScannedPackage(package: BusinessPickupScanCheckDataModel.ItemData, wrongPack: Bool) -> ScannedPackage {
        return ScannedPackage(package: package, wrongPackage: wrongPack)
    }
    
    private func listContainElement(element: ScannedPackage) -> Bool {
        if self.scannedPackagesList.firstIndex(where: {
            $0.package.tno == element.package.tno
        }) != nil {
            return true
        }
        return false
    }
    
    private func manualListContainElement(element: ScannedPackage) -> Bool {
        if self.inputedPackagesList.firstIndex(where: {
            $0.package.tno == element.package.tno
        }) != nil {
            return true
        }
        return false
    }
    
    struct ScannedPackage: Identifiable {
        var id = UUID()
        var package: BusinessPickupScanCheckDataModel.ItemData
        var wrongPackage: Bool
    }
    
    struct ScanListItem: Identifiable, Equatable {
        var id = UUID()
        var package: BusinessPickupScanListDataModel.ListItem
        var wrongPackage: Bool
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.package.id == rhs.package.id
        }
    }
}

extension BusinessPickupScanViewModel: SignatureViewDelegate {
    
    func signatureViewDidDrawGesture(_ view: PencilKitSignatureView, _ tap: UIGestureRecognizer) {}
    
    func signatureViewDidDraw(_ view: PencilKitSignatureView) {
        self.signatureView = view
    }
}
