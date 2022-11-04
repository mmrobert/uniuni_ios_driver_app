//
//  BusinessPickupScanView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-09.
//

import SwiftUI

struct BusinessPickupScanView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var viewModel: BusinessPickupScanViewModel
    
    @State private var focusViewHiden: Bool = false
    @State private var manualInput: Bool = false
    @State private var generateReport: Bool = false
    
    @Binding var businessPickup: Bool
    @Binding var toScanItem: Bool
    
    init(viewModel: BusinessPickupScanViewModel, businessPickup: Binding<Bool>, toScanItem: Binding<Bool>) {
        self.viewModel = viewModel
        self._businessPickup = businessPickup
        self._toScanItem = toScanItem
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    BarCodeScannerView(barCodeScanner: self.viewModel.barCodeScanner, focusViewHiden: self.$focusViewHiden)
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .onReceive(self.viewModel.$startNetworking) { newValue in
                            if newValue {
                                self.focusViewHiden = true
                            } else {
                                self.focusViewHiden = false
                            }
                        }
                }
                VStack {
                    if let trackingNo = viewModel.scannedPackage?.package.tno {
                        HStack {
                            Text(trackingNo)
                                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 10))
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                            Spacer()
                            Text(String(viewModel.scannedPackage?.package.segment ?? ""))
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
                                .foregroundColor(.black)
                                .font(.bold(.system(size: 29))())
                        }
                        HStack {
                            Text(String.trackingNoStr)
                                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 10))
                                .foregroundColor(Color("light-black-text"))
                                .font(.system(size: 12))
                            Spacer()
                            Text(String.segmentStr)
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
                                .foregroundColor(Color("light-black-text"))
                                .font(.system(size: 12))
                        }
                    } else {
                        HStack {
                            Text(String.pleaseScanAParcelStr)
                                .font(.bold(.system(size: 24))())
                                .foregroundColor(Color("light-gray-160"))
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 74)
                .background(Color(red: 222 / 255, green: 237 / 255, blue: 1.0))
                List {
                    ForEach(viewModel.scannedPackagesList) { pack in
                        HStack {
                            Text(self.packageString(pack: pack))
                            Spacer()
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 20))
                    }
                }
                .listStyle(.plain)
                .background(Color("screen-base"))
                
                VStack {
                    Button(action: {
                        self.generateReport = true
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
                }
            }
            VStack {
                ProgressView()
                    .scaleEffect(4)
                    .progressViewStyle(CircularProgressViewStyle())
            }
            .isHidden(!self.viewModel.showingProgressView)
            NavigationLink("", isActive: $manualInput) {
                BusinessPickupManualInputView(viewModel: viewModel)
            }
            NavigationLink("", isActive: $generateReport) {
                BusinessPickupScanConfirmationView(viewModel: viewModel, businessPickup: $businessPickup, toScanItem: $toScanItem)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(String.businessPickupScanStr)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
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
        .alert(String.unrecognizedParcelStr, isPresented: $viewModel.showingWrongPackageAlert, actions: {
            Button(String.OKStr, role: nil, action: {
                self.viewModel.detectionPaused = false
                self.viewModel.startNetworking = false
                self.viewModel.showingWrongPackageAlert = false
            })
        }, message: {
            Text(String.thisParcelCannotBeIdentifiedStr)
        })
        .alert(String.networkFailureStr, isPresented: $viewModel.showingNetworkErrorAlert, actions: {
            Button(String.OKStr, role: nil, action: {
                self.viewModel.detectionPaused = false
                self.viewModel.startNetworking = false
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

struct BusinessPickupScanView_Previews: PreviewProvider {
    static var previews: some View {
        let binding1 = Binding<Bool>(
            get: { false },
            set: { _ in }
        )
        let binding2 = Binding<Bool>(
            get: { false },
            set: { _ in }
        )
        BusinessPickupScanView(viewModel: BusinessPickupScanViewModel(), businessPickup: binding1, toScanItem: binding2)
    }
}
