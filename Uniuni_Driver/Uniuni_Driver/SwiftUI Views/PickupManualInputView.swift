//
//  PickupManualInputView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-02.
//

import SwiftUI

struct PickupManualInputView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PickupManualInputViewModel
    @State private var searchString = ""
    @State private var selectedPackage: PackageViewModel?
    
    @FocusState private var showingKeyboard: Bool
    
    init(viewModel: PickupManualInputViewModel) {
        self.viewModel = viewModel
        viewModel.fetchScanBatchID(driverID: 100)
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color("light-gray-198"))
                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextField(String.trackingNumberStr, text: $searchString)
                                .font(.system(size: 16))
                                .focused($showingKeyboard)
                        }
                        .foregroundColor(.black)
                        .padding(.leading, 15)
                    }
                    .frame(height: 36)
                    .cornerRadius(12)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 10))
                    Button(String.searchStr) {
                        showingKeyboard = false
                    }
                    .frame(width: 65, height: 25)
                    .font(.bold(.system(size: 18))())
                    .foregroundColor(Color("highlighted-blue"))
                    .padding(.trailing, 15)
                }
                List {
                    ForEach(viewModel.inputedPackagesList) { pack in
                        HStack {
                            Text(self.wrongPackageString(pack: pack))
                            Spacer()
                            if self.wrongPackage(pack: pack) {
                                Image("icon-red-alarm")
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 20))
                    }
                }
                .listStyle(.plain)
                .background(Color("screen-base"))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(String.manualInputStr)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image("icon-back")
                }
            }
        }
    }
    
    private func wrongPackage(pack: PickupManualInputViewModel.InputedPackage?) -> Bool {
        if let wrong = pack?.wrongPackage {
            return wrong
        }
        return false
    }
    
    private func wrongPackageString(pack: PickupManualInputViewModel.InputedPackage) -> String {
        if self.wrongPackage(pack: pack) {
            return "\(pack.package.tracking_no ?? "")"
        } else {
            return "\(pack.package.tracking_no ?? "") - \(String.routeStr): \(pack.package.route_no ?? 0)"
        }
    }
}

struct PickupManualInputView_Previews: PreviewProvider {
    static var previews: some View {
        PickupManualInputView(viewModel: PickupManualInputViewModel())
    }
}
