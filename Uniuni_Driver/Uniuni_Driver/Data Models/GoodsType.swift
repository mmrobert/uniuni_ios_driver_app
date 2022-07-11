//
//  GoodsType.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-06.
//

import Foundation

enum GoodsType: Int {
    case regular = 0
    case medical = 1
    
    func getDisplayString() -> String {
        switch self {
        case .regular:
            return String.regularStr
        case .medical:
            return String.medicalStr
        }
    }
    
    static func getTypeFrom(value: Int?) -> GoodsType? {
        guard let value = value else {
            return nil
        }
        return GoodsType(rawValue: value)
    }
}
