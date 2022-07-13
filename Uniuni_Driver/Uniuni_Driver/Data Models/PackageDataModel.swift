//
//  PackageDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-06.
//

import Foundation

struct PackageDataModel {
    var order_id: Int?
    var order_sn: String?
    var tracking_no: String?
    var goods_type: GoodsType?
    var express_type: ExpressType?
    var route_no: Int?
    var assign_time: String?    // 2021-11-25 13:38:42
    var delivery_by: String?    // 2021-11-28 13:38:42
    var state: PackageState?
    var name: String?
    var mobile: String?
    var address: String?
    var zipcode: String?
    var lat: String?
    var lng: String?
    var buzz_code: String?
    var postscript: String?
    var failed_handle_type: FailedHandleType?
    
    static func dataModelFrom(viewModel: PackageViewModel) -> PackageDataModel {
        return PackageDataModel(
            order_id: viewModel.order_id,
            order_sn: viewModel.order_sn,
            tracking_no: viewModel.tracking_no,
            goods_type: viewModel.goods_type,
            express_type: viewModel.express_type,
            route_no: viewModel.route_no,
            assign_time: viewModel.assign_time,
            delivery_by: viewModel.delivery_by,
            state: viewModel.state,
            name: viewModel.name,
            mobile: viewModel.mobile,
            address: viewModel.address,
            zipcode: viewModel.zipcode,
            lat: viewModel.lat,
            lng: viewModel.lng,
            buzz_code: viewModel.buzz_code,
            postscript: viewModel.postscript,
            failed_handle_type: viewModel.failed_handle_type
        )
    }
}
