//
//  OrdersToDropoffDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-04.
//

import Foundation

struct OrdersToDropoffDataModel: Codable {
    var biz_code: String?
    var biz_message: String?
    var biz_data: OrdersToDropoff?
}

struct OrdersToDropoff: Codable {
    var total_number: Int?
    var address: String?
}
