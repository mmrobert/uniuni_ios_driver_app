//
//  LoginDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-29.
//

import Foundation

struct LoginDataModel: Codable {
    var biz_code: String?
    var biz_message: String?
    var biz_data: LoginData?
    
    struct LoginData: Codable {
        var access_token: String?
        var token_type: String?
        var expires_in: Int?
    }
}
