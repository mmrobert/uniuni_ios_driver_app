//
//  FailedPackageDetailView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-08-21.
//

import Foundation
import SwiftUI
import MapboxDirections

struct FailedPackageDetailView: View {
    
    @ObservedObject private var navigator: FailedDeliveryNavigator
    @State private var scrollViewContentSize: CGSize = .zero
    
    var packageViewModel: PackageViewModel {
        navigator.getPackageViewModel()
    }
    
    var failedReason: FailedReasonDelivery {
        navigator.getFailedReason()
    }
    
    init(navigator: FailedDeliveryNavigator) {
        self.navigator = navigator
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            HStack {
                                Text(String.orderInformationStr)
                                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
                                    .font(.bold(.system(size: 20))())
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            VStack {
                                TitleTextView(title: String.orderNoStr, text: packageViewModel.order_sn)
                                TitleTextView(title: String.trackingNoStr, text: packageViewModel.tracking_no)
                                TitleTextView(title: String.orderTypeStr, text: packageViewModel.goods_type?.getDisplayString(), textColor: goodsTypeColor())
                                TitleTextView(title: String.routeNoStr, text: "\(packageViewModel.route_no ?? 0)")
                                TitleTextView(title: String.assignedTimeStr, text: packageViewModel.assign_time)
                                TitleTextView(title: String.deliveryTypeStr, text: packageViewModel.express_type?.getDisplayString(), textColor: deliveryTypeColor())
                                TitleTextView(title: String.deliveryAttemptStr, text: packageViewModel.getDeliveryAttemptValue())
                                TitleTextView(title: String.deliveryByStr, text: packageViewModel.delivery_by)
                                TitleTextView(title: String.failedReasonStr, text: failedReason.displayString(), titleColor: .black, textColor: Color("light-blue"))
                            }
                            HStack {
                                Text(String.customerInformationStr)
                                    .padding(EdgeInsets(top: 2, leading: 20, bottom: 0, trailing: 20))
                                    .font(.bold(.system(size: 20))())
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            VStack {
                                TitleTextView(title: String.nameStr, text: packageViewModel.name)
                                TitleTextView(title: String.phoneNumberStr, text: packageViewModel.mobile)
                                TitleTextView(title: String.addressStr, text: (packageViewModel.address ?? ""))
                            }
                            HStack {
                                Text(String.customerNotesStr)
                                    .padding(EdgeInsets(top: 2, leading: 20, bottom: 0, trailing: 20))
                                    .font(.bold(.system(size: 20))())
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            VStack {
                                TitleTextView(title: String.buzzStr, text: packageViewModel.buzz_code)
                                TitleTextView(title: String.noteStr, text: packageViewModel.postscript)
                            }
                            switch failedReason {
                            case .redelivery:
                                HStack {
                                    Text(String.photosStr)
                                        .padding(EdgeInsets(top: 2, leading: 20, bottom: 0, trailing: 20))
                                        .font(.bold(.system(size: 20))())
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                HStack {
                                    Text(String.takeAtLeast1PhotoStr)
                                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                            case .failedContactCustomer:
                                HStack {
                                    Text(String.photosStr)
                                        .padding(EdgeInsets(top: 2, leading: 20, bottom: 0, trailing: 20))
                                        .font(.bold(.system(size: 20))())
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                HStack {
                                    if packageViewModel.SG == 1 {
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
                            case .wrongAddress, .poBox:
                                VStack {
                                    Color(uiColor: .clear)
                                        .frame(width: 100, height: 1)
                                }
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
                    VStack {
                        switch failedReason {
                        case .redelivery:
                            HStack(spacing: 6) {
                                if navigator.photos.count == 0 {
                                    ZStack {
                                        Color("screen-base")
                                            .frame(width: 137, height: 124)
                                        Image("icon-camera")
                                            .resizable()
                                            .frame(width: 73, height: 71)
                                            .background(Color("screen-base"))
                                            .onTapGesture {
                                                self.navigator.startPhotoTakingFlow()
                                            }
                                    }
                                } else if navigator.photos.count > 0 {
                                    ForEach(1...navigator.photos.count, id: \.self) { i in
                                        Image(uiImage: navigator.photos[i - 1])
                                            .resizable()
                                            .frame(width: 137, height: 124)
                                            .onTapGesture {
                                                self.navigator.startPhotoReviewFlow(index: i - 1)
                                            }
                                    }
                                }
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        case .failedContactCustomer:
                            HStack(spacing: 6) {
                                if navigator.photos.count == 0 {
                                    ZStack {
                                        Color("screen-base")
                                            .frame(width: 137, height: 124)
                                        Image("icon-camera")
                                            .resizable()
                                            .frame(width: 73, height: 71)
                                            .background(Color("screen-base"))
                                            .onTapGesture {
                                                self.navigator.startPhotoTakingFlow()
                                            }
                                    }
                                } else if navigator.photos.count == 1 {
                                    Image(uiImage: navigator.photos[0])
                                        .resizable()
                                        .frame(width: 137, height: 124)
                                        .onTapGesture {
                                            self.navigator.startPhotoTakingFlow()
                                        }
                                    ZStack {
                                        Color("screen-base")
                                            .frame(width: 137, height: 124)
                                        Image("icon-camera")
                                            .resizable()
                                            .frame(width: 73, height: 71)
                                            .background(Color("screen-base"))
                                            .onTapGesture {
                                                self.navigator.startPhotoTakingFlow()
                                            }
                                    }
                                } else if navigator.photos.count == 2 {
                                    Image(uiImage: navigator.photos[0])
                                        .resizable()
                                        .frame(width: 137, height: 124)
                                        .onTapGesture {
                                            self.navigator.startPhotoReviewFlow(index: 0)
                                        }
                                    Image(uiImage: navigator.photos[1])
                                        .resizable()
                                        .frame(width: 137, height: 124)
                                        .onTapGesture {
                                            self.navigator.startPhotoReviewFlow(index: 1)
                                        }
                                }
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        case .wrongAddress, .poBox:
                            VStack {
                                Color(uiColor: .clear)
                                    .frame(width: 100, height: 30)
                            }
                        }
                    }
                    Spacer()
                    VStack {
                        switch failedReason {
                        case .redelivery:
                            Button(String.completeStr) {
                                self.navigator.showingBackground = true
                                self.navigator.showingProgressView = true
                                self.navigator.failedReDeliveryTry()
                            }
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(self.navigator.photos.count < 1 ? Color("tab-bar-tint").opacity(0.4) : Color("tab-bar-tint"))
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .cornerRadius(23)
                            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                            .disabled(self.navigator.photos.count < 1)
                        case .failedContactCustomer:
                            Button(String.completeStr) {
                                self.navigator.showingBackground = true
                                self.navigator.showingProgressView = true
                                self.navigator.failedDelivery()
                            }
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(self.navigator.photos.count < 2 ? Color("tab-bar-tint").opacity(0.4) : Color("tab-bar-tint"))
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .cornerRadius(23)
                            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                            .disabled(self.navigator.photos.count < 2)
                        case .wrongAddress, .poBox:
                            Button(String.completeStr) {
                                self.navigator.showingBackground = true
                                self.navigator.showingProgressView = true
                                self.navigator.failedDelivery()
                            }
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(Color("tab-bar-tint"))
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .cornerRadius(23)
                            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        }
                    }
                }
                VStack {
                    Color("black-transparent-0.4")
                        .ignoresSafeArea()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .isHidden(!navigator.showingBackground)
                VStack {
                    ProgressView()
                        .scaleEffect(4)
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .isHidden(!self.navigator.showingProgressView)
            }
            .navigationBarTitle(String.failedStr)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button {
                self.navigator.back()
            } label: {
                Image("icon-back")
            })
            .popup(isPresented: navigator.showingSuccessfulAlert) {
                VStack {
                    Image("circled-checkmark")
                    Text(String.completedStr)
                }
                .frame(width: 158, height: 157)
                .background(Color("white-transparent-0.6"))
                .cornerRadius(10)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.navigator.showingSuccessfulAlert = false
                        self.navigator.showingBackground = false
                        self.navigator.backToDeliveryList()
                    }
                }
            }
            .alert(String.uploadingFailedStr, isPresented: $navigator.showingNetworkErrorAlert, actions: {
                Button(String.retryStr, role: nil, action: {
                    self.navigator.showingNetworkErrorAlert = false
                    self.navigator.showingProgressView = true
                    switch failedReason {
                    case .redelivery:
                        self.navigator.failedReDeliveryTry()
                    case .failedContactCustomer:
                        self.navigator.failedDelivery()
                    case .wrongAddress:
                        self.navigator.failedDelivery()
                    case .poBox:
                        self.navigator.failedDelivery()
                    }
                })
                Button(String.saveAndLeaveStr, role: nil, action: {
                    self.navigator.showingNetworkErrorAlert = false
                    self.navigator.showingBackground = false
                    self.navigator.saveFailedUploadedToCoreData()
                })
                Button(String.cancelStr, role: .cancel, action: {
                    self.navigator.showingBackground = false
                    self.navigator.showingNetworkErrorAlert = false
                })
            }, message: {
                Text(String.completeDeliveryPleaseCheckYourNetworkStr)
            })
            .alert(String.savingFailedStr, isPresented: $navigator.showingSaveErrorAlert, actions: {
                Button(String.retryStr, role: nil, action: {
                    self.navigator.showingSaveErrorAlert = false
                    self.navigator.showingBackground = false
                    self.navigator.saveFailedUploadedToCoreData()
                })
                Button(String.cancelStr, role: .cancel, action: {
                    self.navigator.showingBackground = false
                    self.navigator.showingSaveErrorAlert = false
                })
            }, message: {
                Text(String.notEnoughStorageSpaceStr)
            })
        }
    }
    
    func goodsTypeColor() -> Color {
        guard let goodType = packageViewModel.goods_type else {
            return .black
        }
        switch goodType {
        case .regular:
            return .black
        case .medical:
            return Color("light-red")
        }
    }
    
    func deliveryTypeColor() -> Color {
        guard let deliveryType = packageViewModel.express_type else {
            return .black
        }
        switch deliveryType {
        case .regular:
            return .black
        case .express:
            return Color("red-background")
        }
    }
}

struct FailedPackageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FailedPackageDetailView(navigator: FailedDeliveryNavigator(presenter: nil, packageViewModel: PackageViewModel(dataModel: PackageDataModel()), failedReason: .wrongAddress))
    }
}
