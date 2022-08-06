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
    @Published var networkError: NetworkRequestError?
    
    private var disposables = Set<AnyCancellable>()
    
    init(list: [ServicePointDataModel]? = nil) {
        guard let list = list else {
            return
        }
        self.list = list.map {
            ServicePointViewModel(dataModel: $0)
        }
    }
    
    func fetchServicesFromAPI(driverID: Int) {
        
        NetworkService.shared.fetchServiceList(driverID: driverID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                guard let strongSelf = self else { return }
                switch value {
                case .failure(let error):
                    strongSelf.networkError = error
                    strongSelf.list = []
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] packages in
                guard let strongSelf = self else { return }
                guard let biz_data = packages.biz_data else { return }
                strongSelf.saveServicesToCoreData(services: [biz_data])
                strongSelf.list = [ServicePointViewModel(dataModel: biz_data)]
            })
            .store(in: &disposables)
    }
    
    private func saveServicesToCoreData(services: [ServicePointDataModel]) {
        for service in services {
            coreDataManager.saveServicePoint(servicePoint: service)
        }
    }
    
    func fetchServicePointsFromCoreData() {
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
        let data1 = ServicePointDataModel(
            id: 99,
            name: "YY99",
            address: "2345 Broadway B, Vancouver",
            lat: 49.2,
            lng: -123.0
        )
        coreDataManager.saveServicePoint(servicePoint: data1)
    }
}
