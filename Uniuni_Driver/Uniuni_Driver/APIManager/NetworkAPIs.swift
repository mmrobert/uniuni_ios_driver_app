//
//  NetworkAPIs.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-30.
//

import Foundation
import Combine

enum NetworkAPIs {
    
    enum RequestMethod: String {
        case get     = "GET"
        case post    = "POST"
        case put     = "PUT"
        case delete  = "DELETE"
    }
    
    // MARK: - for each endpoind of backend
    case login(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case fetchDeliveringList(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case fetchUndeliveredList(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case fetchServiceList(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case updateAddressType(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case fetchLanguageList(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case fetchMsgTemplates(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case sendMessage(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case completeDelivery(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case reDeliveryHistory(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case reDeliveryTry(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case packageDeliveryHistory(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case ordersToPickup(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case ordersToDropoff(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case fetchScanBatchID(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case checkPickupScanned(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case closeReopenBatch(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case pickupScanReport(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case servicePointInfo(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case completeDropoffScan(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case businessPickupScanList(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case businessPickupScanCheck(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case businessPickupScanSummary(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case completeBusinessPickupScan(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    
    // MARK: - base URL
    var baseURL: String {
        switch self {
        case .updateAddressType( _, _, _):
            return "https://app.test.uniexpress.org"
        case .businessPickupScanList( _, _, _),
                .businessPickupScanCheck( _, _, _),
                .businessPickupScanSummary( _, _, _),
                .completeBusinessPickupScan( _, _, _):
            return "https://appdev.uniexpress.ca"
        default:
            return AppConfigurator.shared.baseURL
        }
    }
    
    // MARK: - Request Method
    var method: RequestMethod {
        switch self {
        case .login( _, _, _):
            return .post
        case .fetchDeliveringList( _, _, _):
            return .get
        case .fetchUndeliveredList( _, _, _):
            return .get
        case .fetchServiceList( _, _, _):
            return .get
        case .updateAddressType( _, _, _):
            return .post
        case .fetchLanguageList( _, _, _):
            return .get
        case .fetchMsgTemplates( _, _, _):
            return .get
        case .sendMessage( _, _, _):
            return .post
        case .completeDelivery( _, _, _):
            return .post
        case .reDeliveryHistory( _, _, _):
            return .get
        case .reDeliveryTry( _, _, _):
            return .post
        case .packageDeliveryHistory( _, _, _):
            return .get
        case .ordersToPickup( _, _, _):
            return .get
        case .ordersToDropoff( _, _, _):
            return .get
        case .fetchScanBatchID( _, _, _):
            return .post
        case .checkPickupScanned( _, _, _):
            return .post
        case .closeReopenBatch( _, _, _):
            return .put
        case .pickupScanReport( _, _, _):
            return .post
        case .servicePointInfo( _, _, _):
            return .get
        case .completeDropoffScan( _, _, _):
            return .post
        case .businessPickupScanList( _, _, _):
            return .get
        case .businessPickupScanCheck( _, _, _):
            return .post
        case .businessPickupScanSummary( _, _, _):
            return .get
        case .completeBusinessPickupScan( _, _, _):
            return .post
        }
    }
    
    // MARK: - path string
    var path: String {
        switch self {
        case .login( _, _, _):
            return "/auth/login"
        case .fetchDeliveringList( _, _, _):
            return "/delivery/parcels/delivering"
        case .fetchUndeliveredList( _, _, _):
            return "/delivery/parcels/undelivered"
        case .fetchServiceList(let pathParas, _, _):
            if let pathParas = pathParas {
                var pathStr = ""
                for para in pathParas {
                    pathStr += "/\(para)"
                }
                return "/dropoff/assignment/service_point" + pathStr
            } else {
                return "/dropoff/assignment/service_point"
            }
        case .updateAddressType( _, _, _):
            return "/location/deliveredaddress"
        case .fetchLanguageList(let pathParas, _, _):
            if let pathParas = pathParas {
                var pathStr = ""
                for para in pathParas {
                    pathStr += "/\(para)"
                }
                return "/masterdata/message/languages" + pathStr
            } else {
                return "/masterdata/message/languages"
            }
        case .fetchMsgTemplates(let pathParas, _, _):
            if let pathParas = pathParas {
                var pathStr = ""
                for para in pathParas {
                    pathStr += "/\(para)"
                }
                return "/masterdata/message/templates" + pathStr
            } else {
                return "/masterdata/message/templates"
            }
        case .sendMessage( _, _, _):
            return "/delivery/message"
        case .completeDelivery( _, _, _):
            return "/delivery"
        case .reDeliveryHistory(let pathParas, _, _):
            if let pathParas = pathParas {
                var pathStr = ""
                for para in pathParas {
                    pathStr += "/\(para)"
                }
                return "/delivery/retry/brief" + pathStr
            } else {
                return "/delivery/retry/brief"
            }
        case .reDeliveryTry( _, _, _):
            return "/delivery/retry"
        case .packageDeliveryHistory(let pathParas, _, _):
            if let pathParas = pathParas {
                var pathStr = ""
                for para in pathParas {
                    pathStr += "/\(para)"
                }
                return "/delivery/parcels/deliveries" + pathStr
            } else {
                return "/delivery/parcels/deliveries"
            }
        case .ordersToPickup(let pathParas, _, _):
            if let pathParas = pathParas {
                var pathStr = ""
                for para in pathParas {
                    pathStr += "/\(para)"
                }
                return "/delivery/to-be-picked-up/brief" + pathStr
            } else {
                return "/delivery/to-be-picked-up/brief"
            }
        case .ordersToDropoff(let pathParas, _, _):
            if let pathParas = pathParas {
                var pathStr = ""
                for para in pathParas {
                    pathStr += "/\(para)"
                }
                return "/delivery/to-be-dropped-off/brief" + pathStr
            } else {
                return "/delivery/to-be-dropped-off/brief"
            }
        case .fetchScanBatchID( _, _, _):
            return "/delivery/scan/batch"
        case .checkPickupScanned( _, _, _):
            return "/delivery/scan"
        case .closeReopenBatch(let pathParas, _, _):
            if let pathParas = pathParas {
                var pathStr = ""
                for para in pathParas {
                    pathStr += "/\(para)"
                }
                return "/delivery/scan/batch" + pathStr
            } else {
                return "/delivery/scan/batch"
            }
        case .pickupScanReport( _, _, _):
            return "/delivery/scan/batch/report"
        case .servicePointInfo(let pathParas, _, _):
            if let pathParas = pathParas {
                var pathStr = ""
                for para in pathParas {
                    pathStr += "/\(para)"
                }
                return "/dropoff/assignment/service_point" + pathStr
            } else {
                return "/dropoff/assignment/service_point"
            }
        case .completeDropoffScan( _, _, _):
            return "/dropoff/batch"
        case .businessPickupScanList( _, _, _):
            return "/driver/querymanifestlist"
        case .businessPickupScanCheck( _, _, _):
            return "/driver/updatepickupscanstatus"
        case .businessPickupScanSummary( _, _, _):
            return "/driver/getscansummary"
        case .completeBusinessPickupScan( _, _, _):
            return "/driver/completepickupscan"
        }
    }
    
    // MARK: - query parameters like ...?key=value
    var queryItems: [URLQueryItem]? {
        switch self {
        case .login( _, _, _):
            return nil
        case .fetchDeliveringList( _, let queryParas, _),
                .fetchUndeliveredList( _, let queryParas, _),
                .fetchServiceList( _, let queryParas, _),
                .updateAddressType( _, let queryParas, _),
                .fetchLanguageList( _, let queryParas, _),
                .fetchMsgTemplates( _, let queryParas, _),
                .sendMessage( _, let queryParas, _),
                .completeDelivery( _, let queryParas, _),
                .reDeliveryHistory( _, let queryParas, _),
                .reDeliveryTry( _, let queryParas, _),
                .packageDeliveryHistory( _, let queryParas, _),
                .ordersToPickup( _, let queryParas, _),
                .ordersToDropoff( _, let queryParas, _),
                .fetchScanBatchID( _, let queryParas, _),
                .checkPickupScanned( _, let queryParas, _),
                .closeReopenBatch( _, let queryParas, _),
                .pickupScanReport( _, let queryParas, _),
                .servicePointInfo( _, let queryParas, _),
                .completeDropoffScan( _, let queryParas, _),
                .businessPickupScanList( _, let queryParas, _),
                .businessPickupScanCheck( _, let queryParas, _),
                .businessPickupScanSummary( _, let queryParas, _),
                .completeBusinessPickupScan( _, let queryParas, _):
            if let query = queryParas {
                return query.map({
                    URLQueryItem(name: $0.key, value: $0.value)
                })
            } else {
                return nil
            }
        }
    }
    
    // MARK: - body parameters
    var bodyParameters: [String:Any?]? {
        switch self {
        case .login( _, _, let bodyParas):
            return bodyParas
        case .fetchDeliveringList( _, _, let bodyParas):
            return bodyParas
        case .fetchUndeliveredList( _, _, let bodyParas):
            return bodyParas
        case .fetchServiceList( _, _, let bodyParas):
            return bodyParas
        case .updateAddressType( _, _, let bodyParas):
            return bodyParas
        case .fetchLanguageList( _, _, let bodyParas):
            return bodyParas
        case .fetchMsgTemplates( _, _, let bodyParas):
            return bodyParas
        case .sendMessage( _, _, let bodyParas):
            return bodyParas
        case .completeDelivery( _, _, let bodyParas):
            return bodyParas
        case .reDeliveryHistory( _, _, let bodyParas):
            return bodyParas
        case .reDeliveryTry( _, _, let bodyParas):
            return bodyParas
        case .packageDeliveryHistory( _, _, let bodyParas):
            return bodyParas
        case .ordersToPickup( _, _, let bodyParas):
            return bodyParas
        case .ordersToDropoff( _, _, let bodyParas):
            return bodyParas
        case .fetchScanBatchID( _, _, let bodyParas):
            return bodyParas
        case .checkPickupScanned( _, _, let bodyParas):
            return bodyParas
        case .closeReopenBatch( _, _, let bodyParas):
            return bodyParas
        case .pickupScanReport( _, _, let bodyParas):
            return bodyParas
        case .servicePointInfo( _, _, let bodyParas):
            return bodyParas
        case .completeDropoffScan( _, _, let bodyParas):
            return bodyParas
        case .businessPickupScanList( _, _, let bodyParas):
            return bodyParas
        case .businessPickupScanCheck( _, _, let bodyParas):
            return bodyParas
        case .businessPickupScanSummary( _, _, let bodyParas):
            return bodyParas
        case .completeBusinessPickupScan( _, _, let bodyParas):
            return bodyParas
        }
    }
    
    // MARK: - URLRequest creating
    func makeURLRequest() throws -> URLRequest {
        
        let fullPath = baseURL + path
        guard var urlComponent = URLComponents(string: fullPath) else {
            throw NetworkRequestError.invalidURL(description: "\(fullPath)")
        }
        
        if let query = queryItems {
            urlComponent.queryItems = query
        }
        
        guard let url = urlComponent.url else {
            throw NetworkRequestError.invalidURL(description: "\(fullPath)")
        }
        var urlRequest = URLRequest(url: url)
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        let tempToken = AppConfigurator.shared.token
        // Headers
        let bearer = "Bearer \(tempToken)"
        urlRequest.setValue(bearer, forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        switch self {
        case .completeDelivery( _, _, let bodyParas):
            if var paras = bodyParas {
                let boundary = "Boundary-\(UUID().uuidString)"
                urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                let images = paras.removeValue(forKey: "pod_images")
                let body = self.createFormData(boundary: boundary, paras: paras, imagesKey: "pod_images[]", images: images as? [Any])
                urlRequest.setValue(String(body.count), forHTTPHeaderField: "Content-Length")
                urlRequest.httpBody = body
            }
        case .reDeliveryTry( _, _, let bodyParas):
            if var paras = bodyParas {
                let boundary = "Boundary-\(UUID().uuidString)"
                urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                let images = paras.removeValue(forKey: "pod_img")
                let body = self.createFormData(boundary: boundary, paras: paras, imagesKey: "pod_img[]", images: images as? [Any])
                urlRequest.setValue(String(body.count), forHTTPHeaderField: "Content-Length")
                urlRequest.httpBody = body
            }
        case .completeDropoffScan( _, _, let bodyParas):
            if var paras = bodyParas {
                let boundary = "Boundary-\(UUID().uuidString)"
                urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                let image = paras.removeValue(forKey: "signature")
                let body = self.createFormData(boundary: boundary, paras: paras, imageKey: "signature", image: image as Any?)
                urlRequest.setValue(String(body.count), forHTTPHeaderField: "Content-Length")
                urlRequest.httpBody = body
            }
        case .completeBusinessPickupScan( _, _, let bodyParas):
            if var paras = bodyParas {
                let boundary = "Boundary-\(UUID().uuidString)"
                urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                let image = paras.removeValue(forKey: "signature")
                let body = self.createFormData(boundary: boundary, paras: paras, imageKey: "signature", image: image as Any?)
                urlRequest.setValue(String(body.count), forHTTPHeaderField: "Content-Length")
                urlRequest.httpBody = body
            }
        default:
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            // body parameters
            if let body = bodyParameters {
                let body = body.compactMapValues { $0 }
                do {
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
                } catch _ {
                    throw NetworkRequestError.bodyToJSON(description: "Body parameters serialization error for URL: \(fullPath)")
                }
            }
        }
        return urlRequest
    }
    
    // MARK: - network by urlsession (Combine framework)
    func fetchJSON<T>(request: URLRequest) -> AnyPublisher<T, NetworkRequestError> where T: Decodable {
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { error in
                NetworkRequestError.netConnection(description: error.localizedDescription)
            }
            .tryMap { element in
                let httpResponse = element.response as? HTTPURLResponse
                if let httpResponse = httpResponse, httpResponse.statusCode == 200 {
                    switch self {
                    case .completeDelivery( _, _, _):
                        //let kk = String(data: element.data, encoding: .utf8)
                        //print("cheng=data= \(kk)")
                        break
                    default:
                        break
                    }
                    return element.data
                } else if let httpResponse = httpResponse, httpResponse.statusCode == 403 {
                    if case .checkPickupScanned( _, _, _) = self {
                        return element.data
                    } else {
                        throw NetworkRequestError.failStatusCode(description: "Status code: \(403)")
                    }
                } else if let statusCode = httpResponse?.statusCode {
                    throw NetworkRequestError.failStatusCode(description: "Status code: \(statusCode)")
                } else {
                    throw NetworkRequestError.other(description: "")
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if error is Swift.DecodingError {
                    return NetworkRequestError.parsingResponseData(description: error.localizedDescription)
                } else if let err = error as? NetworkRequestError {
                    return err
                } else {
                    return NetworkRequestError.other(description: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func createFormData(boundary: String, paras: [String:Any?]?, imagesKey: String, images: [Any]?) -> Data {
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        let imgType = "image/jpeg"
        if let paras = paras {
            for (key, value) in paras {
                if let value = value {
                    body.append(boundaryPrefix.data(using: .utf8) ?? Data())
                    body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8) ?? Data())
                    body.append("\(value)\r\n".data(using: .utf8) ?? Data())
                }
            }
        }
        if let images = images as? [Data], images.count > 0 {
            var fileName: String
            for (ind, img) in images.enumerated() {
                fileName = "image\(ind).jpeg"
                body.append(boundaryPrefix.data(using: .utf8) ?? Data())
                body.append("Content-Disposition: form-data; name=\"\(imagesKey)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8) ?? Data())
                body.append("Content-Type: \(imgType)\r\n\r\n".data(using: .utf8) ?? Data())
                body.append(img)
                body.append("\r\n".data(using: .utf8) ?? Data())
            }
            body.append("--\(boundary)--\r\n".data(using: .utf8) ?? Data())
        }
        return body
    }
    
    private func createFormData(boundary: String, paras: [String:Any?]?, imageKey: String, image: Any?) -> Data {
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        if let paras = paras {
            for (key, value) in paras {
                if let value = value {
                    body.append(boundaryPrefix.data(using: .utf8) ?? Data())
                    body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8) ?? Data())
                    body.append("\(value)\r\n".data(using: .utf8) ?? Data())
                }
            }
        }
        let imgType = "image/jpeg"
        if let image = image as? Data {
            let fileName: String = "image.jpeg"
            body.append(boundaryPrefix.data(using: .utf8) ?? Data())
            body.append("Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8) ?? Data())
            body.append("Content-Type: \(imgType)\r\n\r\n".data(using: .utf8) ?? Data())
            body.append(image)
            body.append("\r\n".data(using: .utf8) ?? Data())
            body.append("--\(boundary)--\r\n".data(using: .utf8) ?? Data())
        }
        return body
    }
}
