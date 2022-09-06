//
//  PickupScanView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-04.
//

import SwiftUI

struct PickupScanView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var viewModel: ScanPackagesViewModel
    
    init(viewModel: ScanPackagesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                VStack {
                    Color.blue
                        .frame(maxWidth: .infinity, maxHeight: 200)
                }
                VStack {
                    Color.clear
                        .frame(maxWidth: .infinity, maxHeight: 110)
                        .border(.black, width: 1.0)
                        .padding(EdgeInsets(top: 45, leading: 17, bottom: 45, trailing: 17))
                }
            }
            VStack {
                if let trackingNo = viewModel.scannedPackage?.tracking_no {
                    HStack {
                        Text(trackingNo)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 10))
                            .foregroundColor(.black)
                            .font(.system(size: 24))
                        Spacer()
                        Text(String(viewModel.scannedPackage?.route_no ?? 0))
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
                            .foregroundColor(.black)
                            .font(.bold(.system(size: 30))())
                    }
                    HStack {
                        Text(String.trackingNoStr)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 10))
                            .foregroundColor(Color("light-black-text"))
                            .font(.system(size: 12))
                        Spacer()
                        Text(String.routeNoStr)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
                            .foregroundColor(Color("light-black-text"))
                            .font(.bold(.system(size: 12))())
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
                ForEach(viewModel.scannedPackagesList, id: \.id) { pack in
                    HStack {
                        Text("\(pack.order_id ?? 0) - \(String.routeStr): \(pack.route_no ?? 0)")
                        Spacer()
                        Image("icon-red-alarm")
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 20))
                }
            }
            .listStyle(.plain)
            .background(Color("screen-base"))
            
            VStack {
                Button(String.generateReportStr) {
                    
                }
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(Color("tab-bar-tint"))
                .font(.system(size: 18))
                .foregroundColor(.white)
                .cornerRadius(24)
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            }
            .background(Color("screen-base"))
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(String.pickupScanStr)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: Button {
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            Image("icon-back")
        })
    }
}

struct PickupScanView_Previews: PreviewProvider {
    static var previews: some View {
        PickupScanView(viewModel: ScanPackagesViewModel(driverID: 10))
    }
}
