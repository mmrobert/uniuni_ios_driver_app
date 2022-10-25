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
    
    func completeDelivery(orderID: Int, deliveryResult: Int, podImages: [Data]?, failedReason: Int?, longitude: Double, latitude: Double) -> AnyPublisher<GeneralHttpResponse, NetworkRequestError> {
        let bodyParas = ["order_id": orderID,
                         "delivery_result": deliveryResult,
                         "pod_images": podImages as Any,
                         "failed_reason": failedReason as Any,
                         "longitude": longitude,
                         "latitude": latitude] as [String:Any]
        let router = NetworkAPIs.completeDelivery(pathParas: nil, queryParas: nil, bodyParas: bodyParas)
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
    
    func reDeliveryHistory(driverID: Int, orderID: Int) -> AnyPublisher<RedeliveryHistoryDataModel, NetworkRequestError> {
        let pathParas = [String(driverID), String(orderID)]
        let router = NetworkAPIs.reDeliveryHistory(pathParas: pathParas, queryParas: nil, bodyParas: nil)
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
    
    func reDeliveryTry(driverID: Int, orderID: Int, latitude: Double, longitude: Double, podImages: [Data]?) -> AnyPublisher<GeneralHttpResponse, NetworkRequestError> {
        let bodyParas = ["driver_id": driverID,
                         "order_id": orderID,
                         "latitude": latitude,
                         "longitude": longitude,
                         "pod_img": podImages as Any] as [String:Any]
        let router = NetworkAPIs.reDeliveryTry(pathParas: nil, queryParas: nil, bodyParas: bodyParas)
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
    
    func packageDeliveryHistory(orderID: Int) -> AnyPublisher<PackageDeliveryHistoryDataModel, NetworkRequestError> {
        let pathParas = [String(orderID)]
        let router = NetworkAPIs.packageDeliveryHistory(pathParas: pathParas, queryParas: nil, bodyParas: nil)
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
    
    func ordersToPickupInfo(driverID: Int) -> AnyPublisher<OrdersToPickupDataModel, NetworkRequestError> {
        let pathParas = [String(driverID)]
        let router = NetworkAPIs.ordersToPickup(pathParas: pathParas, queryParas: nil, bodyParas: nil)
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
    
    func ordersToDropoffInfo(driverID: Int) -> AnyPublisher<OrdersToDropoffDataModel, NetworkRequestError> {
        let pathParas = [String(driverID)]
        let router = NetworkAPIs.ordersToDropoff(pathParas: pathParas, queryParas: nil, bodyParas: nil)
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
    
    func fetchScanBatchID(driverID: Int) -> AnyPublisher<ScanBatchIDDataModel, NetworkRequestError> {
        let bodyParas = ["driver_id": driverID]
        let router = NetworkAPIs.fetchScanBatchID(pathParas: nil, queryParas: nil, bodyParas: bodyParas)
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
    
    func checkPickupScanned(scanBatchID: Int, trackingNo: String) -> AnyPublisher<PickupCheckScannedDataModel, NetworkRequestError> {
        let bodyParas = ["scan_batch_id": scanBatchID,
                         "tracking_no": trackingNo] as [String:Any]
        let router = NetworkAPIs.checkPickupScanned(pathParas: nil, queryParas: nil, bodyParas: bodyParas)
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
    
    func closeReopenBatch(scanBatchID: Int, status: String) -> AnyPublisher<GeneralHttpResponse, NetworkRequestError> {
        let pathParas = [String(scanBatchID)]
        let bodyParas = ["status": status] as [String:Any]
        let router = NetworkAPIs.closeReopenBatch(pathParas: pathParas, queryParas: nil, bodyParas: bodyParas)
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
    
    func pickupScanReport(scanBatchID: Int) -> AnyPublisher<PickupScanReportDataModel, NetworkRequestError> {
        let bodyParas = ["scan_batch_id": scanBatchID] as [String:Any]
        let router = NetworkAPIs.pickupScanReport(pathParas: nil, queryParas: nil, bodyParas: bodyParas)
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
    
    func servicePointInfo(driverID: Int) -> AnyPublisher<ServicePointInfoDataModel, NetworkRequestError> {
        let pathParas = [String(driverID)]
        let router = NetworkAPIs.servicePointInfo(pathParas: pathParas, queryParas: nil, bodyParas: nil)
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
    
    func completeDropoffScan(driverID: Int, servicePointID: Int, scannedItems: String, signature: Data?) -> AnyPublisher<GeneralHttpResponse, NetworkRequestError> {
        let bodyParas = ["driver_id": driverID,
                         "service_point_id": servicePointID,
                         "scanned_parcel_items": scannedItems,
                         "signature": signature as Any] as [String:Any]
        let router = NetworkAPIs.completeDropoffScan(pathParas: nil, queryParas: nil, bodyParas: bodyParas)
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
    
    func businessPickupScanList(driverID: Int) -> AnyPublisher<BusinessPickupScanListDataModel, NetworkRequestError> {
        let queryParas = ["driver_id": String(driverID)]
        let router = NetworkAPIs.businessPickupScanList(pathParas: nil, queryParas: queryParas, bodyParas: nil)
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
    
    func businessPickupScanCheck(driverID: Int, manifestNo: String, trackingNo: String) -> AnyPublisher<BusinessPickupScanCheckDataModel, NetworkRequestError> {
        let bodyParas = ["manifest_no": manifestNo,
                         "staff_id": driverID,
                         "tno": trackingNo] as [String:Any]
        let router = NetworkAPIs.businessPickupScanCheck(pathParas: nil, queryParas: nil, bodyParas: bodyParas)
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
    
    func businessPickupScanSummary(driverID: Int, manifestNo: String) -> AnyPublisher<BusinessPickupScanSummaryDataModel, NetworkRequestError> {
        let queryParas = ["driver_id": String(driverID),
                          "manifest_no": manifestNo]
        let router = NetworkAPIs.businessPickupScanSummary(pathParas: nil, queryParas: queryParas, bodyParas: nil)
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
    
    func completeBusinessPickupScan(driverID: Int, vcode: String, manifestNo: String, signature: Data?) -> AnyPublisher<BusinessPickupScanCompleteDataModel, NetworkRequestError> {
        let bodyParas = ["vcode": vcode,
                         "manifest_no": manifestNo,
                         "driver_id": String(driverID),
                         "signature": signature as Any] as [String:Any]
        let router = NetworkAPIs.completeBusinessPickupScan(pathParas: nil, queryParas: nil, bodyParas: bodyParas)
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
