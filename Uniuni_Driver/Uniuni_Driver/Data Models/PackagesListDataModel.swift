//
//  PackagesListDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-30.
//

import Foundation

struct PackagesListDataModel: Codable {
    var biz_code: String?
    var biz_message: String?
    var biz_data: [PackageDataModel]?
}
