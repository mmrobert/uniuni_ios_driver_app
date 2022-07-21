//
//  MapPackageDetailCardViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-17.
//

import Foundation
import UIKit

class MapPackageDetailCardViewModel {
    
    var routeNo: Int?
    var addressType: Int?
    var name: String?
    var phone: String?
    var address: String?
    var distance: Double?
    var distanceUnit: DistanceUnit?
    var expressType: ExpressType?
    var assignedTime: String?
    var deliveryBy: String?
    var buzz: String?
    var note: String?
    var failedButtonTitle: String?
    var deliveredButtonTitle: String?

    init(routeNo: Int?,
         addressType: Int?,
         name: String?,
         phone: String?,
         address: String?,
         distance: Double?,
         distanceUnit: DistanceUnit?,
         expressType: ExpressType?,
         assignedTime: String?,
         deliveryBy: String?,
         buzz: String?,
         note: String?,
         failedButtonTitle: String?,
         deliveredButtonTitle: String?) {

        self.routeNo = routeNo
        self.addressType = addressType
        self.name = name
        self.phone = phone
        self.address = address
        self.distance = distance
        self.distanceUnit = distanceUnit
        self.expressType = expressType
        self.assignedTime = assignedTime
        self.deliveryBy = deliveryBy
        self.buzz = buzz
        self.note = note
        self.failedButtonTitle = failedButtonTitle
        self.deliveredButtonTitle = deliveredButtonTitle
    }
    
    init(packageViewModel: PackageViewModel, location: (lat: Double, lng: Double), failedButtonTitle: String?, deliveredButtonTitle: String?) {
        self.routeNo = packageViewModel.route_no
        
        self.addressType = 1
        
        self.name = packageViewModel.name
        self.phone = packageViewModel.mobile
        self.address = packageViewModel.address
        self.distance = packageViewModel.getDistanceFrom(location: location, distanceUnit: .KM)
        self.distanceUnit = .KM
        self.expressType = packageViewModel.express_type
        self.assignedTime = packageViewModel.assign_time
        self.deliveryBy = packageViewModel.delivery_by
        self.buzz = packageViewModel.buzz_code
        self.note = ""
        
        self.failedButtonTitle = failedButtonTitle
        self.deliveredButtonTitle = deliveredButtonTitle
    }
}
