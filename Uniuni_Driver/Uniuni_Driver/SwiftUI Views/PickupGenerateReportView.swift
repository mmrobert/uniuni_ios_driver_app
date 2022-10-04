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
    
    init(viewModel: PickupGenerateReportViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            VStack {
                
            }
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
    }
}

struct PickupGenerateReportView_Previews: PreviewProvider {
    static var previews: some View {
        PickupGenerateReportView(viewModel: PickupGenerateReportViewModel())
    }
}
