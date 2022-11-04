//
//  PickupScanView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-04.
//

import SwiftUI

struct PickupScanView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var viewModel: PickupScanPackagesViewModel
    
    @ObservedObject private var generateReportViewModel = PickupGenerateReportViewModel()
    
    @State private var focusViewHiden: Bool = false
    @State private var manualInput: Bool = false
    @State private var generateReport: Bool = false
    
    @Binding var scanToPickup: Bool
    
    init(viewModel: PickupScanPackagesViewModel, scanToPickup: Binding<Bool>) {
        self.viewModel = viewModel
        self._scanToPickup = scanToPickup
        viewModel.fetchScanBatchID(driverID: AppConfigurator.shared.driverID)
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
                    if let trackingNo = viewModel.scannedPackage?.package.tracking_no {
                        HStack {
                            Text(trackingNo)
                                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 10))
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                            Spacer()
                            if !self.wrongPackage(pack: viewModel.scannedPackage) {
                                Text(String(viewModel.scannedPackage?.package.route_no ?? 0))
                                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
                                    .foregroundColor(.black)
                                    .font(.bold(.system(size: 29))())
                            }
                        }
                        HStack {
                            Text(String.trackingNoStr)
                                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 10))
                                .foregroundColor(Color("light-black-text"))
                                .font(.system(size: 12))
                            Spacer()
                            if !self.wrongPackage(pack: viewModel.scannedPackage) {
                                Text(String.routeNoStr)
                                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
                                    .foregroundColor(Color("light-black-text"))
                                    .font(.system(size: 12))
                            }
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
                .background(!self.wrongPackage(pack: viewModel.scannedPackage) ? Color(red: 222 / 255, green: 237 / 255, blue: 1.0) : Color(red: 1.0, green: 214 / 255, blue: 214 / 255))
                
                List {
                    ForEach(viewModel.scannedPackagesList) { pack in
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
                
                VStack {
                    Button(action: {
                        self.generateReport = true
                    }) {
                        Text(String.deliveredStr)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color("tab-bar-tint"))
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .cornerRadius(24)
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: -5, trailing: 20))
                    }
                }
                .background(Color("screen-base"))
                .onAppear {
                    manualInput = false
                    generateReport = false
                    focusViewHiden = false
                }
            }
            VStack {
                ProgressView()
                    .scaleEffect(4)
                    .progressViewStyle(CircularProgressViewStyle())
            }
            .isHidden(!self.viewModel.showingProgressView)
            NavigationLink("", isActive: $manualInput) {
                PickupManualInputView(viewModel: self.viewModel)
            }
            NavigationLink("", isActive: $generateReport) {
                PickupGenerateReportView(viewModel: generateReportViewModel, scanToPickup: $scanToPickup)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(String.pickupScanStr)
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
        .alert(String.wrongPackageStr, isPresented: $viewModel.showingWrongPackageAlert, actions: {
            Button(String.OKStr, role: nil, action: {
                self.viewModel.detectionPaused = false
                self.viewModel.startNetworking = false
                self.viewModel.showingWrongPackageAlert = false
            })
        }, message: {
            Text(String.thisPackageShouldNotBePickedupStr)
        })
        .alert(String.failedScanningStr, isPresented: $viewModel.showingNetworkErrorAlert, actions: {
            Button(String.OKStr, role: nil, action: {
                self.viewModel.detectionPaused = false
                self.viewModel.startNetworking = false
                self.viewModel.showingNetworkErrorAlert = false
            })
        }, message: {
            Text(String.scanningNetworkFailureStr)
        })
        .alert(String.alreadyScannedStr, isPresented: $viewModel.showingAlreadyScannedAlert, actions: {
            Button(String.OKStr, role: nil, action: {
                self.viewModel.detectionPaused = false
                self.viewModel.startNetworking = false
                self.viewModel.showingAlreadyScannedAlert = false
            })
        }, message: {
            Text(String.thisParcelHasBeenScannedStr)
        })
        .alert(String.scanClosedStr, isPresented: $viewModel.showingBatchClosedAlert, actions: {
            Button(String.yesStr, role: nil, action: {
                self.viewModel.detectionPaused = false
                self.viewModel.startNetworking = false
                self.viewModel.showingBatchClosedAlert = false
                self.viewModel.showingProgressView = true
                self.viewModel.reopenBatch()
            })
            Button(String.noStr, role: .cancel, action: {
                self.viewModel.detectionPaused = false
                self.viewModel.startNetworking = false
                self.viewModel.showingBatchClosedAlert = false
            })
        }, message: {
            Text(String.theScanSessionIsClosedStr)
        })
    }
    
    private func wrongPackage(pack: PickupScanPackagesViewModel.ScannedPackage?) -> Bool {
        if let wrong = pack?.wrongPackage {
            return wrong
        }
        return false
    }
    
    private func wrongPackageString(pack: PickupScanPackagesViewModel.ScannedPackage) -> String {
        if self.wrongPackage(pack: pack) {
            return "\(pack.package.tracking_no ?? "")"
        } else {
            return "\(pack.package.tracking_no ?? "") - \(String.routeStr): \(pack.package.route_no ?? 0)"
        }
    }
}

struct PickupScanView_Previews: PreviewProvider {
    static var previews: some View {
        let binding = Binding<Bool>(
            get: { false },
            set: { _ in }
        )
        PickupScanView(viewModel: PickupScanPackagesViewModel(), scanToPickup: binding)
    }
}
