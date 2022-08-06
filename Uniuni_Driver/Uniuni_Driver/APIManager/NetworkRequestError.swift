//
//  NetworkRequestError.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-30.
//

import Foundation

enum NetworkRequestError: Error {
    case invalidURL(description: String)
    case netConnection(description: String)
    case bodyToJSON(description: String)
    case parsingResponseData(description: String)
    case failStatusCode(description: String)
    case other(description: String)
    
    var description: String {
        switch self {
        case .invalidURL(let description):
            return String.wrongURLStr + ": " + description
        case .netConnection(let description):
            return String.badInternetConnectionStr + ": " + description
        case .bodyToJSON(let description):
            return description
        case .parsingResponseData(let description):
            return description
        case .failStatusCode(let description):
            return description
        case .other(let description):
            return description
        }
    }
}
