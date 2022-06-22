//
//  UINavigationController-Extension.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-19.
//

import Foundation
import UIKit

extension UINavigationController {
    
    func configureNavigationBar(isLargeTitle: Bool, backgroundColor: UIColor?, tintColor: UIColor?) {
        navigationBar.prefersLargeTitles = isLargeTitle
        navigationBar.backgroundColor = backgroundColor
        navigationBar.tintColor = tintColor
    }

    func configureStatusBar(backgroundColor: UIColor?) {
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = backgroundColor
        view.addSubview(statusBarView)
    }
}
