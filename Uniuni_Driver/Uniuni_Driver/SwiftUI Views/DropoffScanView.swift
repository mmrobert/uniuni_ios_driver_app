//
//  DropoffScanView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-05.
//

import Foundation
import SwiftUI

struct DropoffScanView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var viewModel: DropoffScanPackagesViewModel
    
    private var address: String = ""
    
    @State private var showingIncorrectAmountAlert: Bool = false
    
    @State private var manualInput: Bool = false
    @State private var generateReport: Bool = false
    
    @Binding var scanToDropoff: Bool
    
    init(address: String, viewModel: DropoffScanPackagesViewModel, scanToDropoff: Binding<Bool>) {
        self.address = address
        self.viewModel = viewModel
        self._scanToDropoff = scanToDropoff
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    BarCodeScannerView(barCodeScanner: self.viewModel.barCodeScanner, focusViewHiden: Binding.constant(false))
                        .frame(maxWidth: .infinity, maxHeight: 200)
                }
                VStack {
                    HStack {
                        Image("icon-address-mark")
                        Text(address)
                            .font(.bold(.system(size: 14))())
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.leading, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: 45)
                .background(Color(red: 206 / 255, green: 230 / 255, blue: 1.0))
                
                List {
                    ForEach(viewModel.dropoffPackagesList) { pack in
                        HStack {
                            Text(self.packageString(pack: pack))
                            Spacer()
                            Image(self.packageCheckbox(pack: pack))
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 20))
                    }
                }
                .listStyle(.plain)
                .background(Color("screen-base"))
                
                VStack {
                    Button(action: {
                        if viewModel.checkScannedAmount() {
                            self.generateReport = true
                        } else {
                            self.generateReport = false
                            self.showingIncorrectAmountAlert = true
                        }
                    }) {
                        Text(String.generateReportStr)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color("tab-bar-tint"))
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .cornerRadius(24)
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: -18, trailing: 20))
                    }
                }
                .background(Color("screen-base"))
                .onAppear {
                    manualInput = false
                    generateReport = false
                    showingIncorrectAmountAlert = false
                }
            }
            NavigationLink("", isActive: $manualInput) {
                DropoffManualInputView(viewModel: viewModel)
            }
            NavigationLink("", isActive: $generateReport) {
                DropoffGenerateReportView(address: address, viewModel: viewModel, scanToDropoff: $scanToDropoff)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(String.dropoffScanStr)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    AppGlobalVariables.shared.tabBarHiden = false
                    self.viewModel.barCodeScanner.stopRunningCaptureSession()
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image("icon-back")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.manualInput = true
                } label: {
                    Image("icon-manual-input")
                }
            }
        }
        .alert(String.networkFailureStr, isPresented: $viewModel.showingNetworkErrorAlert, actions: {
            Button(String.OKStr, role: nil, action: {
                self.viewModel.showingNetworkErrorAlert = false
            })
        }, message: {
            Text(String.pleaseCheckYourNetworkAndRetryStr)
        })
        .alert(String.wrongPackageStr, isPresented: $viewModel.showingWrongPackageAlert, actions: {
            Button(String.OKStr, role: nil, action: {
                self.viewModel.showingWrongPackageAlert = false
            })
        }, message: {
            Text(String.thisPackageShouldNotBeDroppedoffStr)
        })
        .alert(String.alreadyScannedStr, isPresented: $viewModel.showingAlreadyScannedAlert, actions: {
            Button(String.OKStr, role: nil, action: {
                self.viewModel.showingAlreadyScannedAlert = false
            })
        }, message: {
            Text(String.thisParcelHasAlreadyBeenScannedStr)
        })
        .alert(String.incorrectPackageAmountStr, isPresented: $showingIncorrectAmountAlert, actions: {
            Button(String.yesStr, role: nil, action: {
                showingIncorrectAmountAlert = false
                self.generateReport = true
            })
            Button(String.cancelStr, role: .cancel, action: {
                self.generateReport = false
                showingIncorrectAmountAlert = false
            })
        }, message: {
            Text(String.theNumberOfPackagesScannedDoesNotStr)
        })
    }
    
    private func packageCheckbox(pack: DropoffScanPackagesViewModel.ScannedPackage) -> String {
        switch pack.state {
        case .notScanned:
            return "icon-checkbox-gray"
        case .scanned:
            return "icon-checkbox-green"
        case .manualInput:
            return "icon-checkbox-orange"
        }
    }
    
    private func packageString(pack: DropoffScanPackagesViewModel.ScannedPackage) -> String {
        return "\(pack.package.tracking_no ?? "") - \(String.routeStr): \(pack.package.route_no ?? 0)"
    }
}

struct DropoffScanView_Previews: PreviewProvider {
    static var previews: some View {
        let binding = Binding<Bool>(
            get: { false },
            set: { _ in }
        )
        DropoffScanView(address: "", viewModel: DropoffScanPackagesViewModel(), scanToDropoff: binding)
    }
}
