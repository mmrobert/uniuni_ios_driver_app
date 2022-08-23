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
        ZStack {
            VStack {
                ScrollView(showsIndicators: false) {
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
                            TitleTextView(title: String.orderTypeStr, text: packageViewModel.goods_type?.getDisplayString())
                            TitleTextView(title: String.routeNoStr, text: "\(packageViewModel.route_no ?? 0)")
                            TitleTextView(title: String.assignedTimeStr, text: packageViewModel.assign_time)
                            TitleTextView(title: String.deliveryTypeStr, text: packageViewModel.express_type?.getDisplayString())
                            TitleTextView(title: String.deliveryAttemptStr, text: packageViewModel.getDeliveryAttemptValue())
                            TitleTextView(title: String.deliveryByStr, text: packageViewModel.delivery_by)
                            TitleTextView(title: String.failedReasonStr, text: failedReason.displayString(), titleColor: .black, textColor: Color("light-blue"))
                        }
                        HStack {
                            Text(String.customerInformationStr)
                                .padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
                                .font(.bold(.system(size: 20))())
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        VStack {
                            TitleTextView(title: String.nameStr, text: packageViewModel.name)
                            TitleTextView(title: String.phoneNumberStr, text: packageViewModel.mobile)
                            TitleTextView(title: String.addressStr, text: ((packageViewModel.address ?? "") + " " + (packageViewModel.zipcode ?? "")))
                        }
                        HStack {
                            Text(String.customerNotesStr)
                                .padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
                                .font(.bold(.system(size: 20))())
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        VStack {
                            TitleTextView(title: String.buzzStr, text: packageViewModel.buzz_code)
                            TitleTextView(title: String.noteStr, text: packageViewModel.postscript)
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
                    case .failedContactCustomer, .redelivery:
                        HStack(spacing: 6) {
                            if navigator.photos.count == 0 {
                                Image("icon-camera")
                                    .resizable()
                                    .frame(width: 110, height: 110)
                                    .background(Color("screen-base"))
                                    .onTapGesture {
                                        self.navigator.startPhotoTakingFlow()
                                    }
                            } else if navigator.photos.count == 1 {
                                Image(uiImage: navigator.photos[0])
                                    .resizable()
                                    .frame(width: 110, height: 110)
                                    .onTapGesture {
                                        self.navigator.startPhotoTakingFlow()
                                    }
                                Image("icon-camera")
                                    .resizable()
                                    .frame(width: 110, height: 110)
                                    .background(Color("screen-base"))
                                    .onTapGesture {
                                        self.navigator.startPhotoTakingFlow()
                                    }
                            } else if navigator.photos.count == 2 {
                                Image(uiImage: navigator.photos[0])
                                    .resizable()
                                    .frame(width: 110, height: 110)
                                    .onTapGesture {
                                        self.navigator.startPhotoReviewFlow(index: 0)
                                    }
                                Image(uiImage: navigator.photos[1])
                                    .resizable()
                                    .frame(width: 110, height: 110)
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
                    case .failedContactCustomer, .redelivery:
                        Button(String.completeStr) {
                            self.navigator.showingBackground = true
                            self.navigator.showingProgressView = true
                            self.navigator.successfulDelivery()
                        }
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .background(Color("tab-bar-tint"))
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .cornerRadius(23)
                        .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        .disabled(self.navigator.photos.count < 2)
                    case .wrongAddress, .poBox:
                        Button(String.completeStr) {
                            self.navigator.showingBackground = true
                            self.navigator.showingProgressView = true
                            self.navigator.successfulDelivery()
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
        .navigationBarItems(leading: Button {
            self.navigator.dismissNavigator()
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
                    navigator.showingSuccessfulAlert = false
                    self.navigator.showingBackground = false
                    self.navigator.dismissNavigator()
                }
            }
        }
        .alert(String.uploadingFailedStr, isPresented: $navigator.showingNetworkErrorAlert, actions: {
            Button(String.retryStr, role: nil, action: {
                self.navigator.showingNetworkErrorAlert = false
                self.navigator.showingProgressView = true
                self.navigator.successfulDelivery()
            })
            Button(String.saveAndLeaveStr, role: nil, action: {
                self.navigator.showingNetworkErrorAlert = false
                self.navigator.saveFailedUploadedToCoreData()
                self.navigator.showingBackground = false
            })
            Button(String.cancelStr, role: .cancel, action: {
                self.navigator.showingBackground = false
                self.navigator.showingNetworkErrorAlert = false
            })
        }, message: {
            Text(String.completeDeliveryPleaseCheckYourNetworkStr)
        })
    }
}

struct FailedPackageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FailedPackageDetailView(navigator: FailedDeliveryNavigator(packageViewModel: PackageViewModel(dataModel: PackageDataModel()), failedReason: .wrongAddress))
    }
}
