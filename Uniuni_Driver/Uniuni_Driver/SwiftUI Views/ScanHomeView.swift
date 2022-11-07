//
//  ScanHomeView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-04.
//

import SwiftUI

struct ScanHomeView: View {
    
    @ObservedObject private var viewModel: ScanHomeViewModel
    
    @State private var scrollViewContentSize: CGSize = .zero
    
    init(viewModel: ScanHomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
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
                            .padding(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    }
                    .background(
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                scrollViewContentSize = geo.size
                            }
                            return Color("screen-base")
                        }
                    )
                }
                .frame(maxHeight: scrollViewContentSize.height)
                .onAppear {
                    viewModel.fetchPacksPickDropInfo(driverID: AppConfigurator.shared.driverID)
                }
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
