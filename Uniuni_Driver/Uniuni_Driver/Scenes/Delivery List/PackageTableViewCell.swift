//
//  PackageTableViewCell.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-25.
//

import Foundation
import UIKit

class PackageTableViewCell: UITableViewCell {
    
    private struct Constants {
        static let leadingSpacing: CGFloat = 20
        static let trailingSpacing: CGFloat = 20
        static let topSpacing: CGFloat = 10
        static let bottomSpacing: CGFloat = 10
    }
    
    private let cardView: PackageCardView = {
        let view = PackageCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        self.setupUI()
    }
    
    func configure(packageViewModel: PackageViewModel) {
        let cardViewModel = PackageCardViewModel(
            packageNo: packageViewModel.serialNo,
            medicalIcon: UIImage.iconMedicalCross,
            packageType: packageViewModel.type,
            routeNo: packageViewModel.routeNo,
            receiverName: packageViewModel.name,
            receiverAddress: packageViewModel.address,
            receiverDistance: packageViewModel.distance
        )
        self.cardView.configure(viewModel: cardViewModel)
        
        self.layoutIfNeeded()
    }
    
    private func setupUI() {
        self.contentView.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Constants.leadingSpacing),
            cardView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Constants.topSpacing),
            cardView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -Constants.trailingSpacing),
            cardView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Constants.bottomSpacing)])
    }
}
