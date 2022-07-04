//
//  TopActionSheetViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-28.
//

import Foundation
import UIKit

struct TopActionSheetViewModel {
 
    let title: String
    let actions: [Action]
    
    struct Action {
        var title: String
        var handler: ((String?) -> Void)?
 
        init(title: String, handler: ((String?) -> Void)? = nil) {
            self.title = title
            self.handler = handler
        }
    }
}
