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
    }
    
    var body: some View {
        NavigationView {
        VStack(spacing: 0) {
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
                            .padding(EdgeInsets(top: 16, leading: 20, bottom: 6, trailing: 20))
                    }
                    .onAppear {
                        viewModel.fetchPacksPickDropInfo(driverID: AppConfigurator.shared.driverID)
                }
                .frame(maxHeight: .infinity)
                }
                Spacer()
                VStack {
                    Color("screen-base")
                        .frame(maxHeight: 0)
                }
            }
            .background(Color("screen-base"))
        }
        .navigationBarTitle(String.scanStr)
        .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}

struct ScanHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ScanHomeView(viewModel: ScanHomeViewModel())
    }
}
