//
//  ScanHomeViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-22.
//

import Foundation
import AVFoundation
import Combine

class ScanHomeViewModel: ObservableObject {
    
    @Published var packsToPickNo: Int = 0
    @Published var packsToPickAddress: String = ""
    @Published var packsToDropNo: Int = 0
    @Published var packsToDropAddress: String = ""
    
    private var disposables = Set<AnyCancellable>()
    
    init() {}
    
    func fetchPacksPickDropInfo(driverID: Int) {
        NetworkService.shared.ordersToPickupInfo(driverID: driverID)
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
