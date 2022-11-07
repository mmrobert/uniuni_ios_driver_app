//
//  PhotoReviewView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-08-13.
//

import SwiftUI

struct PhotoReviewView<Navigator>: View where Navigator: TakePhotosViewControllerNavigator {
    
    @ObservedObject private var navigator: Navigator
    
    init(navigator: Navigator) {
        self.navigator = navigator
    }
    
    var body: some View {
        VStack {
            VStack {
                ZStack(){
                    HStack{
                        Image("cross")
                            .resizable()
                            .frame(width: 25, height: 29)
                            .padding(.leading, 30)
                            .onTapGesture {
                                self.navigator.dismissPhotoReview(animated: true, completion: nil)
                            }
                        Spacer()
                    }
                    switch self.navigator.photoTakingFlow {
                    case .taking:
                        if self.navigator.photos.count == 0 {
                            Text(String.firstPhotoStr)
                                .font(.bold(.system(size: 22))())
                                .foregroundColor(Color.white)
                        } else {
                            Text(String.secondPhotoStr)
                                .font(.bold(.system(size: 22))())
                                .foregroundColor(Color.white)
                        }
                    case .review(let index):
                        if index == 0 {
                            Text(String.firstPhotoStr)
                                .font(.bold(.system(size: 22))())
                                .foregroundColor(Color.white)
                        } else {
                            Text(String.secondPhotoStr)
                                .font(.bold(.system(size: 22))())
                                .foregroundColor(Color.white)
                        }
                    }
                }
                .padding(.top, 15)
            }
            .frame(maxWidth: .infinity, minHeight: 114)
            .background(.black)
            
            VStack {
                if let photo = self.navigator.photoTaken {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text(String.noPhotoToReviewStr)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .font(.bold(.system(size: 26))())
                        .foregroundColor(Color.white)
                }
            }
            .background(Color.gray)
            
            HStack {
                Text(String.retakeStr)
                    .padding(.leading, 30)
                    .font(.bold(.system(size: 22))())
                    .foregroundColor(Color.white)
                    .onTapGesture {
                        switch self.navigator.photoTakingFlow {
                        case .taking:
                            self.navigator.dismissPhotoReview(animated: true, completion: nil)
                        case .review(_):
                            self.navigator.presentTakePhotoViewController()
                        }
                    }
                Spacer()
                Text(String.useStr)
                    .padding(.trailing, 30)
                    .font(.bold(.system(size: 22))())
                    .foregroundColor(Color.white)
                    .onTapGesture {
                        switch self.navigator.photoTakingFlow {
                        case .taking:
                            if let photo = self.navigator.photoTaken {
                                self.navigator.photos.append(photo)
                            }
                            self.navigator.dismissPhotoReview(animated: false) {
                                if let navi = self.navigator as? FailedDeliveryNavigator {
                                    switch navi.getFailedReason() {
                                    case .redelivery:
                                        if self.navigator.photos.count == 1 {
                                            self.navigator.dismissPhotoTaking(animated: false, completion: nil)
                                        }
                                    case .failedContactCustomer:
                                        if self.navigator.photos.count == 2 {
                                            self.navigator.dismissPhotoTaking(animated: false, completion: nil)
                                        }
                                    case .wrongAddress, .poBox:
                                        break
                                    }
                                } else {
                                    if self.navigator.photos.count == 2 {
                                        self.navigator.dismissPhotoTaking(animated: false, completion: nil)
                                    }
                                }
                            }
                        case .review(let index):
                            if let photo = self.navigator.photoTaken {
                                self.navigator.photos[index] = photo
                            }
                            self.navigator.dismissPhotoReview(animated: true, completion: nil)
                        }
                    }
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(.black)
        }
    }
}

struct PhotoReviewView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoReviewView(navigator: CompleteDeliveryNavigator(presenter: nil, packageViewModel: PackageViewModel(dataModel: PackageDataModel())))
    }
}
