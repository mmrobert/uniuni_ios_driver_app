//
//  NetworkService.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-30.
//

import Foundation
import Combine

protocol NetworkServiceProvider {
    func fetchDeliveringList(driverID: Int) -> AnyPublisher<PackagesListDataModel, NetworkRequestError>
    func fetchUndeliveredList(driverID: Int) -> AnyPublisher<PackagesListDataModel, NetworkRequestError>
    func fetchServiceList(driverID: Int) -> AnyPublisher<ServicePointsListDataModel, NetworkRequestError>
    func fetchLanguageList(warehouseID: Int) -> AnyPublisher<LanguagesListDataModel, NetworkRequestError>
}

class NetworkService: NetworkServiceProvider {
    
    static let shared = NetworkService()
    
    private init() {}
    
    func fetchDeliveringList(driverID: Int) -> AnyPublisher<PackagesListDataModel, NetworkRequestError> {
        let queryParas = ["driver_id": String(driverID)]
        let router = NetworkAPIs.fetchDeliveringList(pathParas: nil, queryParas: queryParas, bodyParas: nil)
        do {
            let netRequest = try router.makeURLRequest()
            return router.fetchJSON(request: netRequest)
        } catch let error {
            if let error = error as? NetworkRequestError {
                return Fail(error: error).eraseToAnyPublisher()
            } else {
                let error = NetworkRequestError.other(description: error.localizedDescription)
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
    }
    
    func fetchUndeliveredList(driverID: Int) -> AnyPublisher<PackagesListDataModel, NetworkRequestError> {
        let queryParas = ["driver_id": String(driverID)]
        let router = NetworkAPIs.fetchUndeliveredList(pathParas: nil, queryParas: queryParas, bodyParas: nil)
        do {
            let netRequest = try router.makeURLRequest()
            return router.fetchJSON(request: netRequest)
        } catch let error {
            if let error = error as? NetworkRequestError {
                return Fail(error: error).eraseToAnyPublisher()
            } else {
                let error = NetworkRequestError.other(description: error.localizedDescription)
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
    }
    
    func fetchServiceList(driverID: Int) -> AnyPublisher<ServicePointsListDataModel, NetworkRequestError> {
        let pathParas = [String(driverID)]
        let router = NetworkAPIs.fetchServiceList(pathParas: pathParas, queryParas: nil, bodyParas: nil)
        do {
            let netRequest = try router.makeURLRequest()
            return router.fetchJSON(request: netRequest)
        } catch let error {
            if let error = error as? NetworkRequestError {
                return Fail(error: error).eraseToAnyPublisher()
            } else {
                let error = NetworkRequestError.other(description: error.localizedDescription)
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
    }
    
    func updateAddressType(driverID: Int, orderSN: String, addressType: Int) -> AnyPublisher<UpdateAddressTypeResponse, NetworkRequestError> {
        let bodyParas = ["order_sn": orderSN, "addr_type": addressType, "operator": driverID] as [String:Any]
        let router = NetworkAPIs.updateAddressType(pathParas: nil, queryParas: nil, bodyParas: bodyParas)
        do {
            let netRequest = try router.makeURLRequest()
            return router.fetchJSON(request: netRequest)
        } catch let error {
            if let error = error as? NetworkRequestError {
                return Fail(error: error).eraseToAnyPublisher()
            } else {
                let error = NetworkRequestError.other(description: error.localizedDescription)
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
    }
    
    func fetchLanguageList(warehouseID: Int) -> AnyPublisher<LanguagesListDataModel, NetworkRequestError> {
        let pathParas = [String(warehouseID)]
        let router = NetworkAPIs.fetchLanguageList(pathParas: pathParas, queryParas: nil, bodyParas: nil)
        do {
            let netRequest = try router.makeURLRequest()
            return router.fetchJSON(request: netRequest)
        } catch let error {
            if let error = error as? NetworkRequestError {
                return Fail(error: error).eraseToAnyPublisher()
            } else {
                let error = NetworkRequestError.other(description: error.localizedDescription)
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
    }
    
    func fetchMsgTemplates(warehouseID: Int, language: String) -> AnyPublisher<MessageTemplatesListDataModel, NetworkRequestError> {
        let pathParas = [String(warehouseID), language]
        let router = NetworkAPIs.fetchMsgTemplates(pathParas: pathParas, queryParas: nil, bodyParas: nil)
        do {
            let netRequest = try router.makeURLRequest()
            return router.fetchJSON(request: netRequest)
        } catch let error {
            if let error = error as? NetworkRequestError {
                return Fail(error: error).eraseToAnyPublisher()
            } else {
                let error = NetworkRequestError.other(description: error.localizedDescription)
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
    }
    
    func sendMessage(orderID: Int, templateID: Int) -> AnyPublisher<GeneralHttpResponse, NetworkRequestError> {
        let bodyParas = ["order_id": orderID, "template_id": templateID]
        let router = NetworkAPIs.sendMessage(pathParas: nil, queryParas: nil, bodyParas: bodyParas)
        do {
            let netRequest = try router.makeURLRequest()
            return router.fetchJSON(request: netRequest)
        } catch let error {
            if let error = error as? NetworkRequestError {
                return Fail(error: error).eraseToAnyPublisher()
            } else {
                let error = NetworkRequestError.other(description: error.localizedDescription)
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
    }
}
