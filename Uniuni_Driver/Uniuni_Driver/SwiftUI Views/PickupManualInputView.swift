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
    
    @FocusState private var showingKeyboard: Bool
    
    init(viewModel: PickupManualInputViewModel) {
        self.viewModel = viewModel
        viewModel.fetchScanBatchID(driverID: AppConstants.driverID)
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
                        self.viewModel.showingProgressView = true
                        self.viewModel.checkPickupInputed(trackingNo: searchString)
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
            VStack {
                ProgressView()
                    .scaleEffect(4)
                    .progressViewStyle(CircularProgressViewStyle())
            }
            .isHidden(!self.viewModel.showingProgressView)
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
        .alert(String.wrongPackageStr, isPresented: $viewModel.showingWrongPackageAlert, actions: {
            Button(String.OKStr, role: nil, action: {
                self.viewModel.showingWrongPackageAlert = false
            })
        }, message: {
            Text(String.thisPackageShouldNotBePickedupStr)
        })
        .alert(String.failedScanningStr, isPresented: $viewModel.showingNetworkErrorAlert, actions: {
            Button(String.OKStr, role: nil, action: {
                self.viewModel.showingNetworkErrorAlert = false
            })
        }, message: {
            Text(String.scanningNetworkFailureStr)
        })
        .alert(String.alreadyScannedStr, isPresented: $viewModel.showingAlreadyScannedAlert, actions: {
            Button(String.OKStr, role: nil, action: {
                self.viewModel.showingAlreadyScannedAlert = false
            })
        }, message: {
            Text(String.thisParcelHasBeenScannedStr)
        })
        .alert(String.scanClosedStr, isPresented: $viewModel.showingBatchClosedAlert, actions: {
            Button(String.yesStr, role: nil, action: {
                self.viewModel.showingBatchClosedAlert = false
                self.viewModel.showingProgressView = true
                self.viewModel.reopenBatch()
            })
            Button(String.noStr, role: .cancel, action: {
                self.viewModel.showingBatchClosedAlert = false
            })
        }, message: {
            Text(String.theScanSessionIsClosedStr)
        })
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
