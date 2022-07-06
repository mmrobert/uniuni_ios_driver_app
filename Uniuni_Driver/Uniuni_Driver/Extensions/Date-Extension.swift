//
//  Date-Extension.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-27.
//

import Foundation

extension Date {
    
    static func dateTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let time = formatter.string(from: Date())
        return time
    }
}
