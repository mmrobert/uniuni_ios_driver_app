//
//  OrderToDropoffCardView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-04.
//

import SwiftUI

struct OrderToDropoffCardView: View {
    
    @ObservedObject private var viewModel: ScanHomeViewModel
    @State var scanToDropoff: Bool = false
    
    init(viewModel: ScanHomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text(String.orderToDropoffStr)
                    .font(.bold(.system(size: 14))())
                    .foregroundColor(Color("light-black-text"))
                Text(String(viewModel.packsToDropNo))
                    .font(.bold(.system(size: 48))())
                    .foregroundColor(Color("navi-bar-button"))
                Text(self.servicePointAdd())
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
            }
            VStack {
                Image("icon-delivery-man")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 78, height: 164)
            }
            .onAppear {
                self.scanToDropoff = false
            }
            NavigationLink("", isActive: $scanToDropoff) {
                DropoffScanView(address: self.servicePointAdd(), viewModel: DropoffScanPackagesViewModel(), scanToDropoff: $scanToDropoff)
            }
        }
        .padding(EdgeInsets(top: 46, leading: 20, bottom: 42, trailing: 15))
        .onTapGesture {
            if let add = viewModel.packsToDropAddress, add.count > 0 {
                if viewModel.packsToDropNo > 0 {
                    self.scanToDropoff = true
                    AppGlobalVariables.shared.tabBarHiden = true
                } else {
                    self.scanToDropoff = false
                    AppGlobalVariables.shared.tabBarHiden = false
                }
            } else {
                self.scanToDropoff = false
                AppGlobalVariables.shared.tabBarHiden = false
            }
        }
    }
    
    private func servicePointAdd() -> String {
        if let add = viewModel.packsToDropAddress, add.count > 0 {
            return add
        }
        return String.noServicePointIsCurrentlyAssignedToYouStr
    }
}

struct OrderToDropoffCardView_Previews: PreviewProvider {
    static var previews: some View {
        OrderToDropoffCardView(viewModel: ScanHomeViewModel())
    }
}
