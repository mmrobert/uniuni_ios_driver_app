//
//  UpdateAddressTypeResponse.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-08-04.
//

import Foundation

struct UpdateAddressTypeResponse: Codable {
    var status: String?
    var ret_msg: String?
    var err_code: Int?
    var data: ResponseData?
    
    struct ResponseData: Codable {
        var address: String?
        var postal_code: String?
    }
}
