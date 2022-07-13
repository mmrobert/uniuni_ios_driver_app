//
//  MapPackageCardViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-09.
//

import Foundation
import UIKit

class MapPackageCardViewModel {
    
    var trackingNo: String?
    var goodsType: GoodsType?
    var expressType: ExpressType?
    var receiverAddress: String?
    var receiverZipcode: String?
    var receiverDistance: Double?
    var distanceUnit: DistanceUnit?
    var buttonTitle: String?

    init(trackingNo: String?,
         goodsType: GoodsType?,
         expressType: ExpressType?,
         receiverAddress: String?,
         receiverZipcode: String?,
         receiverDistance: Double?,
         distanceUnit: DistanceUnit?,
         buttonTitle: String?) {

        self.trackingNo = trackingNo
        self.goodsType = goodsType
        self.expressType = expressType
        self.receiverAddress = receiverAddress
        self.receiverZipcode = receiverZipcode
        self.receiverDistance = receiverDistance
        self.distanceUnit = distanceUnit
        self.buttonTitle = buttonTitle
    }
    
    init(packageViewModel: PackageViewModel, location: (lat: Double, lng: Double), buttonTitle: String?) {
        self.trackingNo = packageViewModel.tracking_no
        self.goodsType = packageViewModel.goods_type
        self.expressType = packageViewModel.express_type
        self.receiverAddress = packageViewModel.address
        self.receiverZipcode = packageViewModel.zipcode
        self.receiverDistance = packageViewModel.getDistanceFrom(location: location, distanceUnit: .KM)
        self.distanceUnit = .KM
        self.buttonTitle = buttonTitle
    }
}
