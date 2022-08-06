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
    case fetchDeliveringList(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case fetchUndeliveredList(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case fetchServiceList(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case updateAddressType(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case fetchLanguageList(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case fetchMsgTemplates(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    case sendMessage(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    
    // MARK: - base URL
    var baseURL: String {
        switch self {
        case .updateAddressType( _, _, _):
            return "https://app.test.uniexpress.org"
        default:
            return AppConfigurator.shared.baseURL
        }
    }
    
    // MARK: - Request Method
    var method: RequestMethod {
        switch self {
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
        }
    }
    
    // MARK: - path string
    var path: String {
        switch self {
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
        }
    }
    
    // MARK: - query parameters like ...?key=value
    var queryItems: [URLQueryItem]? {
        switch self {
        case .fetchDeliveringList( _, let queryParas, _):
            if let query = queryParas {
                return query.map({
                    URLQueryItem(name: $0.key, value: $0.value)
                })
            } else {
                return nil
            }
        case .fetchUndeliveredList( _, let queryParas, _):
            if let query = queryParas {
                return query.map({
                    URLQueryItem(name: $0.key, value: $0.value)
                })
            } else {
                return nil
            }
        case .fetchServiceList( _, let queryParas, _):
            if let query = queryParas {
                return query.map({
                    URLQueryItem(name: $0.key, value: $0.value)
                })
            } else {
                return nil
            }
        case .updateAddressType( _, let queryParas, _):
            if let query = queryParas {
                return query.map({
                    URLQueryItem(name: $0.key, value: $0.value)
                })
            } else {
                return nil
            }
        case .fetchLanguageList( _, let queryParas, _):
            if let query = queryParas {
                return query.map({
                    URLQueryItem(name: $0.key, value: $0.value)
                })
            } else {
                return nil
            }
        case .fetchMsgTemplates( _, let queryParas, _):
            if let query = queryParas {
                return query.map({
                    URLQueryItem(name: $0.key, value: $0.value)
                })
            } else {
                return nil
            }
        case .sendMessage( _, let queryParas, _):
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
        
        // Headers
        let bearer = "Bearer \(AppConstants.token)"
        urlRequest.setValue(bearer, forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        
        // body parameters
        if let body = bodyParameters {
            let body = body.compactMapValues { $0 }
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch _ {
                throw NetworkRequestError.bodyToJSON(description: "Body parameters serialization error for URL: \(fullPath)")
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
                    return element.data
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
}
