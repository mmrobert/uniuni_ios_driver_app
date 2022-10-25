//
//  BusinessPickupScanListDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-09.
//

import Foundation

struct BusinessPickupScanListDataModel: Codable {
    var status: String?
    var ret_msg: String?
    var err_code: Int?
    var data: [ListItem]?
    
    struct ListItem: Codable {
        var id: Int?
        var manifest_no: String?
        var create_time: Int?
        var creator: String?
        var total_count: Int?
        var status: Int?
        var partner_id: Int?
        var pickup_driver: Int?
        var pickup_time: Int?
        var signature_file: String?
        var deleted: Int?
        var partner_name: String?
        var scanned_count: Int?
    }
}
