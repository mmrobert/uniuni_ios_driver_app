//
//  CompletePackageDetailView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-08-07.
//

import SwiftUI
import MapboxDirections

struct CompletePackageDetailView: View {
    
    @ObservedObject private var navigator: CompleteDeliveryNavigator
    @State private var scrollViewContentSize: CGSize = .zero
    
    @State private var showingSignatureConfirm: Bool = false
    
    var packageViewModel: PackageViewModel {
        navigator.getPackageViewModel()
    }
    
    init(navigator: CompleteDeliveryNavigator) {
        self.navigator = navigator
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            
                            ZStack {
                                Color("light-red")
                                HStack {
                                    Text(String.thisParcelRequiresCustomerSignatureStr)
                                        .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 0))
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                            .padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
                            .isHidden(!self.requiredSignatureReminding())
                            
                            HStack {
                                Text(String.orderInformationStr)
                                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
                                    .font(.bold(.system(size: 20))())
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            VStack {
                                TitleTextView(title: String.trackingNoStr, text: packageViewModel.tracking_no)
                                TitleTextView(title: String.routeNoStr, text: "\(packageViewModel.route_no ?? 0)")
                                TitleTextView(title: String.orderTypeStr, text: packageViewModel.goods_type?.getDisplayString())
                                TitleTextView(title: String.customerSignatureStr, text: requiredCustomerSignature())
                                TitleTextView(title: String.assignedTimeStr, text: packageViewModel.assign_time)
                                TitleTextView(title: String.deliveryTypeStr, text: packageViewModel.express_type?.getDisplayString())
                                TitleTextView(title: String.deliveryAttemptStr, text: packageViewModel.getDeliveryAttemptValue())
                                TitleTextView(title: String.deliveryByStr, text: packageViewModel.delivery_by)
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
                                TitleTextView(title: String.addressStr, text: (packageViewModel.address ?? ""))
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
                            HStack {
                                Text(String.photosStr)
                                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
                                    .font(.bold(.system(size: 20))())
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            HStack {
                                switch (packageViewModel.goods_type ?? .regular) {
                                case .regular:
                                    Text(String.take2PhotosStr)
                                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                        .foregroundColor(.gray)
                                case .medical:
                                    Text(String.take2PhotosMedicationStr)
                                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
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
                        Button(String.completeStr) {
                            if packageViewModel.SG == 1 {
                                self.showingSignatureConfirm = true
                            } else {
                                self.showingSignatureConfirm = false
                                self.navigator.showingBackground = true
                                self.navigator.showingProgressView = true
                                self.navigator.successfulDelivery()
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .background(self.navigator.photos.count < 2 ? Color("tab-bar-tint").opacity(0.4) : Color("tab-bar-tint"))
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .cornerRadius(23)
                        .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        .disabled(self.navigator.photos.count < 2)
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
            .navigationBarTitle(String.deliveredStr)
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
                    self.navigator.successfulDelivery()
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
            .alert(String.signatureStr, isPresented: $showingSignatureConfirm, actions: {
                Button(String.yesStr, role: nil, action: {
                    self.showingSignatureConfirm = false
                    self.navigator.showingBackground = true
                    self.navigator.showingProgressView = true
                    self.navigator.successfulDelivery()
                })
                Button(String.noStr, role: .cancel, action: {
                    self.showingSignatureConfirm = false
                })
            }, message: {
                Text(String.signatureConfirmStr)
            })
        }
    }
    
    private func requiredCustomerSignature() -> String {
        if packageViewModel.SG == 1 {
            return String.yesStr
        } else {
            return String.noStr
        }
    }
    
    private func requiredSignatureReminding() -> Bool {
        if packageViewModel.SG == 1 {
            return true
        } else {
            return false
        }
    }
}

struct CompletePackageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CompletePackageDetailView(navigator: CompleteDeliveryNavigator(presenter: nil, packageViewModel: PackageViewModel(dataModel: PackageDataModel())))
    }
}
