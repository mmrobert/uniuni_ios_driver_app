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
    var state: PackageState?
    var routeNo: Int?
    var receiverName: String?
    var receiverAddress: String?
    var receiverDistance: String?
    var failedHandleType: FailedHandleType?

    init(trackingNo: String?,
         goodsType: GoodsType?,
         expressType: ExpressType?,
         state: PackageState?,
         routeNo: Int?,
         receiverName: String?,
         receiverAddress: String?,
         receiverDistance: String?,
         failedHandleType: FailedHandleType?) {

        self.trackingNo = trackingNo
        self.goodsType = goodsType
        self.expressType = expressType
        self.state = state
        self.routeNo = routeNo
        self.receiverName = receiverName
        self.receiverAddress = receiverAddress
        self.receiverDistance = receiverDistance
        self.failedHandleType = failedHandleType
    }
}
