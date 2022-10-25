//
//  PackageDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-06.
//

import Foundation

struct PackageDataModel: Codable {
    var order_id: Int?
    var order_sn: String?
    var tracking_no: String?
    var goods_type: GoodsType?
    var express_type: ExpressType?
    var route_no: Int?
    var assign_time: String?    // 2021-11-25 13:38:42
    var delivery_by: String?    // 2021-11-28 13:38:42
    var state: Int?
    var name: String?
    var mobile: String?
    var address: String?
    var address_type: AddressType?
    var zipcode: String?
    var lat: String?
    var lng: String?
    var buzz_code: String?
    var postscript: String?
    var warehouse_id: Int?
    var need_retry: Int?
    var failed_handle_type: FailedHandleType?
    var dispatch_type: DispatchType?
    
    struct DispatchType: Codable {
        var SZ: Int?
        var SG: Int?
    }
    
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
            state: PackageState.getIntFrom(state: viewModel.state),
            name: viewModel.name,
            mobile: viewModel.mobile,
            address: viewModel.address,
            address_type: viewModel.address_type,
            zipcode: viewModel.zipcode,
            lat: viewModel.lat,
            lng: viewModel.lng,
            buzz_code: viewModel.buzz_code,
            postscript: viewModel.postscript,
            warehouse_id: viewModel.warehouse_id,
            need_retry: viewModel.need_retry,
            failed_handle_type: viewModel.failed_handle_type
        )
    }
    
    static func dataModelFrom(mapDetailViewModel: MapPackageDetailCardViewModel) -> PackageDataModel {
        return PackageDataModel(
            order_id: mapDetailViewModel.orderId,
            order_sn: mapDetailViewModel.orderSN,
            tracking_no: mapDetailViewModel.trackingNo,
            goods_type: mapDetailViewModel.goodsType,
            express_type: mapDetailViewModel.expressType,
            route_no: mapDetailViewModel.routeNo,
            assign_time: mapDetailViewModel.assignedTime,
            delivery_by: mapDetailViewModel.deliveryBy,
            state: nil,
            name: mapDetailViewModel.name,
            mobile: mapDetailViewModel.phone,
            address: mapDetailViewModel.address,
            address_type: mapDetailViewModel.addressType,
            zipcode: nil,
            lat: mapDetailViewModel.lat,
            lng: mapDetailViewModel.lng,
            buzz_code: mapDetailViewModel.buzz,
            postscript: mapDetailViewModel.note,
            warehouse_id: mapDetailViewModel.warehouseID,
            need_retry: mapDetailViewModel.needRetry,
            failed_handle_type: nil
        )
    }
}
