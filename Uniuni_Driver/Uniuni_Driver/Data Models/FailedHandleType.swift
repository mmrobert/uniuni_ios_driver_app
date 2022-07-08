//
//  FailedHandleType.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-06.
//

import Foundation

enum FailedHandleType: Int {
    case wrongAddress = 0
    
    func getDisplayString() -> String {
        switch self {
        case .wrongAddress:
            return String.wrongAddressStr
        }
    }
    
    static func getTypeFrom(value: Int?) -> FailedHandleType? {
        guard let value = value else {
            return nil
        }
        return FailedHandleType(rawValue: value)
    }
}
