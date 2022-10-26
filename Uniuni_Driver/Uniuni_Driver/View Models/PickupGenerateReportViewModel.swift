//
//  PickupGenerateReportViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-04.
//

import Foundation
import Combine

class PickupGenerateReportViewModel: ObservableObject {
    
    @Published var showingProgressView: Bool = false
    
    @Published var showingNetworkErrorAlert: Bool = false
    
    @Published var pickupScanReportData: PickupScanReportData?
    @Published var unscannedParcels: [ParcelViewModel] = []
    @Published var returnedParcels: [ParcelViewModel] = []
    
    private var scanBatchID: Int = 0
    
    private var disposables = Set<AnyCancellable>()
    
    init() {
        self.fetchScanBatchID(driverID: AppConstants.driverID)
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
    
    func fetchPickupScanReport() {
        NetworkService.shared.pickupScanReport(scanBatchID: self.scanBatchID)
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
                strongSelf.pickupScanReportData = response.biz_data
                if let unscanned_parcels = response.biz_data?.unscanned_parcels {
                    strongSelf.unscannedParcels = unscanned_parcels.map {
                        ParcelViewModel(tracking_no: $0.tracking_no, route_no: $0.route_no)
                    }
                }
                if let returned_parcels = response.biz_data?.returned_parcels {
                    strongSelf.returnedParcels = returned_parcels.map {
                        ParcelViewModel(tracking_no: $0.tracking_no, route_no: $0.route_no)
                    }
                }
            })
            .store(in: &disposables)
    }
    
    func closeBatch() {
        NetworkService.shared.closeReopenBatch(scanBatchID: self.scanBatchID, status: "CLOSE")
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
            })
            .store(in: &disposables)
    }
    
    struct ParcelViewModel: Identifiable {
        var id = UUID()
        var tracking_no: String?
        var route_no: Int?
    }
}

