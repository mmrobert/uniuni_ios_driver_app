//
//  FailedHandleType.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-06.
//

import Foundation

enum FailedHandleType: Int, Codable {
    case wrongAddress = 0
    case damaged = 1
    
    func getDisplayString() -> String {
        switch self {
        case .wrongAddress:
            return String.wrongAddressStr
        case .damaged:
            return ""
        }
    }
    
    static func getTypeFrom(value: Int?) -> FailedHandleType? {
        guard let value = value else {
            return nil
        }
        return FailedHandleType(rawValue: value)
    }
}
