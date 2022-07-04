//
//  PackageCardViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-25.
//

import Foundation
import UIKit

class PackageCardViewModel {
    
    var packageNo: String?
    var medicalIcon: UIImage?
    var packageType: PackageType?
    var routeNo: String?
    var receiverName: String?
    var receiverAddress: String?
    var receiverDistance: String?

    init(packageNo: String?,
         medicalIcon: UIImage?,
         packageType: PackageType?,
         routeNo: String?,
         receiverName: String?,
         receiverAddress: String?,
         receiverDistance: String?) {

        self.packageNo = packageNo
        self.medicalIcon = medicalIcon
        self.packageType = packageType
        self.routeNo = routeNo
        self.receiverName = receiverName
        self.receiverAddress = receiverAddress
        self.receiverDistance = receiverDistance
    }
}
