//
//  AppConfigurator.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-29.
//

import Foundation

struct AppConfigurator {
    
    static let shared = AppConfigurator()
    
    public var targetName: String? {
        return Bundle.main.infoDictionary?["TargetName"] as? String
    }
    
    public var baseURL: String {
        if targetName == "Uniuni_Driver" {
            return "https://deliverydev.uniexpress.ca"
        } else {
            return ""
        }
    }
}
