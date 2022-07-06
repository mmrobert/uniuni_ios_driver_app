//
//  Double-Extension.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-05.
//

import Foundation

extension Double {
    
    func kmDistance() -> String {
        return String(format: "%.0f", self) + String.KMAwayStr
    }
    
    func miDistance() -> String {
        return String(format: "%.0f", self) + String.MIAwayStr
    }
}
