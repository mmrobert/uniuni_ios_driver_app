//
//  FailedHandleType.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-06.
//

import Foundation

enum FailedHandleType: Int, Codable {
    case returned = 0
    case drop_off = 1
    
    func getDisplayString() -> String {
        switch self {
        case .returned:
            return String.returnedStr
        case .drop_off:
            return String.dropOffStr
        }
    }
    
    static func getTypeFrom(value: Int?) -> FailedHandleType? {
        guard let value = value else {
            return nil
        }
        return FailedHandleType(rawValue: value)
    }
}
