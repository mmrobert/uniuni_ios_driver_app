//
//  MapPackageCardView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-09.
//

import Foundation
import UIKit

class MapPackageCardView: UIView {
    
    private struct Constants {
        static let cornerRadius: CGFloat = 18
        static let leadingSpacing: CGFloat = 18
        static let trailingSpacing: CGFloat = 18
        static let topSpacing: CGFloat = 18
        static let bottomSpacing: CGFloat = 18
        static let horizontalSpacing: CGFloat = 12
        static let verticalSpacing: CGFloat = 12
        static let medicalIconWidth: CGFloat = 19
        static let expressTypeWidth: CGFloat = 75
        static let expressTypeHeight: CGFloat = 22
        static let distanceWidth: CGFloat = 120
        static let buttonHeight: CGFloat = 40
    }
    
    struct Theme {
        var backgroundColor: UIColor = .white
        var trackingNoTextColor: UIColor = .black
        var trackingNoTextFont: UIFont = UIFont.boldSystemFont(ofSize: 20)
        var expressTypeTextColor: UIColor? = UIColor.redBackground
        var expressTypeTextFont: UIFont = UIFont.systemFont(ofSize: 12)
        var expressTypeBackgroundColor: UIColor? = UIColor.redBackground
        var receiverAddressTextColor: UIColor = .black
        var receiverAddressTextFont: UIFont = UIFont.systemFont(ofSize: 16)
        var distanceUnitTextFont: UIFont = UIFont.systemFont(ofSize: 10)
        var distanceUnitTextColor: UIColor? = UIColor.lightBlackText
        var distanceValueTextFont: UIFont = UIFont.systemFont(ofSize: 34)
        var distanceValueTextColor: UIColor? = UIColor.highlightedBlue
        var buttonBackgroundColor: UIColor? = UIColor.black
        var buttonTextColor: UIColor? = UIColor.white
        var generalTextColor: UIColor? = UIColor.lightBlackText
        var generalTextFont: UIFont = UIFont.systemFont(ofSize: 12)
        
        static let `default`: Theme = Theme()
    }
    
    private lazy var packageTitleContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var trackingNoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.trackingNoTextFont
        label.textColor = Theme.default.trackingNoTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private lazy var medicalIcon: UIImageView = {
        let imgView = UIImageView(image: nil)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.isUserInteractionEnabled = false
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private lazy var expressTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.expressTypeTextFont
        label.textColor = Theme.default.expressTypeTextColor
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var centerContainer: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.alignment = .center
        return view
    }()
    
    private lazy var receiverAddressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.receiverAddressTextFont
        label.textColor = Theme.default.receiverAddressTextColor
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private lazy var distanceContainer: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.alignment = .center
        return view
    }()
    
    private lazy var distanceUnitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.distanceUnitTextFont
        label.textColor = Theme.default.distanceUnitTextColor
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var distanceValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.distanceValueTextFont
        label.textColor = Theme.default.distanceValueTextColor
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Theme.default.buttonBackgroundColor
        button.setTitleColor(Theme.default.buttonTextColor, for: .normal)
        return button
    }()
    
    private var theme: MapPackageCardView.Theme?
    private var viewModel: MapPackageCardViewModel?
    
    convenience init(viewModel: MapPackageCardViewModel? = nil, theme: MapPackageCardView.Theme? = nil) {
        self.init(frame: .zero)
        self.viewModel = viewModel
        self.theme = theme
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        self.backgroundColor = Theme.default.backgroundColor
        self.layer.cornerRadius = Constants.cornerRadius
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.masksToBounds = true
        
        self.setupTitleContainer()
        self.setupCenterContainer()
        self.setupButton()
    }
    
    func configure(theme: MapPackageCardView.Theme? = nil, viewModel: MapPackageCardViewModel) {
        self.viewModel = viewModel
        self.configureViewModel(viewModel: viewModel)
        guard let theme = theme else {
            self.layoutIfNeeded()
            return
        }
        self.theme = theme
        self.configureTheme(theme: theme)
        self.layoutIfNeeded()
    }
    
    private func configureViewModel(viewModel: MapPackageCardViewModel) {
        self.trackingNoLabel.text = viewModel.trackingNo
        self.receiverAddressLabel.text = (viewModel.receiverAddress ?? "") + " " + (viewModel.receiverZipcode ?? "")
        self.distanceUnitLabel.text = String.distanceStr + "/" + (viewModel.distanceUnit?.getDisplayString() ?? "")
        self.distanceValueLabel.text = String(format: "%.1f", viewModel.receiverDistance ?? 0.0)
        self.button.setTitle(viewModel.buttonTitle, for: .normal)
        
        if viewModel.expressType == .express {
            self.expressTypeLabel.isHidden = false
            self.expressTypeLabel.text = viewModel.expressType?.getDisplayString()
        } else {
            self.expressTypeLabel.isHidden = true
            self.expressTypeLabel.text = nil
        }
        if viewModel.goodsType == .medical {
            self.medicalIcon.image = UIImage.iconMedicalCross
        } else {
            self.medicalIcon.image = nil
        }
    }
    
    private func configureTheme(theme: MapPackageCardView.Theme) {
        
    }
}

// UI set up
extension MapPackageCardView {
    
    private func setupTitleContainer() {
        self.addSubview(self.packageTitleContainer)
        NSLayoutConstraint.activate(
            [packageTitleContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.leadingSpacing),
             packageTitleContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.topSpacing),
             packageTitleContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.trailingSpacing)]
        )
        NSLayoutConstraint.activate(
            [medicalIcon.widthAnchor.constraint(equalToConstant: Constants.medicalIconWidth)]
        )
        NSLayoutConstraint.activate(
            [expressTypeLabel.widthAnchor.constraint(equalToConstant: Constants.expressTypeWidth),
             expressTypeLabel.heightAnchor.constraint(equalToConstant: Constants.expressTypeHeight)]
        )
        self.packageTitleContainer.addSubview(self.trackingNoLabel)
        self.packageTitleContainer.addSubview(self.medicalIcon)
        self.packageTitleContainer.addSubview(self.expressTypeLabel)
        
        NSLayoutConstraint.activate(
            [trackingNoLabel.leadingAnchor.constraint(equalTo: packageTitleContainer.leadingAnchor),
             trackingNoLabel.topAnchor.constraint(equalTo: packageTitleContainer.topAnchor),
             trackingNoLabel.bottomAnchor.constraint(equalTo: packageTitleContainer.bottomAnchor)]
        )
        NSLayoutConstraint.activate(
            [medicalIcon.leadingAnchor.constraint(equalTo: trackingNoLabel.trailingAnchor),
             medicalIcon.centerYAnchor.constraint(equalTo: trackingNoLabel.centerYAnchor)]
        )
        NSLayoutConstraint.activate(
            [expressTypeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: medicalIcon.trailingAnchor),
             expressTypeLabel.centerYAnchor.constraint(equalTo: trackingNoLabel.centerYAnchor),
             expressTypeLabel.trailingAnchor.constraint(equalTo: packageTitleContainer.trailingAnchor)]
        )
    }
    
    private func setupCenterContainer() {
        self.addSubview(self.centerContainer)
        NSLayoutConstraint.activate(
            [centerContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.leadingSpacing),
             centerContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.trailingSpacing),
             centerContainer.topAnchor.constraint(equalTo: packageTitleContainer.bottomAnchor, constant: Constants.verticalSpacing)]
        )
        
        self.centerContainer.addArrangedSubview(self.receiverAddressLabel)
        
        NSLayoutConstraint.activate(
            [distanceContainer.widthAnchor.constraint(equalToConstant: Constants.distanceWidth)]
        )
        
        self.distanceContainer.addArrangedSubview(self.distanceUnitLabel)
        self.distanceContainer.addArrangedSubview(self.distanceValueLabel)
        
        self.centerContainer.addArrangedSubview(self.distanceContainer)
    }
    
    private func setupButton() {
        self.button.layer.cornerRadius = Constants.buttonHeight / 2
        self.button.layer.masksToBounds = true
        self.addSubview(self.button)
        NSLayoutConstraint.activate(
            [button.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)]
        )
        NSLayoutConstraint.activate(
            [button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.leadingSpacing),
             button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.trailingSpacing),
             button.topAnchor.constraint(equalTo: centerContainer.bottomAnchor, constant: Constants.verticalSpacing),
             button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.bottomSpacing)]
        )
    }
}
