//
//  DropoffGenerateReportView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-08.
//

import SwiftUI

struct DropoffGenerateReportView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: DropoffScanPackagesViewModel
    
    private var address: String = ""
    
    @Binding var scanToDropoff: Bool
    
    init(address: String, viewModel: DropoffScanPackagesViewModel, scanToDropoff: Binding<Bool>) {
        self.address = address
        self.viewModel = viewModel
        self._scanToDropoff = scanToDropoff
    }
    
    var body: some View {
        VStack {
            Divider()
                .frame(width: 0, height: 0)
            ZStack {
                VStack {
                    VStack(spacing: 10) {
                        HStack {
                            Text(String.confirmTheDropoffWithStr)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
                        HStack(alignment: .top) {
                            Text(String.scanTimeStr + ":")
                                .foregroundColor(.black)
                            Text(self.nowString())
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
                        HStack(alignment: .top) {
                            Text(String.servicePointStr + ":")
                                .foregroundColor(.black)
                            Text(address)
                                .foregroundColor(.black)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
                        HStack(alignment: .top) {
                            Text(String.totalPackagesForDropoffStr + ":")
                                .foregroundColor(.black)
                            Text("\(viewModel.dropoffPackagesList.count)")
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
                    }
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    Divider()
                    VStack {
                        HStack(alignment: .top) {
                            Text(String.totalScannedStr + ":")
                                .foregroundColor(.black)
                            Text("\(totalScanned().count)")
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
                        List {
                            ForEach(totalScanned()) { pack in
                                HStack {
                                    Text(self.packageString(pack: pack))
                                    Spacer()
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color("screen-base"))
                                .listRowInsets(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 25))
                            }
                        }
                        .listStyle(.plain)
                    }
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    Spacer()
                    Divider()
                    HStack {
                        Text(String.signByServicePointManagerStr)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 10, leading: 25, bottom: 0, trailing: 25))
                    ZStack {
                        DrawSignatureView(delegate: self.viewModel)
                            .frame(height: 206)
                            .frame(maxWidth: .infinity)
                            .border(.black, width: 1.0)
                            .padding(EdgeInsets(top: 7, leading: 18, bottom: 10, trailing: 18))
                        VStack {
                            HStack {
                                Text(String.signatureStr)
                                    .foregroundColor(Color("light-gray-198"))
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 12, leading: 25, bottom: 0, trailing: 25))
                            Spacer()
                        }
                    }
                    Button(action: {
                        self.viewModel.showingProgressView = true
                        self.viewModel.completeDropoffScan()
                        self.presentationMode.wrappedValue.dismiss()
                        self.scanToDropoff = false
                    }) {
                        Text(String.completeStr)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color("tab-bar-tint"))
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .cornerRadius(24)
                            .padding(EdgeInsets(top: 10, leading: 25, bottom: -18, trailing: 25))
                    }
                }
                .background(Color("screen-base"))
                VStack {
                    ProgressView()
                        .scaleEffect(4)
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .isHidden(!self.viewModel.showingProgressView)
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(String.dropoffConfirmationStr)
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
            .popup(isPresented: viewModel.showingSuccessfulAlert) {
                VStack {
                    Image("circled-checkmark")
                    Text(String.completedStr)
                }
                .frame(width: 158, height: 157)
                .background(Color("white-transparent-0.6"))
                .cornerRadius(10)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.viewModel.showingSuccessfulAlert = false
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
        }
    }
    
    private func nowString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm a, MMM d yyyy"
        let time = formatter.string(from: Date())
        return time
    }
    
    private func totalScanned() -> [DropoffScanPackagesViewModel.ScannedPackage] {
        let scanned = viewModel.dropoffPackagesList.filter {
            $0.state != .notScanned
        }
        return scanned
    }
    
    private func packageString(pack: DropoffScanPackagesViewModel.ScannedPackage) -> String {
        return "\(pack.package.tracking_no ?? "") - \(String.routeStr): \(pack.package.route_no ?? 0)"
    }
}

struct DropoffGenerateReportView_Previews: PreviewProvider {
    static var previews: some View {
        let binding = Binding<Bool>(
            get: { false },
            set: { _ in }
        )
        DropoffGenerateReportView(address: "", viewModel: DropoffScanPackagesViewModel(), scanToDropoff: binding)
    }
}
