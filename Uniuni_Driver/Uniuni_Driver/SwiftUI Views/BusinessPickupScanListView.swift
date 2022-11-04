//
//  BusinessPickupScanListView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-09.
//

import SwiftUI

struct BusinessPickupScanListView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BusinessPickupScanViewModel
    
    @State var selectedListItem: BusinessPickupScanViewModel.ScanListItem?
    
    @State private var toScanItem: Bool = false
    @Binding var businessPickup: Bool
    
    init(viewModel: BusinessPickupScanViewModel, businessPickup: Binding<Bool>) {
        self.viewModel = viewModel
        self._businessPickup = businessPickup
    }
    
    var body: some View {
        VStack {
            Divider()
                .frame(width: 0, height: 0)
            VStack {
                List {
                    ForEach(viewModel.scanList) {
                        BusinessPickupScanListCellView(listItem: $0, selectedListItem: $selectedListItem)
                    }
                }
                .background(Color("screen-base"))
                .padding(.bottom, -30)
                NavigationLink("", isActive: $toScanItem) {
                    BusinessPickupScanView(viewModel: viewModel, businessPickup: $businessPickup, toScanItem: $toScanItem)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(String.scanListStr)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                        AppGlobalVariables.shared.tabBarHiden = false
                    } label: {
                        Image("icon-back")
                    }
                }
            }
            .onAppear {
                self.toScanItem = false
                viewModel.fetchScanList()
            }
            .onChange(of: selectedListItem) { _ in
                guard let selectedItem = self.selectedListItem else {
                    return
                }
                viewModel.selectedListItem = selectedItem
                self.toScanItem = true
            }
        }
    }
}

struct BusinessPickupScanListView_Previews: PreviewProvider {
    static var previews: some View {
        let binding = Binding<Bool>(
            get: { false },
            set: { _ in }
        )
        BusinessPickupScanListView(viewModel: BusinessPickupScanViewModel(), businessPickup: binding)
    }
}
