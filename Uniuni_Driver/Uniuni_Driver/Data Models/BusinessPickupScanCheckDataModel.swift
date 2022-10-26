//
//  BusinessPickupScanCheckDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-09.
//

import Foundation

struct BusinessPickupScanCheckDataModel: Codable {
    var status: String?
    var ret_msg: String?
    var err_code: Int?
    var data: ItemData?
    
    struct ItemData: Codable {
        var order_id: Int?
        var order_sn: String?
        var enpathInfo: String?
        var pathAddr: String?
        var pathInfo: String?
        var rcountry: String?
        var state: Int?
        var grid_code: Int?
        var tno: String?
        var segment: String?
    }
}
