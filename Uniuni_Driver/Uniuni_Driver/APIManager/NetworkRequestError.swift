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
    case other(description: String)
}
