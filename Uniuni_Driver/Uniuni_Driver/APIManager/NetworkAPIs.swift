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
    case fetchLanguageList(pathParas: [String]?, queryParas: [String:String]?, bodyParas: [String:Any?]?)
    
    // MARK: - base URL
    var baseURL: String {
        switch self {
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
        case .fetchLanguageList( _, _, _):
            return .get
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
        case .fetchLanguageList( _, let queryParas, _):
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
        case .fetchLanguageList( _, _, let bodyParas):
            return bodyParas
        }
    }
    
    // MARK: - URLRequest creating
    func makeURLRequest() throws -> URLRequest {
        
        let fullPath = baseURL + path
        guard var urlComponent = URLComponents(string: fullPath) else { throw NetworkRequestError.invalidURL(description: "Wrong URL: \(fullPath)") }
        
        if let query = queryItems {
            urlComponent.queryItems = query
        }
        
        guard let url = urlComponent.url else { throw NetworkRequestError.invalidURL(description: "Wrong URL: \(fullPath)") }
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
            } catch let error {
                throw NetworkRequestError.bodyToJSON(description: "Body serialization error: \(error.localizedDescription)")
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
            .flatMap(maxPublishers: .max(1)) { response in
                decode(response.data)
            }
            .eraseToAnyPublisher()
    }
    
    private func decode<T>(_ data: Data) -> AnyPublisher<T, NetworkRequestError> where T: Decodable {
        let decoder = JSONDecoder()
        return Just(data)
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                NetworkRequestError.parsingResponseData(description: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}
