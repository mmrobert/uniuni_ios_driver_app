//
//  ScanHomeView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-04.
//

import SwiftUI

struct ScanHomeView: View {
    
    @ObservedObject private var viewModel: ScanHomeViewModel
    
    init(viewModel: ScanHomeViewModel) {
        self.viewModel = viewModel
        viewModel.fetchPacksPickDropInfo(driverID: 100)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 1) {
                        OrderToPickupCardView(viewModel: viewModel)
                            .background(.white)
                            .cornerRadius(16)
                            .padding(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20))
                        OrderToDropoffCardView(viewModel: viewModel)
                            .background(.white)
                            .cornerRadius(16)
                            .padding(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20))
                        BusinessPickupCardView()
                            .background(.white)
                            .cornerRadius(16)
                            .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
                        Spacer(minLength: 5)
                    }
                    .background(Color("screen-base"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationBarTitle(String.scanStr)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                AppGlobalVariables.shared.tabBarHiden = false
            }
        }
    }
}

struct ScanHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ScanHomeView(viewModel: ScanHomeViewModel())
    }
}
