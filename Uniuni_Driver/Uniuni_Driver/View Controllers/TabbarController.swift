//
//  TabbarController.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-15.
//

import Foundation
import UIKit
import SwiftUI
import Combine

public enum AppTab {
    case delivery
    case scan
    case income
}

class TabBarController: UITabBarController {
    
    private var disposables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.observeGlobalVariables()

        self.tabBar.backgroundColor = UIColor.tabbarBackground
        self.tabBar.tintColor = UIColor.tabbarTint
        self.viewControllers = [deliveryTab(), scanTab(), incomeTab()]
    }
    
    private func deliveryTab() -> UINavigationController {
        let deliveryVC = DeliveryListViewController(packagesListViewModel: PackagesListViewModel())
        let deliveryNav = UINavigationController(rootViewController: deliveryVC)
        deliveryNav.tabBarItem = UITabBarItem(title: String.deliveryStr, image: UIImage.delivery, tag: 1)
        return deliveryNav
    }
    
    private func scanTab() -> UIViewController {
        let scanView = ScanHomeView(viewModel: ScanHomeViewModel())
        let scanVC = UIHostingController(rootView: scanView)
        
        scanVC.tabBarItem = UITabBarItem(title: String.scanStr, image: UIImage.scan, tag: 2)
        return scanVC
    }
    
    private func incomeTab() -> UINavigationController {
        let incomeVC = UIViewController()  // to be customized in future
        incomeVC.view.backgroundColor = .yellow
        let incomeNav = UINavigationController(rootViewController: incomeVC)
        incomeNav.tabBarItem = UITabBarItem(title: String.incomeStr, image: UIImage.dollar, tag: 3)
        return incomeNav
    }
    
    private func observeGlobalVariables() {
        AppGlobalVariables.shared.$tabBarHiden
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] hiden in
                guard let strongSelf = self else { return }
                strongSelf.tabBar.isHidden = hiden
            })
            .store(in: &disposables)
    }

    public func chooseTab(appTab: AppTab) {
        switch appTab {
        case .delivery:
            selectedIndex = 0
        case .scan:
            selectedIndex = 1
        case .income:
            selectedIndex = 2
        }
    }
}
