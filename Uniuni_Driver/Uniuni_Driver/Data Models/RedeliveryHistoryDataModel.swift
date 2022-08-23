//
//  RedeliveryHistoryDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-08-20.
//

import Foundation

struct RedeliveryHistoryDataModel: Codable {
    var biz_code: String?
    var biz_message: String?
    var biz_data: RedeliveryDataModel?
}

struct RedeliveryDataModel: Codable {
    var retry_times: Int?
    var remaining_time: Int?
}
