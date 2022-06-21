//
//  TabbarController.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-15.
//

import Foundation
import UIKit

public enum AppTab {
    case delivery
    case scan
    case income
}

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.backgroundColor = UIColor.tabbarBackground
        self.tabBar.tintColor = UIColor.tabbarTint
        self.viewControllers = [deliveryTab(), scanTab(), incomeTab()]
    }
    
    private func deliveryTab() -> UINavigationController {
        let deliveryVC = DeliveryListViewController(
            deliveringViewModel: DeliveryListViewModel(),
            undeliveredViewModel: DeliveryListViewModel()
        )
        let deliveryNav = UINavigationController(rootViewController: deliveryVC)
        deliveryNav.tabBarItem = UITabBarItem(title: String.deliveryStr, image: UIImage.delivery, tag: 1)
        return deliveryNav
    }
    
    private func scanTab() -> UINavigationController {
        let scanVC = UIViewController()  // to be customized in future
        scanVC.view.backgroundColor = .white
        let scanNav = UINavigationController(rootViewController: scanVC)
        scanNav.tabBarItem = UITabBarItem(title: String.scanStr, image: UIImage.scan, tag: 2)
        return scanNav
    }
    
    private func incomeTab() -> UINavigationController {
        let incomeVC = UIViewController()  // to be customized in future
        incomeVC.view.backgroundColor = .yellow
        let incomeNav = UINavigationController(rootViewController: incomeVC)
        incomeNav.tabBarItem = UITabBarItem(title: String.incomeStr, image: UIImage.dollar, tag: 3)
        return incomeNav
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
