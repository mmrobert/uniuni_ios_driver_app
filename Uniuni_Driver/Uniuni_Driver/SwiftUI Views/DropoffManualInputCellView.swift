//
//  DropoffManualInputCellView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-08.
//

import SwiftUI

struct DropoffManualInputCellView: View {
    
    private var package: DropoffScanPackagesViewModel.ScannedPackage
    @Binding var selectedPackage: DropoffScanPackagesViewModel.ScannedPackage?
    
    init(package: DropoffScanPackagesViewModel.ScannedPackage, selectedPackage: Binding<DropoffScanPackagesViewModel.ScannedPackage?>) {
        self.package = package
        self._selectedPackage = selectedPackage
    }
    
    var body: some View {
        HStack {
            Text(package.package.tracking_no ?? "")
        }
        .onTapGesture {
            self.selectedPackage = self.package
        }
    }
}

struct DropoffManualInputCellView_Previews: PreviewProvider {
    static var previews: some View {
        let binding = Binding<DropoffScanPackagesViewModel.ScannedPackage?>(
            get: { nil },
            set: { _ in }
        )
        DropoffManualInputCellView(package: DropoffScanPackagesViewModel.ScannedPackage(package: PackageViewModel(), state: .notScanned), selectedPackage: binding)
    }
}
