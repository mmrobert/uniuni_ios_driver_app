//
//  ServicePointsListDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-12.
//

import Foundation

struct ServicePointsListDataModel: Codable {
    var biz_code: String?
    var biz_message: String?
    var biz_data: ServicePointDataModel?
}
