//
//  PickupScanPackagesViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-04.
//

import Foundation
import AVFoundation
import Combine

class PickupScanPackagesViewModel: ObservableObject {
    
    private struct Constants {
        static let wrongPackage: String = "SCAN.WRONG.PARCEL"
        static let alreadyScanned: String = "SCAN.ALREADY.SCANNED"
        static let batchClosed: String = "SCAN.BATCH.CLOSED"
    }
    
    @Published var scannedPackage: ScannedPackage?
    @Published var scannedPackagesList: [ScannedPackage] = []
    
    @Published var startNetworking: Bool = false
    @Published var showingProgressView: Bool = false
    
    @Published var showingNetworkErrorAlert: Bool = false
    @Published var showingWrongPackageAlert: Bool = false
    @Published var showingAlreadyScannedAlert: Bool = false
    @Published var showingBatchClosedAlert: Bool = false
    
    private var scannedBarcode: String?
    private var scanBatchID: Int = 0
    
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
    
    func fetchScanBatchID(driverID: Int) {
        NetworkService.shared.fetchScanBatchID(driverID: driverID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                switch value {
                case .failure( _):
                    break
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                guard let strongSelf = self else { return }
                if let scanBatchID = response.biz_data?.scan_batch_id {
                    strongSelf.scanBatchID = scanBatchID
                }
            })
            .store(in: &disposables)
    }
    
    func checkPickupScanned(trackingNo: String) {
        NetworkService.shared.checkPickupScanned(scanBatchID: self.scanBatchID, trackingNo: trackingNo)
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
                    case .failStatusCode(let codeStr):
                        if codeStr == "Status code: \(404)" {
                            strongSelf.showingWrongPackageAlert = true
                            if let previousPack = strongSelf.scannedPackage, !strongSelf.listContainElement(element: previousPack) {
                                strongSelf.scannedPackagesList.insert(previousPack, at: 0)
                            }
                            strongSelf.scannedPackage = strongSelf.createScannedPackage(trackingNo: trackingNo, orderID: nil, routeNo: nil, wrongPack: true)
                        } else {
                            strongSelf.showingNetworkErrorAlert = true
                        }
                    default:
                        break
                    }
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                guard let strongSelf = self else { return }
                strongSelf.showingProgressView = false
                if response.biz_code?.lowercased() == Constants.wrongPackage.lowercased() {
                    if let trackingNo = response.biz_data?.tracking_no {
                        if let previousPack = strongSelf.scannedPackage, !strongSelf.listContainElement(element: previousPack) {
                            strongSelf.scannedPackagesList.insert(previousPack, at: 0)
                        }
                        strongSelf.scannedPackage = strongSelf.createScannedPackage(trackingNo: trackingNo, orderID: response.biz_data?.order_id, routeNo: response.biz_data?.route_no, wrongPack: true)
                    }
                    strongSelf.showingWrongPackageAlert = true
                    return
                } else if response.biz_code?.lowercased() == Constants.alreadyScanned.lowercased() {
                    strongSelf.showingAlreadyScannedAlert = true
                    return
                } else if response.biz_code?.lowercased() == Constants.batchClosed.lowercased() {
                    strongSelf.showingBatchClosedAlert = true
                    return
                }
                if let trackingNo = response.biz_data?.tracking_no {
                    if let previousPack = strongSelf.scannedPackage, !strongSelf.listContainElement(element: previousPack) {
                        strongSelf.scannedPackagesList.insert(previousPack, at: 0)
                    }
                    strongSelf.scannedPackage = strongSelf.createScannedPackage(trackingNo: trackingNo, orderID: response.biz_data?.order_id, routeNo: response.biz_data?.route_no, wrongPack: false)
                }
                strongSelf.detectionPaused = false
                strongSelf.startNetworking = false
            })
            .store(in: &disposables)
    }
    
    func reopenBatch() {
        NetworkService.shared.closeReopenBatch(scanBatchID: self.scanBatchID, status: "REOPEN")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                self?.showingProgressView = false
                switch value {
                case .failure( _):
                    break
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.showingProgressView = false
                if let code = strongSelf.scannedBarcode {
                    strongSelf.checkPickupScanned(trackingNo: code)
                }
            })
            .store(in: &disposables)
    }
    
    private func createScannedPackage(trackingNo: String, orderID: Int?, routeNo: Int?, wrongPack: Bool) -> ScannedPackage {
        var pack = PackageViewModel()
        pack.tracking_no = trackingNo
        pack.route_no = routeNo
        pack.order_id = orderID
        return ScannedPackage(package: pack, wrongPackage: wrongPack)
    }
    
    private func listContainElement(element: ScannedPackage) -> Bool {
        if self.scannedPackagesList.firstIndex(where: {
            $0.package.tracking_no == element.package.tracking_no
        }) != nil {
            return true
        }
        return false
    }
    
    struct ScannedPackage: Identifiable {
        var id = UUID()
        var package: PackageViewModel
        var wrongPackage: Bool
    }
}
