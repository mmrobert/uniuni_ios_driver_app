//
//  BusinessPickupScanCompleteDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-09.
//

import Foundation

struct BusinessPickupScanCompleteDataModel: Codable {
    var status: String?
    var ret_msg: String?
    var err_code: Int?
    var data: CompleteData?
    
    struct CompleteData: Codable {
        var manifest_no: String?
        var signature_file: String?
        var saved: Bool?
    }
}
