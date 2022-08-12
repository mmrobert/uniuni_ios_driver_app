//
//  CompleteDeliveryNavigator.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-08-07.
//

import UIKit
import Combine
import SwiftUI

class CompleteDeliveryNavigator: ObservableObject {
    
    private var naviController = UINavigationController()
    private var topController: UIViewController?
    private var packageViewModel: PackageViewModel
    @Published var photos: [UIImage] = []
    
    init(packageViewModel: PackageViewModel) {
        self.packageViewModel = packageViewModel
    }
    
    func getPackageViewModel() -> PackageViewModel {
        self.packageViewModel
    }
    
    func presentDeliveryDetail(presenter: UIViewController) {
        let contentView = CompletePackageDetailView(navigator: self)
        let top = UIHostingController(rootView: contentView)
        naviController.viewControllers = [top]
        self.topController = top
        naviController.modalPresentationStyle = .automatic
        naviController.modalTransitionStyle = .crossDissolve
        presenter.present(naviController, animated: true)
    }
    
    func presentTakePhotoViewController() {
        let takePhoto = TakePhotosViewController(navigator: self)
        takePhoto.modalPresentationStyle = .fullScreen
        takePhoto.modalTransitionStyle = .crossDissolve
        topController?.present(takePhoto, animated: true)
    }
    
    func dismissNavigator() {
        self.naviController.dismiss(animated: true)
    }
}
