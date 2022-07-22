//
//  ServicePointDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-12.
//

import Foundation

struct ServicePointDataModel {
    var biz_code: String?
    var biz_message: String?
    var biz_data: Biz_Data?
    
    struct Biz_Data {
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
