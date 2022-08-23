//
//  ViewHidenModifier.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-08-17.
//

import Foundation
import SwiftUI

extension View {
    
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}
