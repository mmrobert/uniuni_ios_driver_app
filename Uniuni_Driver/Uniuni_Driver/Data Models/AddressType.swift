//
//  AddressType.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-23.
//

import Foundation

enum AddressType: Int, Codable {
    case house = 0
    case townhouse = 1
    case business = 2
    case apartment = 3
    
    func getDisplayString() -> String {
        switch self {
        case .house:
            return String.houseStr
        case .townhouse:
            return String.townhouseStr
        case .business:
            return String.businessStr
        case .apartment:
            return String.apartmentStr
        }
    }
    
    static func getTypeFrom(value: Int?) -> AddressType? {
        guard let value = value else {
            return nil
        }
        return AddressType(rawValue: value)
    }
}
