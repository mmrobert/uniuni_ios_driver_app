//
//  PackageCardViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-25.
//

import Foundation
import UIKit

class PackageCardViewModel {
    
    var trackingNo: String?
    var goodsType: GoodsType?
    var expressType: ExpressType?
    var routeNo: Int?
    var receiverName: String?
    var receiverAddress: String?
    var receiverDistance: String?

    init(trackingNo: String?,
         goodsType: GoodsType?,
         expressType: ExpressType?,
         routeNo: Int?,
         receiverName: String?,
         receiverAddress: String?,
         receiverDistance: String?) {

        self.trackingNo = trackingNo
        self.goodsType = goodsType
        self.expressType = expressType
        self.routeNo = routeNo
        self.receiverName = receiverName
        self.receiverAddress = receiverAddress
        self.receiverDistance = receiverDistance
    }
}
