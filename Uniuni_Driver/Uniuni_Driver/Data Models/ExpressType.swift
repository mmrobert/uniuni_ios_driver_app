//
//  ExpressType.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-06.
//

import Foundation

enum ExpressType: Int, Codable {
    case regular = 0
    case express = 1
    
    func getDisplayString() -> String {
        switch self {
        case .regular:
            return String.regularStr
        case .express:
            return String.expressStr
        }
    }
    
    static func getTypeFrom(value: Int?) -> ExpressType? {
        guard let value = value else {
            return nil
        }
        return ExpressType(rawValue: value)
    }
}
