//
//  BusinessPickupScanSummaryDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-09.
//

import Foundation

struct BusinessPickupScanSummaryDataModel: Codable {
    var status: String?
    var ret_msg: String?
    var err_code: Int?
    var data: SummaryData?
    
    struct SummaryData: Codable {
        var pickup_time: Int?
        var manifest_no: String?
        var total_count: Int?
        var scanned_count: Int?
        var addon_orders: [String]?
        var unfound_orders: [String]?
        var unscan_orders: [String]?
    }
}
