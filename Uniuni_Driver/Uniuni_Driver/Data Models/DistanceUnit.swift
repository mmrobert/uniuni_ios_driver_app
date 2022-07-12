//
//  DistanceUnit.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-09.
//

import Foundation

enum DistanceUnit: String {
    case KM
    case MI
    
    func getDisplayString() -> String {
        switch self {
        case .KM:
            return "KM"
        case .MI:
            return "MI"
        }
    }
    
    static func getSortFrom(description: String?) -> PackageSort? {
        guard let description = description else {
            return nil
        }
        return PackageSort(rawValue: description)
    }
}
