//
//  ServicePointsListViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-12.
//

import Foundation
import Combine

class ServicePointsListViewModel: ObservableObject {
    
    let coreDataManager = CoreDataManager.shared
    
    @Published var list: [ServicePointViewModel] = []
    
    private var disposables = Set<AnyCancellable>()
    
    init(list: [ServicePointDataModel]? = nil) {
        guard let list = list else {
            return
        }
        self.list = list.map {
            ServicePointViewModel(dataModel: $0)
        }
    }
    
    func fetchServicePoints() {
        self.coreDataManager.$services
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] services in
                guard let strongSelf = self else { return }
                strongSelf.list = services.map {
                    ServicePointViewModel(dataModel: $0)
                }
            })
            .store(in: &disposables)
        self.coreDataManager.fetchServicePoints()
    }
    
    func saveMockServicesList() {
        let bizData1 = ServicePointDataModel.Biz_Data(
            id: 99,
            name: "YY99",
            address: "2345 Broadway B, Vancouver",
            lat: 49.2,
            lng: -123.0
        )
        coreDataManager.saveServicePoint(servicePoint: ServicePointDataModel(
            biz_code: "999",
            biz_message: "999",
            biz_data: bizData1
        ))
    }
}
