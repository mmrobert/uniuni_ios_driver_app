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
    case pickup
    case profile
}

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.backgroundColor = .gray
        self.tabBar.tintColor = .white
        self.viewControllers = [deliveryTab(), pickupTab(), profileTab()]
    }
    
    private func deliveryTab() -> UIViewController {
        let deliveryVC = UIViewController()  // to be customized in future
        deliveryVC.view.backgroundColor = .lightGray
        let deliveryNav = UINavigationController(rootViewController: deliveryVC)
        let deliveryStr = NSLocalizedString("Delivery", comment: "")
        deliveryNav.tabBarItem = UITabBarItem(title: deliveryStr, image: nil, tag: 1)
        return deliveryNav
    }
    
    private func pickupTab() -> UIViewController {
        let pickupVC = UIViewController()  // to be customized in future
        pickupVC.view.backgroundColor = .white
        let pickupNav = UINavigationController(rootViewController: pickupVC)
        let pickupStr = NSLocalizedString("Pickup", comment: "")
        pickupNav.tabBarItem = UITabBarItem(title: pickupStr, image: nil, tag: 2)
        return pickupNav
    }
    
    private func profileTab() -> UIViewController {
        let profileVC = UIViewController()  // to be customized in future
        profileVC.view.backgroundColor = .yellow
        let profileNav = UINavigationController(rootViewController: profileVC)
        let profileStr = NSLocalizedString("Profile", comment: "")
        profileNav.tabBarItem = UITabBarItem(title: profileStr, image: nil, tag: 3)
        return profileNav
    }

    public func chooseTab(appTab: AppTab) {
        switch appTab {
        case .delivery:
            selectedIndex = 0
        case .pickup:
            selectedIndex = 1
        case .profile:
            selectedIndex = 2
        }
    }
}
