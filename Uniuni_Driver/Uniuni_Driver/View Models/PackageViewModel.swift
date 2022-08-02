//
//  PackageViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-06.
//

import Foundation
import Combine

struct PackageViewModel: Identifiable, Equatable {
    var id = UUID()
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
    var address_type: AddressType?
    var zipcode: String?
    var lat: String?
    var lng: String?
    var buzz_code: String?
    var postscript: String?
    var warehouse_id: Int?
    var failed_handle_type: FailedHandleType?
    
    init(dataModel: PackageDataModel) {
        self.order_id = dataModel.order_id
        self.order_sn = dataModel.order_sn
        self.tracking_no = dataModel.tracking_no
        self.goods_type = dataModel.goods_type
        self.express_type = dataModel.express_type
        self.route_no = dataModel.route_no
        self.assign_time = dataModel.assign_time
        self.delivery_by = dataModel.delivery_by
        self.state = dataModel.state
        self.name = dataModel.name
        self.mobile = dataModel.mobile
        self.address = dataModel.address
        self.address_type = dataModel.address_type
        self.zipcode = dataModel.zipcode
        self.lat = dataModel.lat
        self.lng = dataModel.lng
        self.buzz_code = dataModel.buzz_code
        self.postscript = dataModel.postscript
        self.warehouse_id = dataModel.warehouse_id
        self.failed_handle_type = dataModel.failed_handle_type
    }
    
    func getDistanceFrom(location: (lat: Double, lng: Double), distanceUnit: DistanceUnit) -> Double {
        
        let packLng = Double(self.lng ?? "") ?? -122.0
        let theta = location.lng - packLng
        let packLat = Double(self.lat ?? "") ?? 49.0
        var dist = sin(deg2rad(deg: location.lat)) * sin(deg2rad(deg: packLat)) + cos(deg2rad(deg: location.lat)) * cos(deg2rad(deg: packLat)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515
        
        switch distanceUnit {
        case .KM:
            dist = dist * 1.609344
        case .MI:
            dist = dist * 1.0
        }
        
        return dist
    }
    
    private func deg2rad(deg: Double) -> Double {
        return deg * Double.pi / 180
    }
    
    private func rad2deg(rad: Double) -> Double {
        return rad * 180.0 / Double.pi
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.order_sn == rhs.order_sn
    }
}
