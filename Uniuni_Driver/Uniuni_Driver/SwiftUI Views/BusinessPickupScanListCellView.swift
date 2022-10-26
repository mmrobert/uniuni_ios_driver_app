//
//  BusinessPickupScanListCellView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-12.
//

import SwiftUI

struct BusinessPickupScanListCellView: View {
    
    private var listItem: BusinessPickupScanViewModel.ScanListItem
    @Binding var selectedListItem: BusinessPickupScanViewModel.ScanListItem?
    
    init(listItem: BusinessPickupScanViewModel.ScanListItem, selectedListItem: Binding<BusinessPickupScanViewModel.ScanListItem?>) {
        self.listItem = listItem
        self._selectedListItem = selectedListItem
    }
    
    var body: some View {
        HStack {
            Text(listItem.package.partner_name ?? "")
            Spacer()
            Text(listItem.package.manifest_no ?? "")
            Spacer()
            Text("\(listItem.package.scanned_count ?? 0)/\(listItem.package.total_count ?? 0)")
        }
        .onTapGesture {
            self.selectedListItem = self.listItem
        }
    }
}

struct BusinessPickupScanListCellView_Previews: PreviewProvider {
    static var previews: some View {
        let binding = Binding<BusinessPickupScanViewModel.ScanListItem?>(
            get: { nil },
            set: { _ in }
        )
        BusinessPickupScanListCellView(listItem: BusinessPickupScanViewModel.ScanListItem(package: BusinessPickupScanListDataModel.ListItem(), wrongPackage: false), selectedListItem: binding)
    }
}
