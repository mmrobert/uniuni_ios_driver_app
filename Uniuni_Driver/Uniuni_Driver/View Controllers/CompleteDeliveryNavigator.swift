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
    private var packageViewModel: PackageViewModel
    @Published var image1: UIImage?
    @Published var image2: UIImage?
    
    init(packageViewModel: PackageViewModel) {
        self.packageViewModel = packageViewModel
    }
    
    func getPackageViewModel() -> PackageViewModel {
        self.packageViewModel
    }
    
    func presentDeliveryDetail(presenter: UIViewController) {
        let contentView = CompletePackageDetailView(navigator: self)
        naviController.viewControllers = [UIHostingController(rootView: contentView)]
        naviController.modalPresentationStyle = .automatic
        naviController.modalTransitionStyle = .crossDissolve
        presenter.present(naviController, animated: true)
    }
    
    func pushImagePickerController() {
        
    }
    
    func dismissNavigator() {
        self.naviController.dismiss(animated: true)
    }
}
