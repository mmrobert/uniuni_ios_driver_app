//
//  DropoffScanPackagesViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-05.
//

import Foundation
import AVFoundation
import Combine
import UIKit

class DropoffScanPackagesViewModel: ObservableObject {
    
    @Published var dropoffPackagesList: [ScannedPackage] = []
    
    @Published var showingNetworkErrorAlert: Bool = false
    @Published var showingSuccessfulAlert: Bool = false
    
    @Published var showingAlreadyScannedAlert: Bool = false
    @Published var showingWrongPackageAlert: Bool = false
    
    @Published var showingProgressView: Bool = false
    
    private var servicePointID: Int?
    private var failedUploaded: [Int] = []
    private var scannedBarcode: String?
    
    var signatureView: PencilKitSignatureView?
    
    private var disposables = Set<AnyCancellable>()
    
    var barCodeScanner: BarCodeScanner = BarCodeScanner(metadataObjectTypes: [.code128, .ean8, .ean13, .pdf417])
    
    init() {
        self.observeBarcodeDetected()
        CoreDataManager.shared.$failedUploadeds
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] failed in
                guard let strongSelf = self else { return }
                strongSelf.failedUploaded = failed
                strongSelf.undeliveredList()
                
            })
            .store(in: &disposables)
        CoreDataManager.shared.fetchFailedUploadeds()
        self.fetchServicePointInfo()
    }
    
    private func observeBarcodeDetected() {
        self.barCodeScanner.$barCodeDetected
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] code in
                guard let strongSelf = self else { return }
                if let code = code, code.count > 0 {
                    strongSelf.scannedBarcode = code
                    if let packIndex = strongSelf.dropoffPackagesList.firstIndex(where: {
                        $0.package.tracking_no == code
                    }) {
                        if strongSelf.dropoffPackagesList[packIndex].state != .notScanned {
                            strongSelf.showingAlreadyScannedAlert = true
                        } else {
                            var updated = strongSelf.dropoffPackagesList.remove(at: packIndex)
                            updated.state = .scanned
                            strongSelf.dropoffPackagesList.insert(updated, at: 0)
                        }
                    } else {
                        strongSelf.showingWrongPackageAlert = true
                    }
                }
            })
            .store(in: &disposables)
    }
    
    func undeliveredList() {
        NetworkService.shared.fetchUndeliveredList(driverID: AppConfigurator.shared.driverID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                switch value {
                case .failure( _):
                    break
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] packages in
                guard let strongSelf = self else { return }
                guard let biz_data = packages.biz_data else { return }
                let newData = strongSelf.removeFailedUploaded(biz_data: biz_data)
                let dropoff = newData.filter {
                    $0.failed_handle_type == .drop_off
                }
                strongSelf.dropoffPackagesList = dropoff.map { packData in
                    let vm = PackageViewModel(dataModel: packData)
                    return ScannedPackage(package: vm, state: .notScanned)
                }
            })
            .store(in: &disposables)
    }
    
    func checkScannedAmount() -> Bool {
        guard self.dropoffPackagesList.count > 0 else {
            return false
        }
        if self.dropoffPackagesList.firstIndex(where: {
            $0.state == .notScanned
        }) != nil {
            return false
        }
        return true
    }
    
    func manualInput(input: DropoffScanPackagesViewModel.ScannedPackage) {
        
        if let packIndex = self.dropoffPackagesList.firstIndex(where: {
            $0.package.tracking_no == input.package.tracking_no
        }) {
            var updated = self.dropoffPackagesList.remove(at: packIndex)
            updated.state = .manualInput
            self.dropoffPackagesList.insert(updated, at: 0)
        }
    }
    
    func fetchServicePointInfo() {
        NetworkService.shared.servicePointInfo(driverID: AppConfigurator.shared.driverID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                switch value {
                case .failure( _):
                    break
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] serPoint in
                guard let strongSelf = self else { return }
                strongSelf.servicePointID = serPoint.biz_data?.id
            })
            .store(in: &disposables)
    }
    
    func completeDropoffScan() {
        let servicePointID = self.servicePointID ?? 0
        let scanneds = self.dropoffPackagesList.filter {
            $0.state != .notScanned
        }.compactMap { pack -> String? in
            guard let orderID = pack.package.order_id else {
                return nil
            }
            var inputType = 0
            if pack.state == .manualInput {
                inputType = 1
            }
            return "\(orderID),\(inputType)"
        }
        var scannedItems = ""
        if scanneds.count > 0 {
            scannedItems = scanneds.joined(separator: "|")
        }
        let signature = self.signatureView?.signature?.compressImageTo(expectedSizeInMB: 0.14)?.jpegData(compressionQuality: 1)
        NetworkService.shared.completeDropoffScan(driverID: AppConfigurator.shared.driverID, servicePointID: servicePointID, scannedItems: scannedItems, signature: signature)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                self?.showingProgressView = false
                switch value {
                case .failure( _):
                    self?.showingNetworkErrorAlert = true
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.showingProgressView = false
                strongSelf.showingSuccessfulAlert = true
                strongSelf.undeliveredList()
            })
            .store(in: &disposables)
    }
    
    private func removeFailedUploaded(biz_data: [PackageDataModel]) -> [PackageDataModel] {
        var biz_data = biz_data
        for failed in self.failedUploaded {
            if let packIndex = biz_data.firstIndex(where: {
                $0.order_id == failed
            }) {
                _ = biz_data.remove(at: packIndex)
            }
        }
        return biz_data
    }
    
    struct ScannedPackage: Identifiable, Equatable {
        var id = UUID()
        var package: PackageViewModel
        var state: State
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.package.tracking_no == rhs.package.tracking_no
        }
        
        enum State {
            case notScanned
            case scanned
            case manualInput
        }
    }
}

extension DropoffScanPackagesViewModel: SignatureViewDelegate {
    
    func signatureViewDidDrawGesture(_ view: PencilKitSignatureView, _ tap: UIGestureRecognizer) {}
    
    func signatureViewDidDraw(_ view: PencilKitSignatureView) {
        self.signatureView = view
    }
}
