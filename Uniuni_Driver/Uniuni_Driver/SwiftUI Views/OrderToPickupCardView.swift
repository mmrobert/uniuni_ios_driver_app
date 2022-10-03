//
//  OrderToPickupCardView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-03.
//

import SwiftUI

struct OrderToPickupCardView: View {
    
    @ObservedObject private var viewModel: ScanHomeViewModel
    @State var scanToPickup: Bool = false
    
    init(viewModel: ScanHomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image("icon-package")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 141, height: 114)
            VStack(alignment: .leading, spacing: 5) {
                Text(String.orderToPickupStr)
                    .font(.bold(.system(size: 14))())
                    .foregroundColor(Color("light-black-text"))
                Text(String(viewModel.packsToPickNo))
                    .font(.bold(.system(size: 48))())
                    .foregroundColor(Color("navi-bar-button"))
                Text(viewModel.packsToPickAddress)
                    .font(.system(size: 14))
                    .foregroundColor(Color("navi-bar-button"))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                HStack {
                    Text(String.scanStr)
                        .font(.bold(.system(size: 16))())
                        .foregroundColor(Color("navi-bar-button"))
                    Image(systemName: "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 16)
                    Spacer()
                }
                .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0))
                .onTapGesture {
                    self.scanToPickup = true
                    AppGlobalVariables.shared.tabBarHiden = true
                }
            }
            .onAppear {
                self.scanToPickup = false
            }
            NavigationLink("", isActive: $scanToPickup) {
                PickupScanView(viewModel: PickupScanPackagesViewModel())
            }
        }
        .padding(EdgeInsets(top: 46, leading: 20, bottom: 42, trailing: 15))
    }
}

struct OrderToPickupCardView_Previews: PreviewProvider {
    static var previews: some View {
        OrderToPickupCardView(viewModel: ScanHomeViewModel())
    }
}
