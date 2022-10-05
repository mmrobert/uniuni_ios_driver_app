//
//  PickupCheckScannedDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-10.
//

import Foundation

struct PickupCheckScannedDataModel: Codable {
    var biz_code: String?
    var biz_message: String?
    var biz_data: ScannedPackage?
    
    struct ScannedPackage: Codable {
        var order_id: Int?
        var tracking_no: String?
        var route_no: Int?
    }
}
