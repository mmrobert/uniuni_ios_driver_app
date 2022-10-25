//
//  ServicePointInfoDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-11.
//

import Foundation

struct ServicePointInfoDataModel: Codable {
    var biz_code: String?
    var biz_message: String?
    var biz_data: ServicePointInfo?
    
    struct ServicePointInfo: Codable {
        var id: Int?
        var name: String?
        var uni_operator_id: Int?
        var type: Int?
        var code: String?
        var address: String?
        var lat: Double?
        var lng: Double?
        var district: Int?
        var business_hours: String?
        var unit_number: String?
        var phone: String?
        var partner_id: Int?
        var company: String?
        var is_active: Int?
        var warehouse: Int?
        var premise_type: String?
        var device: String?
        var contact: String?
        var login: String?
        var password: String?
        var verification_code: Int?
        var storage_space: Int?
        var remark: String?
    }
}
