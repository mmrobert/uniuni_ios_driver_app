//
//  PickupGenerateReportView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-02.
//

import SwiftUI

struct PickupGenerateReportView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PickupGenerateReportViewModel
    
    @State private var showingRemind: Bool = false
    
    init(viewModel: PickupGenerateReportViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Divider()
                .frame(width: 0, height: 0)
            ZStack {
                VStack {
                    VStack(spacing: 10) {
                        HStack(alignment: .top) {
                            Text(String.scanTimeStr + ":")
                                .foregroundColor(.black)
                            Text(viewModel.pickupScanReportData?.scan_time ?? "")
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        HStack(alignment: .top) {
                            Text(String.ordersAssignedStr + ":")
                                .foregroundColor(.black)
                            Text("\(viewModel.pickupScanReportData?.assigned_parcels_count ?? 0)")
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        HStack(alignment: .top) {
                            Text(String.totalScannedStr + ":")
                                .foregroundColor(.black)
                            Text("\(viewModel.pickupScanReportData?.scanned_parcels_count ?? 0)")
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    }
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    Divider()
                    VStack {
                        HStack(alignment: .top) {
                            Text(String.ordersNotScannedStr + ":")
                                .foregroundColor(.black)
                            Text("\(viewModel.pickupScanReportData?.unscanned_parcels_count ?? 0)")
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        List {
                            ForEach(viewModel.unscannedParcels) { pack in
                                HStack {
                                    Text("\(pack.tracking_no ?? "") - \(String.routeStr): \(pack.route_no ?? 0)")
                                    Spacer()
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color("screen-base"))
                                .listRowInsets(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 20))
                            }
                        }
                        .listStyle(.plain)
                    }
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    Divider()
                    VStack {
                        HStack(alignment: .top) {
                            Text(String.parcelsToBeReturnedStr + ":")
                                .foregroundColor(.black)
                            Text("\(viewModel.pickupScanReportData?.returned_parcels_count ?? 0)")
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        List {
                            ForEach(viewModel.returnedParcels) { pack in
                                HStack {
                                    Text("\(pack.tracking_no ?? "")")
                                    Spacer()
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color("screen-base"))
                                .listRowInsets(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 20))
                            }
                        }
                        .listStyle(.plain)
                    }
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    Spacer()
                    Text(String.pleaseShowThisReportStr)
                        .foregroundColor(Color("tab-bar-tint"))
                        .font(.system(size: 14))
                        .padding(EdgeInsets(top: 10, leading: 30, bottom: 0, trailing: 30))
                        .multilineTextAlignment(.center)
                    Button(String.confirmPickupStr) {
                        self.showingRemind = true
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color("tab-bar-tint"))
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .cornerRadius(24)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: -30, trailing: 20))
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
            .navigationTitle(String.pickupConfirmationStr)
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
            .alert(String.confirmPickupStr, isPresented: $showingRemind, actions: {
                Button(String.yesStr, role: nil, action: {
                    self.showingRemind = false
                    self.viewModel.showingProgressView = true
                    self.viewModel.closeBatch()
                })
                Button(String.cancelStr, role: .cancel, action: {
                    self.showingRemind = false
                })
            }, message: {
                Text(String.confirmPickupMessageStr)
            })
            .onAppear {
                viewModel.showingProgressView = true
                viewModel.fetchPickupScanReport()
            }
        }
    }
}

struct PickupGenerateReportView_Previews: PreviewProvider {
    static var previews: some View {
        PickupGenerateReportView(viewModel: PickupGenerateReportViewModel())
    }
}
