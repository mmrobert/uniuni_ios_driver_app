//
//  UndeliveredPackageDetailView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-22.
//

import SwiftUI
import SDWebImageSwiftUI

struct UndeliveredPackageDetailView: View {
    
    var naviController: UINavigationController?
    
    @ObservedObject private var viewModel: UndeliveredPackageDetailViewModel
    
    @State private var scrollViewContentSize: CGSize = .zero
    @State private var showingSignatureConfirm: Bool = false
    
    init(naviController: UINavigationController?, viewModel: UndeliveredPackageDetailViewModel) {
        self.naviController = naviController
        self.viewModel = viewModel
        let tempToken = AppConfigurator.shared.token
        let bearer = "Bearer \(tempToken)"
        SDWebImageDownloader.shared.setValue(bearer, forHTTPHeaderField: "Authorization")
    }
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        HStack {
                            Text(String.orderInformationStr)
                                .padding(EdgeInsets(top: 5, leading: 20, bottom: 3, trailing: 20))
                                .font(.bold(.system(size: 20))())
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        VStack(spacing: 3) {
                            TitleTextView(title: String.trackingNoStr, text: viewModel.packageViewModel?.tracking_no)
                            TitleTextView(title: String.routeNoStr, text: "\(viewModel.packageViewModel?.route_no ?? 0)")
                            TitleTextView(title: String.orderTypeStr, text: viewModel.packageViewModel?.goods_type?.getDisplayString())
                            TitleTextView(title: String.customerSignatureStr, text: requiredCustomerSignature())
                            TitleTextView(title: String.assignedTimeStr, text: viewModel.packageViewModel?.assign_time)
                            TitleTextView(title: String.deliveryTypeStr, text: viewModel.packageViewModel?.express_type?.getDisplayString())
                            TitleTextView(title: String.deliveryAttemptStr, text: viewModel.packageViewModel?.getDeliveryAttemptValue())
                            TitleTextView(title: String.deliveryByStr, text: viewModel.packageViewModel?.delivery_by)
                            HStack(alignment: .top) {
                                Text(String.failedReasonStr)
                                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 10))
                                    .foregroundColor(.black)
                                Spacer()
                                Text(self.failedReason())
                                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
                                    .foregroundColor(Color("light-blue"))
                            }
                        }
                        HStack {
                            Text(String.customerInformationStr)
                                .padding(EdgeInsets(top: 5, leading: 20, bottom: 3, trailing: 20))
                                .font(.bold(.system(size: 20))())
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        VStack(spacing: 3) {
                            TitleTextView(title: String.nameStr, text: viewModel.packageViewModel?.name)
                            TitleTextView(title: String.phoneNumberStr, text: viewModel.packageViewModel?.mobile)
                            TitleTextView(title: String.addressStr, text: viewModel.packageViewModel?.address)
                        }
                        HStack {
                            Text(String.customerNotesStr)
                                .padding(EdgeInsets(top: 5, leading: 20, bottom: 3, trailing: 20))
                                .font(.bold(.system(size: 20))())
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        VStack(spacing: 3) {
                            TitleTextView(title: String.buzzStr, text: viewModel.packageViewModel?.buzz_code)
                            TitleTextView(title: String.noteStr, text: viewModel.packageViewModel?.postscript)
                        }
                    }
                    .background(
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                scrollViewContentSize = geo.size
                            }
                            return Color.clear
                        }
                    )
                }
                .frame(maxHeight: scrollViewContentSize.height)
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .isHidden(shadowHiden())
                VStack {
                    HStack {
                        Text(String.photosStr)
                            .padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
                            .font(.bold(.system(size: 20))())
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    HStack {
                        if viewModel.packageViewModel?.SG == 1 {
                            Text(String.take2PhotosSignatureStr)
                                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                .foregroundColor(.gray)
                        } else {
                            Text(String.take2PhotosStr)
                                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    VStack {
                        HStack(spacing: 16) {
                            ForEach(viewModel.pods, id: \.self) { pod in
                                WebImage(url: URL(string: pod))
                                    .resizable()
                                    .placeholder { Rectangle().foregroundColor(.white) }
                                    .transition(.fade(duration: 0.5))
                                    .scaledToFit()
                                    .frame(width: 137, height: 124)
                            }
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    }
                }
                .isHidden(shadowHiden())
                Spacer()
                VStack {
                    Button(action: {
                        guard let vm = self.viewModel.packageViewModel else {
                            return
                        }
                        self.naviController?.popViewController(animated: false)
                        let completeNavi = CompleteDeliveryNavigator(presenter: self.naviController, packageViewModel: vm)
                        completeNavi.presentDeliveryDetail()
                    }) {
                        Text(String.deliveredStr)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color("tab-bar-tint"))
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .cornerRadius(24)
                            .padding(EdgeInsets(top: 5, leading: 20, bottom: 15, trailing: 20))
                    }
                }
                .onAppear {
                    viewModel.fetchPackageDeliveryHistoryFromAPI()
                }
            }
        }
        .navigationBarTitle(viewModel.packageViewModel?.tracking_no ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button {
            self.naviController?.popViewController(animated: true)
        } label: {
            Image("icon-back")
        })
        
        .alert(String.networkFailureStr, isPresented: $viewModel.showingNetworkErrorAlert, actions: {
            Button(String.OKStr, role: nil, action: {
                self.viewModel.showingNetworkErrorAlert = false
            })
        }, message: {
            Text(String.pleaseCheckYourNetworkAndRetryStr)
        })
    }
    
    private func requiredCustomerSignature() -> String {
        if viewModel.packageViewModel?.SG == 1 {
            return String.yesStr
        } else {
            return String.noStr
        }
    }
    
    private func failedReason() -> String {
        guard let reason = viewModel.failedReason else {
            return ""
        }
        switch reason {
        case 0:
            return String.redeliveryStr
        case 1:
            return String.failToContactCustomerStr
        case 2:
            return String.wrongAddressStr
        case 3:
            return String.POBoxStr
        default:
            return ""
        }
    }
    
    private func shadowHiden() -> Bool {
        if viewModel.pods.count > 0 {
            return false
        }
        return true
    }
}

struct UndeliveredPackageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        UndeliveredPackageDetailView(naviController: UINavigationController(), viewModel: UndeliveredPackageDetailViewModel(packageViewModel: PackageViewModel()))
    }
}
