//
//  AppGlobalVariables.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-10.
//

import Foundation
import Combine

class AppGlobalVariables: ObservableObject {
    
    static let shared = AppGlobalVariables()
    
    private init() {}
    
    @Published var tabBarHiden: Bool = false
    @Published var packagesListUpdated: Bool = false
    
    var originOfDeliveryFlow: OriginOfDeliveryFlow = .fromMap
    
    enum OriginOfDeliveryFlow {
        case fromList
        case fromMap
    }
}
