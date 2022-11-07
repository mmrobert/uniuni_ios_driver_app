//
//  BusinessPickupScanConfirmationView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-10.
//

import SwiftUI

struct BusinessPickupScanConfirmationView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BusinessPickupScanViewModel
    
    @State private var showReminding: Bool = false
    
    @Binding var businessPickup: Bool
    @Binding var toScanItem: Bool
    
    init(viewModel: BusinessPickupScanViewModel, businessPickup: Binding<Bool>, toScanItem: Binding<Bool>) {
        self.viewModel = viewModel
        self._businessPickup = businessPickup
        self._toScanItem = toScanItem
    }
    
    var body: some View {
        VStack {
            Divider()
                .frame(width: 0, height: 0)
            ZStack {
                VStack {
                    VStack {
                        VStack(spacing: 5) {
                            HStack(alignment: .top) {
                                Text(String.startTimeStr + ":")
                                    .foregroundColor(.black)
                                Text(self.timeString(timeIntervalSince1970: Double(viewModel.summaryData?.pickup_time ?? 0)))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
                            HStack(alignment: .top) {
                                Text(String.scanListNoStr + ":")
                                    .foregroundColor(.black)
                                Text(viewModel.summaryData?.manifest_no ?? "")
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
                            HStack(alignment: .top) {
                                Text(String.totalParcelsStr + ":")
                                    .foregroundColor(.black)
                                Text("\(viewModel.summaryData?.total_count ?? 0)")
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
                            HStack(alignment: .top) {
                                Text(String.parcelsScannedStr + ":")
                                    .foregroundColor(.black)
                                Text("\(viewModel.summaryData?.scanned_count ?? 0)")
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
                        }
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
                        Divider()
                        VStack {
                            HStack(alignment: .top) {
                                Text(String.parcelsNotInTheListStr + ":")
                                    .foregroundColor(.black)
                                Text("\(viewModel.summaryData?.addon_orders?.count ?? 0)")
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 0, leading: 25, bottom: -8, trailing: 25))
                            if (viewModel.summaryData?.addon_orders?.count ?? 0) > 0 {
                                List {
                                    ForEach(viewModel.summaryData?.addon_orders ?? [], id: \.self) { trackingNo in
                                        HStack {
                                            Text(trackingNo)
                                            Spacer()
                                        }
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color("screen-base"))
                                        .listRowInsets(EdgeInsets(top: 0, leading: 35, bottom: 0, trailing: 25))
                                    }
                                }
                                .listStyle(.plain)
                            }
                        }
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        Divider()
                        VStack {
                            HStack(alignment: .top) {
                                Text(String.unrecognizedParcelsStr + ":")
                                    .foregroundColor(.black)
                                Text("\(viewModel.summaryData?.unfound_orders?.count ?? 0)")
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 0, leading: 25, bottom: -8, trailing: 25))
                            if (viewModel.summaryData?.unfound_orders?.count ?? 0) > 0 {
                                List {
                                    ForEach(viewModel.summaryData?.unfound_orders ?? [], id: \.self) { trackingNo in
                                        HStack {
                                            Text(trackingNo)
                                            Spacer()
                                        }
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color("screen-base"))
                                        .listRowInsets(EdgeInsets(top: 0, leading: 35, bottom: 0, trailing: 25))
                                    }
                                }
                                .listStyle(.plain)
                            }
                        }
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        Divider()
                        VStack {
                            HStack(alignment: .top) {
                                Text(String.pendingScanStr + ":")
                                    .foregroundColor(.black)
                                Text("\(viewModel.summaryData?.unscan_orders?.count ?? 0)")
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 0, leading: 25, bottom: -8, trailing: 25))
                            if (viewModel.summaryData?.unscan_orders?.count ?? 0) > 0 {
                                List {
                                    ForEach(viewModel.summaryData?.unscan_orders ?? [], id: \.self) { trackingNo in
                                        HStack {
                                            Text(trackingNo)
                                            Spacer()
                                        }
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color("screen-base"))
                                        .listRowInsets(EdgeInsets(top: 0, leading: 35, bottom: 0, trailing: 25))
                                    }
                                }
                                .listStyle(.plain)
                            }
                        }
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    }
                    .background(Color("screen-base"))
                    VStack {
                        HStack {
                            Text(String.signByManagerStr)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 12, leading: 25, bottom: 0, trailing: 25))
                        ZStack {
                            DrawSignatureView(delegate: self.viewModel)
                                .frame(height: 185)
                                .frame(maxWidth: .infinity)
                                .border(.black, width: 1.0)
                                .padding(EdgeInsets(top: 7, leading: 18, bottom: 10, trailing: 18))
                            VStack {
                                HStack {
                                    Text(String.signatureStr)
                                        .foregroundColor(Color("light-gray-198"))
                                    Spacer()
                                }
                                .padding(EdgeInsets(top: 15, leading: 25, bottom: 0, trailing: 25))
                                Spacer()
                            }
                        }
                        Button(action: {
                            self.showReminding = true
                        }) {
                            Text(String.completeStr)
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(Color("tab-bar-tint"))
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .cornerRadius(24)
                                .padding(EdgeInsets(top: 7, leading: 25, bottom: 15, trailing: 25))
                        }
                    }
                    .frame(height: 280)
                }
                .onAppear {
                    viewModel.fetchSummary()
                }
                VStack {
                    ProgressView()
                        .scaleEffect(4)
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .isHidden(!self.viewModel.showingProgressView)
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(String.businessConfirmationStr)
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
            .alert(String.completeScanStr, isPresented: $showReminding, actions: {
                Button(String.yesStr, role: nil, action: {
                    self.showReminding = false
                    self.viewModel.showingProgressView = true
                    self.viewModel.completeBusinessScan()
                    self.presentationMode.wrappedValue.dismiss()
                    self.toScanItem = false
                    self.businessPickup = false
                })
                Button(String.cancelStr, role: .cancel, action: {
                    self.showReminding = false
                })
            }, message: {
                Text(String.pleaseConfirmThatCompleteScanStr)
            })
        }
    }
    
    private func timeString(timeIntervalSince1970: Double) -> String {
        let date = Date(timeIntervalSince1970: timeIntervalSince1970)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm a, MMM d yyyy"
        let time = formatter.string(from: date)
        return time
    }
}

struct BusinessPickupScanConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        let binding1 = Binding<Bool>(
            get: { false },
            set: { _ in }
        )
        let binding2 = Binding<Bool>(
            get: { false },
            set: { _ in }
        )
        BusinessPickupScanConfirmationView(viewModel: BusinessPickupScanViewModel(), businessPickup: binding1, toScanItem: binding2)
    }
}
