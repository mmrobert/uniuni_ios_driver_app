//
//  SearchCellView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-03.
//

import SwiftUI

struct SearchCellView: View {
    
    private var package: PackageViewModel
    @Binding var selectedPackage: PackageViewModel?
    
    init(package: PackageViewModel, selectedPackage: Binding<PackageViewModel?>) {
        self.package = package
        self._selectedPackage = selectedPackage
    }
    
    var body: some View {
        HStack {
            Text(package.tracking_no ?? "")
                .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
        }
        .onTapGesture {
            self.selectedPackage = self.package
        }
    }
}

struct SearchCellView_Previews: PreviewProvider {
    static var previews: some View {
        let binding = Binding<PackageViewModel?>(
            get: { nil },
            set: { _ in }
        )
        SearchCellView(package: PackageViewModel(dataModel: PackageDataModel()), selectedPackage: binding)
    }
}
