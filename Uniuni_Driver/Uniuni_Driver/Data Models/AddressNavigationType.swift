//
//  AddressNavigationType.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-27.
//

import Foundation

enum AddressNavigationType: Int, Codable {
    case appleMap = 0
    case googleMap = 1
    case inAppMap = 2
    case copyAddress = 3
    
    func getDisplayString() -> String {
        switch self {
        case .appleMap:
            return String.appleMapStr
        case .googleMap:
            return String.googleMapStr
        case .inAppMap:
            return String.inAppMapStr
        case .copyAddress:
            return String.copyAddressStr
        }
    }
    
    static func getTypeFrom(value: Int?) -> AddressNavigationType? {
        guard let value = value else {
            return nil
        }
        return AddressNavigationType(rawValue: value)
    }
}
