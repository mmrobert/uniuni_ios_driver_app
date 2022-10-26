//
//  DropoffManualInputView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-08.
//

import SwiftUI

struct DropoffManualInputView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var viewModel: DropoffScanPackagesViewModel
    
    @State private var searchString = ""
    @State private var selectedPackage: DropoffScanPackagesViewModel.ScannedPackage?
    
    init(viewModel: DropoffScanPackagesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Divider()
                .frame(width: 0, height: 0)
            VStack {
                List {
                    ForEach(searchString == "" ? self.unscannedList() : self.unscannedList().filter {
                        guard let trackingNo = $0.package.tracking_no else {
                            return false
                        }
                        return trackingNo.contains(searchString)
                    }) {
                        DropoffManualInputCellView(package: $0, selectedPackage: $selectedPackage)
                    }
                }
                .listStyle(.plain)
                .background(Color("screen-base"))
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(String.manualInputStr)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchString, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("icon-back")
                    }
                }
            }
            .onChange(of: selectedPackage) { _ in
                guard let selectedPackage = self.selectedPackage else {
                    return
                }
                viewModel.manualInput(input: selectedPackage)
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func unscannedList() -> [DropoffScanPackagesViewModel.ScannedPackage] {
        self.viewModel.dropoffPackagesList.filter {
            $0.state == .notScanned
        }
    }
}

struct DropoffManualInputView_Previews: PreviewProvider {
    static var previews: some View {
        DropoffManualInputView(viewModel: DropoffScanPackagesViewModel())
    }
}
