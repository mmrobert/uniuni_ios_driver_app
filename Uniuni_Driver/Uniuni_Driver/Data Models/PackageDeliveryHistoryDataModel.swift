//
//  PackageDeliveryHistoryDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-22.
//

import Foundation

struct PackageDeliveryHistoryDataModel: Codable {
    var biz_code: String?
    var biz_message: String?
    var biz_data: [DeliveryHistory]?
    
    struct DeliveryHistory: Codable {
        var delivery_time: String?
        var status: Int?
        var failed_reason: Int?
        var pods: [String]?
    }
}
