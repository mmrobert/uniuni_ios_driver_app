//
//  CompletePackageDetailView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-08-07.
//

import SwiftUI

struct CompletePackageDetailView: View {
    
    @ObservedObject private var navigator: CompleteDeliveryNavigator
    
    var packageViewModel: PackageViewModel {
        navigator.getPackageViewModel()
    }
    
    init(navigator: CompleteDeliveryNavigator) {
        self.navigator = navigator
    }
    
    var body: some View {
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
            HStack {
                Text(String.photosStr)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
                    .font(.bold(.system(size: 20))())
                    .foregroundColor(.primary)
                Spacer()
            }
            HStack {
                Text(String.take2PhotosStr)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .foregroundColor(.gray)
                Spacer()
            }
            VStack {
                HStack {
                    if let image1 = navigator.image1 {
                        Image(uiImage: image1)
                            .resizable()
                            .frame(width: 110, height: 110)
                    } else {
                        Image("icon-camera")
                            .resizable()
                            .frame(width: 110, height: 110)
                            .onTapGesture {
                                self.navigator.pushImagePickerController()
                            }
                    }
                    if let image2 = navigator.image2 {
                        Image(uiImage: image2)
                            .resizable()
                            .frame(width: 110, height: 110)
                    } else {
                        Image("icon-camera")
                            .resizable()
                            .frame(width: 110, height: 110)
                    }
                    Spacer()
                }
                HStack(alignment: .center) {
                    Button(String.completeStr) {
                        self.navigator.dismissNavigator()
                    }
                    .background(Color(UIColor.tabbarTint ?? .gray))
                    .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
            }
            Spacer()
        }
        .navigationBarTitle(String.deliveredStr)
        .navigationBarItems(leading: Button {
            self.navigator.dismissNavigator()
        } label: {
            Image(systemName: "pencil")
        })
    }
}

struct CompletePackageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CompletePackageDetailView(navigator: CompleteDeliveryNavigator(packageViewModel: PackageViewModel(dataModel: PackageDataModel())))
    }
}
