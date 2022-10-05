//
//  ScanBatchIDDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-10.
//

import Foundation

struct ScanBatchIDDataModel: Codable {
    var biz_code: String?
    var biz_message: String?
    var biz_data: ScanBatchID?
    
    struct ScanBatchID: Codable {
        var scan_batch_id: Int?
    }
}
