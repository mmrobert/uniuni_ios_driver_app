//
//  CustomImageAlert.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-08-06.
//

import Foundation
import UIKit

class CustomImageAlert {
    
    static func makeAlert(title: String?, image: UIImage?) -> UIAlertController {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        alert.view.addSubview(imageView)
        alert.view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate(
            [imageView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 15),
             imageView.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -15),
             imageView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 20)]
        )
        
        NSLayoutConstraint.activate(
            [titleLabel.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 15),
             titleLabel.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -15),
             titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
             titleLabel.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -20)]
        )
        
        return alert
    }
}
