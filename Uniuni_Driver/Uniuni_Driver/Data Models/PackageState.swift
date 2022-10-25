//
//  PackageState.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-06.
//

import Foundation

enum PackageState: Int, Codable {
    case delivering
    case delivering231
    case delivering232
    case undelivered211
    case undelivered206
    case none
    
    init(state: Int) {
        switch state {
        case 202: self = .delivering
        case 231: self = .delivering231
        case 232: self = .delivering232
        case 211: self = .undelivered211
        case 206: self = .undelivered206
        default: self = .none
        }
    }
    
    func getDisplayString() -> String {
        switch self {
        case .delivering:
            return String.deliveringStr
        case .delivering231:
            return String.deliveringStr
        case .delivering232:
            return String.deliveringStr
        case .undelivered211:
            return String.undeliveredStr
        case .undelivered206:
            return String.undeliveredStr
        case .none:
            return "None"
        }
    }
    
    static func getStateFrom(value: Int?) -> PackageState? {
        guard let value = value else {
            return nil
        }
        return PackageState(state: value)
    }
    
    static func getIntFrom(state: PackageState?) -> Int {
        guard let state = state else {
            return 0
        }
        switch state {
        case .delivering:
            return 202
        case .delivering231:
            return 231
        case .delivering232:
            return 232
        case .undelivered211:
            return 211
        case .undelivered206:
            return 206
        case .none:
            return 0
        }
    }
}
