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
    @Published var msgTemplatesList: [MessageTemplateDataModel] = []
    @Published var responseSendMsg: GeneralHttpResponse?
    
    @Published var errorUpdateAddressType: String?
    @Published var errorSendMsg: NetworkRequestError?
    
    private var disposables = Set<AnyCancellable>()
    
    init() {}
    
    func updateAddressTypeFromAPI(driverID: Int, orderSN: String, addressType: Int) {
        
        NetworkService.shared.updateAddressType(driverID: driverID, orderSN: orderSN, addressType: addressType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                switch value {
                case .failure( _):
                    self?.errorUpdateAddressType = String.addressTypeNotUpdatedStr
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                guard let strongSelf = self else { return }
                if response.status?.lowercased() != "success" {
                    strongSelf.errorUpdateAddressType = String.addressTypeNotUpdatedStr
                }
            })
            .store(in: &disposables)
    }
    
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
    
    func fetchMsgTemplatesListFromAPI(warehouseID: Int, language: String) {
        
        NetworkService.shared.fetchMsgTemplates(warehouseID: warehouseID, language: language)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                guard let strongSelf = self else { return }
                switch value {
                case .failure:
                    strongSelf.msgTemplatesList = []
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] templates in
                guard let strongSelf = self else { return }
                guard let biz_data = templates.biz_data else { return }
                strongSelf.msgTemplatesList = biz_data
            })
            .store(in: &disposables)
    }
    
    func sendMsgFromAPI(orderID: Int, templateID: Int) {
        
        NetworkService.shared.sendMessage(orderID: orderID, templateID: templateID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                guard let strongSelf = self else { return }
                switch value {
                case .failure(let error):
                    strongSelf.errorSendMsg = error
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                guard let strongSelf = self else { return }
                strongSelf.responseSendMsg = response
            })
            .store(in: &disposables)
    }
    
    func reDeliveryHistory(driverID: Int, orderID: Int, completion: @escaping (RedeliveryDataModel?) -> ()) {
        
        NetworkService.shared.reDeliveryHistory(driverID: driverID, orderID: orderID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                switch value {
                case .failure:
                    break
                case .finished:
                    break
                }
            }, receiveValue: { response in
                if let retryData = response.biz_data {
                    completion(retryData)
                } else {
                    completion(nil)
                }
            })
            .store(in: &disposables)
    }
}
