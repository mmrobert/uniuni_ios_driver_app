//
//  OrdersToPickupDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-04.
//

import Foundation

struct OrdersToPickupDataModel: Codable {
    var biz_code: String?
    var biz_message: String?
    var biz_data: OrdersToPickup?
}

struct OrdersToPickup: Codable {
    var total_number: Int?
    var address: String?
}
