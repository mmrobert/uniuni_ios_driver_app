//
//  MessageTemplatesListDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-08-02.
//

import Foundation

struct MessageTemplatesListDataModel: Codable {
    var biz_code: String?
    var biz_message: String?
    var biz_data: [MessageTemplateDataModel]?
}

struct MessageTemplateDataModel: Codable {
    var id: Int?
    var title: String?
}
