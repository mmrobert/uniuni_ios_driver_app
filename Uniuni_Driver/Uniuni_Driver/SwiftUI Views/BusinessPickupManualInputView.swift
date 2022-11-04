//
//  BusinessPickupManualInputView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-15.
//

import SwiftUI

struct BusinessPickupManualInputView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BusinessPickupScanViewModel
    @State private var searchString = ""
    
    @FocusState private var showingKeyboard: Bool
    
    init(viewModel: BusinessPickupScanViewModel) {
        self.viewModel = viewModel
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
                        self.viewModel.checkPickupScanned(trackingNo: searchString)
                    }
                    .frame(width: 65, height: 25)
                    .font(.bold(.system(size: 18))())
                    .foregroundColor(Color("highlighted-blue"))
                    .padding(.trailing, 15)
                }
                Spacer()
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
        .alert(String.unrecognizedParcelStr, isPresented: $viewModel.showingWrongPackageAlert, actions: {
            Button(String.OKStr, role: nil, action: {
                self.viewModel.showingWrongPackageAlert = false
            })
        }, message: {
            Text(String.thisParcelCannotBeIdentifiedStr)
        })
        .alert(String.networkFailureStr, isPresented: $viewModel.showingNetworkErrorAlert, actions: {
            Button(String.OKStr, role: nil, action: {
                self.viewModel.showingNetworkErrorAlert = false
            })
        }, message: {
            Text(String.pleaseCheckYourNetworkAndRetryStr)
        })
    }
    
    private func packageString(pack: BusinessPickupScanViewModel.ScannedPackage) -> String {
        return "\(pack.package.tno ?? "") - \(pack.package.segment ?? "")"
    }
}

struct BusinessPickupManualInputView_Previews: PreviewProvider {
    static var previews: some View {
        BusinessPickupManualInputView(viewModel: BusinessPickupScanViewModel())
    }
}
