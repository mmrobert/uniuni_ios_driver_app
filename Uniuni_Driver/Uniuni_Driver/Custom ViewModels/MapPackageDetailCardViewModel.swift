//
//  MapPackageDetailCardViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-17.
//

import Foundation
import UIKit

class MapPackageDetailCardViewModel {
    
    var orderSN: String?
    var orderId: Int?
    var trackingNo: String?
    var routeNo: Int?
    var addressType: AddressType?
    var name: String?
    var phone: String?
    var address: String?
    var lat: String?
    var lng: String?
    var distance: Double?
    var distanceUnit: DistanceUnit?
    var goodsType: GoodsType?
    var expressType: ExpressType?
    var assignedTime: String?
    var deliveryBy: String?
    var buzz: String?
    var note: String?
    var warehouseID: Int?
    var needRetry: Int?
    var failedButtonTitle: String?
    var deliveredButtonTitle: String?

    init(orderSN: String?,
         orderId: Int?,
         trackingNo: String?,
         routeNo: Int?,
         addressType: AddressType?,
         name: String?,
         phone: String?,
         address: String?,
         lat: String?,
         lng: String?,
         distance: Double?,
         distanceUnit: DistanceUnit?,
         goodsType: GoodsType?,
         expressType: ExpressType?,
         assignedTime: String?,
         deliveryBy: String?,
         buzz: String?,
         note: String?,
         warehouseID: Int?,
         needRetry: Int?,
         failedButtonTitle: String?,
         deliveredButtonTitle: String?) {

        self.orderSN = orderSN
        self.orderId = orderId
        self.trackingNo = trackingNo
        self.routeNo = routeNo
        self.addressType = addressType
        self.name = name
        self.phone = phone
        self.address = address
        self.lat = lat
        self.lng = lng
        self.distance = distance
        self.distanceUnit = distanceUnit
        self.goodsType = goodsType
        self.expressType = expressType
        self.assignedTime = assignedTime
        self.deliveryBy = deliveryBy
        self.buzz = buzz
        self.note = note
        self.warehouseID = warehouseID
        self.needRetry = needRetry
        self.failedButtonTitle = failedButtonTitle
        self.deliveredButtonTitle = deliveredButtonTitle
    }
    
    init(packageViewModel: PackageViewModel, location: (lat: Double, lng: Double), failedButtonTitle: String?, deliveredButtonTitle: String?) {
        self.orderSN = packageViewModel.order_sn
        self.orderId = packageViewModel.order_id
        self.trackingNo = packageViewModel.tracking_no
        self.routeNo = packageViewModel.route_no
        self.addressType = packageViewModel.address_type
        self.name = packageViewModel.name
        self.phone = packageViewModel.mobile
        self.address = packageViewModel.address
        self.lat = packageViewModel.lat
        self.lng = packageViewModel.lng
        self.distance = packageViewModel.getDistanceFrom(location: location, distanceUnit: .KM)
        self.distanceUnit = .KM
        self.goodsType = packageViewModel.goods_type
        self.expressType = packageViewModel.express_type
        self.assignedTime = packageViewModel.assign_time
        self.deliveryBy = packageViewModel.delivery_by
        self.buzz = packageViewModel.buzz_code
        self.note = packageViewModel.postscript
        self.warehouseID = packageViewModel.warehouse_id
        self.needRetry = packageViewModel.need_retry
        self.failedButtonTitle = failedButtonTitle
        self.deliveredButtonTitle = deliveredButtonTitle
    }
    
    func getDeliveryAttemptValue() -> String {
        String(format: String.deliveryAttemptValueStr, "1", "3")
    }
}
