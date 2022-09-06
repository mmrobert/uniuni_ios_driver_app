//
//  OrderToDropoffCardView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-04.
//

import SwiftUI

struct OrderToDropoffCardView: View {
    
    @ObservedObject private var viewModel: ScanPackagesViewModel
    
    init(viewModel: ScanPackagesViewModel) {
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
                Text(viewModel.packsToDropAddress)
                    .font(.system(size: 14))
                    .foregroundColor(Color("navi-bar-button"))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                HStack {
                    Text(String.scanStr)
                        .font(.bold(.system(size: 14))())
                        .foregroundColor(Color("navi-bar-button"))
                    Image(systemName: "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 16)
                    Spacer()
                }
            }
            Image("icon-delivery-man")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 78, height: 164)
        }
        .padding(EdgeInsets(top: 30, leading: 20, bottom: 26, trailing: 15))
    }
}

struct OrderToDropoffCardView_Previews: PreviewProvider {
    static var previews: some View {
        OrderToDropoffCardView(viewModel: ScanPackagesViewModel(driverID: 10))
    }
}
