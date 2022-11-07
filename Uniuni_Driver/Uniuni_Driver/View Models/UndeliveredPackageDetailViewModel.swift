//
//  UndeliveredPackageDetailViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-22.
//

import Foundation
import Combine

class UndeliveredPackageDetailViewModel: ObservableObject {
    
    @Published var packageViewModel: PackageViewModel?
    @Published var showingNetworkErrorAlert: Bool = false
    
    @Published var failedReason: Int?
    @Published var pods: [String] = []
    
    private var disposables = Set<AnyCancellable>()
    
    init(packageViewModel: PackageViewModel) {
        self.packageViewModel = packageViewModel
    }
    
    func fetchPackageDeliveryHistoryFromAPI() {
        if let orderID = self.packageViewModel?.order_id {
            NetworkService.shared.packageDeliveryHistory(orderID: orderID)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] value in
                    guard let strongSelf = self else { return }
                    switch value {
                    case .failure( _):
                        strongSelf.showingNetworkErrorAlert = true
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] history in
                    guard let strongSelf = self else { return }
                    guard let biz_data = history.biz_data else { return }
                    strongSelf.parseLatestDelivery(history: biz_data)
                })
                .store(in: &disposables)
        }
    }
    
    private func parseLatestDelivery(history: [PackageDeliveryHistoryDataModel.DeliveryHistory]) {
        let sortedByTime = history.sorted(by: {
            $0.delivery_time ?? "" > $1.delivery_time ?? ""
        })
        if sortedByTime.count > 0 {
            self.failedReason = sortedByTime[0].failed_reason
            self.pods = sortedByTime[0].pods ?? []
        }
    }
}
