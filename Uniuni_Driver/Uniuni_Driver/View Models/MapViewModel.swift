//
//  MapViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-31.
//

import Foundation
import Combine

class MapViewModel: ObservableObject {
    
    let networkService = NetworkService.shared
    
    @Published var languagesList: [LanguageDataModel] = []
    
    private var disposables = Set<AnyCancellable>()
    
    init() {}
    
    func fetchLanguagesFromAPI(warehouseID: Int) {
        
        NetworkService.shared.fetchLanguageList(warehouseID: warehouseID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                guard let strongSelf = self else { return }
                switch value {
                case .failure:
                    strongSelf.languagesList = []
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] language in
                guard let strongSelf = self else { return }
                guard let biz_data = language.biz_data else { return }
                strongSelf.languagesList = biz_data
            })
            .store(in: &disposables)
    }
}
