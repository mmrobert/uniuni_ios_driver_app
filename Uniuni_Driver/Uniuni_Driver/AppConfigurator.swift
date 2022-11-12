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
            return "https://delivery-service-api.qa.uniuni.ca"
        } else {
            return ""
        }
    }
    
    public var driverID: Int {
        if let id = UserDefaults.standard.object(forKey: AppConstants.userDefaultsKey_driverID) as? Int {
            return id
        } else {
            return AppConstants.driverID
        }
    }
    
    public var token: String {
        if let token = UserDefaults.standard.object(forKey: AppConstants.userDefaultsKey_token) as? String {
            return token
        } else {
            return AppConstants.token
        }
    }
    
    public var vcode: String {
        return AppConstants.vcode
    }
    
    public func setDriverID(driverID: Int) {
        UserDefaults.standard.set(driverID, forKey: AppConstants.userDefaultsKey_driverID)
    }
    
    public func setToken(token: String) {
        UserDefaults.standard.set(token, forKey: AppConstants.userDefaultsKey_token)
    }
}
