//
//  PickupScanReportDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-04.
//

import Foundation

struct PickupScanReportDataModel: Codable {
    var biz_code: String?
    var biz_message: String?
    var biz_data: PickupScanReportData?
}

struct PickupScanReportData: Codable {
    var scan_time: String?
    var assigned_parcels_count: Int?
    var scanned_parcels_count: Int?
    var unscanned_parcels_count: Int?
    var returned_parcels_count: Int?
    var unscanned_parcels: [Parcel]?
    var returned_parcels: [Parcel]?
    
    struct Parcel: Codable {
        var tracking_no: String?
        var route_no: Int?
    }
}
