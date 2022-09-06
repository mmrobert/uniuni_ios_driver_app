//
//  ScanPackagesViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-04.
//

import Foundation
import Combine

class ScanPackagesViewModel: ObservableObject {
    
    @Published var packsToPickNo: Int = 0
    @Published var packsToPickAddress: String = ""
    @Published var packsToDropNo: Int = 0
    @Published var packsToDropAddress: String = ""
    
    @Published var scannedPackage: PackageViewModel?
    @Published var scannedPackagesList: [PackageViewModel] = []
    
    private var disposables = Set<AnyCancellable>()
    
    private var driverID: Int
    
    init(driverID: Int) {
        self.driverID = driverID
        
        let pp = PackageViewModel(dataModel: PackageDataModel(
            order_id: 999,
            order_sn: "99900",
            tracking_no: "99999",
            goods_type: .medical,
            express_type: .express,
            route_no: 99,
            assign_time: "5-2-2019",
            delivery_by: "5-4-2019",
            state: .delivering,
            name: "Charlie Peter",
            mobile: "999999999",
            address: "999 Bayview St",
            address_type: .apartment,
            zipcode: "99",
            lat: "49.27",
            lng: "-122.86",
            buzz_code: "99",
            postscript: "This pack 99",
            warehouse_id: 9,
            failed_handle_type: .drop_off
        ))
        self.scannedPackage = pp
        self.scannedPackagesList = [pp, pp]
    }
    
    func fetchPacksPickDropInfo() {
        NetworkService.shared.ordersToPickupInfo(driverID: self.driverID)
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
                if let totalNumber = response.biz_data?.total_number {
                    strongSelf.packsToPickNo = totalNumber
                }
                if let add = response.biz_data?.address {
                    strongSelf.packsToPickAddress = add
                }
            })
            .store(in: &disposables)
        NetworkService.shared.ordersToDropoffInfo(driverID: driverID)
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
                if let totalNumber = response.biz_data?.total_number {
                    strongSelf.packsToDropNo = totalNumber
                }
                if let add = response.biz_data?.address {
                    strongSelf.packsToDropAddress = add
                }
            })
            .store(in: &disposables)
    }
}
