//
//  PickupGenerateReportViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-04.
//

import Foundation
import Combine

class PickupGenerateReportViewModel: ObservableObject {
    
    @Published var showingProgressView: Bool = false
    
    @Published var showingNetworkErrorAlert: Bool = false
    
    
    
    private var disposables = Set<AnyCancellable>()
    
    init() {}
    
    
}

