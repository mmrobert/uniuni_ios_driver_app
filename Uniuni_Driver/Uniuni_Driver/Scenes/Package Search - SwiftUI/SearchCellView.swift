//
//  SearchCellView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-03.
//

import SwiftUI

struct SearchCellView: View {
    
    private var package: PackageViewModel
    
    init(package: PackageViewModel) {
        self.package = package
    }
    
    var body: some View {
        Text(package.tracking_no ?? "")
    }
}

struct SearchCellView_Previews: PreviewProvider {
    static var previews: some View {
        SearchCellView(package: PackageViewModel(dataModel: PackageDataModel()))
    }
}
