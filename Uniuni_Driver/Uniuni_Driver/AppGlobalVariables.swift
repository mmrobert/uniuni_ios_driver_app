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
    
}
