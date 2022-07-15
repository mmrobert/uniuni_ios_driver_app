//
//  ServicePointDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-12.
//

import Foundation

struct ServicePointDataModel {
    var biz_code: String?
    var biz_message: String?
    var biz_data: Biz_Data?
    
    struct Biz_Data {
        var id: Int?
        var name: String?
        var address: String?
        var lat: Double?
        var lng: Double?
    }
}
