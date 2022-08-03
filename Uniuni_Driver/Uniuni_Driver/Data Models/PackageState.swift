//
//  PackageState.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-06.
//

import Foundation

enum PackageState: Int, Codable {
    case delivering = 202
    case undelivered = 211
    
    func getDisplayString() -> String {
        switch self {
        case .delivering:
            return String.deliveringStr
        case .undelivered:
            return String.undeliveredStr
        }
    }
    
    static func getStateFrom(value: Int?) -> PackageState? {
        guard let value = value else {
            return nil
        }
        return PackageState(rawValue: value)
    }
}
