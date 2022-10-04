//
//  PickupManualInputViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-02.
//

import Foundation
import Combine

class PickupManualInputViewModel: ObservableObject {
    
    private struct Constants {
        static let wrongPackage: String = "SCAN.WRONG.PARCEL"
        static let alreadyScanned: String = "SCAN.ALREADY.SCANNED"
        static let batchClosed: String = "SCAN.BATCH.CLOSED"
    }
    
    @Published var inputedPackage: InputedPackage?
    @Published var inputedPackagesList: [InputedPackage] = []
    
    @Published var showingProgressView: Bool = false
    
    @Published var showingNetworkErrorAlert: Bool = false
    @Published var showingWrongPackageAlert: Bool = false
    @Published var showingAlreadyScannedAlert: Bool = false
    @Published var showingBatchClosedAlert: Bool = false
    
    private var inputedBarcode: String?
    private var scanBatchID: Int = 0
    
    private var disposables = Set<AnyCancellable>()
    
    init() {}
    
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
    
    func checkPickupInputed(trackingNo: String) {
        NetworkService.shared.checkPickupScanned(scanBatchID: self.scanBatchID, trackingNo: trackingNo)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                self?.showingProgressView = false
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
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                guard let strongSelf = self else { return }
                strongSelf.showingProgressView = false
                if response.biz_code?.lowercased() == Constants.wrongPackage.lowercased() {
                    var pack: PackageViewModel? = nil
                    if let trackingNo = response.biz_data?.tracking_no {
                        pack = PackageViewModel()
                        pack?.tracking_no = trackingNo
                        pack?.route_no = response.biz_data?.route_no
                        pack?.order_id = response.biz_data?.order_id
                    }
                    if let pack = pack {
                        strongSelf.inputedPackage = InputedPackage(package: pack, wrongPackage: true)
                        strongSelf.inputedPackagesList.insert(InputedPackage(package: pack, wrongPackage: true), at: 0)
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
                var pack: PackageViewModel? = nil
                if let trackingNo = response.biz_data?.tracking_no {
                    pack = PackageViewModel()
                    pack?.tracking_no = trackingNo
                    pack?.route_no = response.biz_data?.route_no
                    pack?.order_id = response.biz_data?.order_id
                }
                if let pack = pack {
                    strongSelf.inputedPackage = InputedPackage(package: pack, wrongPackage: false)
                    strongSelf.inputedPackagesList.insert(InputedPackage(package: pack, wrongPackage: false), at: 0)
                }
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
                if let code = strongSelf.inputedBarcode {
                    strongSelf.checkPickupInputed(trackingNo: code)
                }
            })
            .store(in: &disposables)
    }
    
    struct InputedPackage: Identifiable {
        var id = UUID()
        var package: PackageViewModel
        var wrongPackage: Bool
    }
}
