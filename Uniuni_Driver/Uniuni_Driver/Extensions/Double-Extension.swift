//
//  Double-Extension.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-05.
//

import Foundation

extension Double {
    
    func kmDistance() -> String {
        return String(format: "%.1f", self) + String.KMAwayStr
    }
    
    func miDistance() -> String {
        return String(format: "%.1f", self) + String.MIAwayStr
    }
}
