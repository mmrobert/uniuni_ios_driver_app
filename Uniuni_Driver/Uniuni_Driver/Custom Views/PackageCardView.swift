//
//  PackageCardView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-25.
//

import Foundation
import UIKit

class PackageCardView: UIView {
    
    private struct Constants {
        static let cornerRadius: CGFloat = 12
        static let leadingSpacing: CGFloat = 12
        static let trailingSpacing: CGFloat = 12
        static let topSpacing: CGFloat = 8
        static let bottomSpacing: CGFloat = 12
        static let horizontalSpacing: CGFloat = 10
        static let verticalSpacing: CGFloat = 12
        static let medicalIconWidth: CGFloat = 19
        static let expressTypeWidth: CGFloat = 75
        static let expressTypeHeight: CGFloat = 22
        static let expressTypeCornerRadius: CGFloat = 11
        static let separatorLineHeight: CGFloat = 1
        static let routeContainerWidth: CGFloat = 120
    }
    
    struct Theme {
        var backgroundColor: UIColor = .white
        var trackingNoTextColor: UIColor = .black
        var trackingNoTextFont: UIFont = UIFont.boldSystemFont(ofSize: 16)
        var expressTypeTextColor: UIColor = .white
        var expressTypeTextFont: UIFont = UIFont.systemFont(ofSize: 12)
        var expressTypeBackgroundColor: UIColor? = UIColor.redBackground
        var separatingLineColor: UIColor? = UIColor.screenBase
        var receiverNameTextColor: UIColor = .black
        var receiverNameTextFont: UIFont = UIFont.boldSystemFont(ofSize: 16)
        var routeValueTextFont: UIFont = UIFont.boldSystemFont(ofSize: 34)
        var routeValueTextColor: UIColor = .black
        var routeLabelTextFont: UIFont = UIFont.systemFont(ofSize: 14)
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
        label.backgroundColor = Theme.default.expressTypeBackgroundColor
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var separatingLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.default.separatingLineColor
        return view
    }()
    
    private lazy var receiverStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 0.3 * Constants.verticalSpacing
        view.distribution = .equalSpacing
        view.alignment = .leading
        return view
    }()
    
    private lazy var receiverNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.receiverNameTextFont
        label.textColor = Theme.default.receiverNameTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private lazy var receiverAddressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.generalTextFont
        label.textColor = Theme.default.generalTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private lazy var receiverDistanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.generalTextFont
        label.textColor = Theme.default.generalTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private lazy var routeContainer: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.alignment = .center
        return view
    }()
    
    private lazy var routeValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.routeValueTextFont
        label.textColor = Theme.default.routeValueTextColor
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var routeLabelLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.routeLabelTextFont
        label.textColor = Theme.default.generalTextColor
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = String.routeStr
        return label
    }()
    
    private var theme: PackageCardView.Theme?
    private var viewModel: PackageCardViewModel?
    
    convenience init(viewModel: PackageCardViewModel? = nil, theme: PackageCardView.Theme? = nil) {
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
        self.layer.masksToBounds = true
        
        self.setupTitleContainer()
        self.setupSeparatingLine()
        self.setupRouteInfo()
        self.setupReceiverInfo()
    }
    
    func configure(theme: PackageCardView.Theme? = nil, viewModel: PackageCardViewModel) {
        self.viewModel = viewModel
        self.configureViewModel(viewModel: viewModel)
        guard let theme = theme else {
            return
        }
        self.theme = theme
        self.configureTheme(theme: theme)
    }
    
    private func configureViewModel(viewModel: PackageCardViewModel) {
        self.trackingNoLabel.text = viewModel.trackingNo
        self.routeValueLabel.text = viewModel.routeNo
        self.receiverNameLabel.text = viewModel.receiverName
        self.receiverAddressLabel.text = viewModel.receiverAddress
        self.receiverDistanceLabel.text = viewModel.receiverDistance
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
    
    private func configureTheme(theme: PackageCardView.Theme) {
        
    }
}

// UI set up
extension PackageCardView {
    
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
        self.expressTypeLabel.layer.cornerRadius = Constants.expressTypeCornerRadius
        self.expressTypeLabel.layer.masksToBounds = true
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
    
    private func setupSeparatingLine() {
        self.addSubview(self.separatingLine)
        NSLayoutConstraint.activate(
            [separatingLine.heightAnchor.constraint(equalToConstant: Constants.separatorLineHeight),
             separatingLine.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.leadingSpacing),
             separatingLine.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.trailingSpacing),
             separatingLine.topAnchor.constraint(equalTo: packageTitleContainer.bottomAnchor, constant: Constants.verticalSpacing)]
        )
    }
    
    private func setupRouteInfo() {
        self.addSubview(self.routeContainer)
        NSLayoutConstraint.activate(
            [routeContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.leadingSpacing),
             routeContainer.widthAnchor.constraint(equalToConstant: Constants.routeContainerWidth)]
        )
        self.routeContainer.addArrangedSubview(self.routeValueLabel)
        self.routeContainer.addArrangedSubview(self.routeLabelLabel)
    }
    
    private func setupReceiverInfo() {
        self.addSubview(self.receiverStackView)
        NSLayoutConstraint.activate(
            [receiverStackView.leadingAnchor.constraint(equalTo: routeContainer.trailingAnchor, constant: Constants.horizontalSpacing),
             receiverStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.trailingSpacing),
             receiverStackView.topAnchor.constraint(equalTo: separatingLine.bottomAnchor, constant: Constants.verticalSpacing),
             receiverStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.bottomSpacing),
             receiverStackView.centerYAnchor.constraint(equalTo: routeContainer.centerYAnchor)]
        )
        self.receiverStackView.addArrangedSubview(self.receiverNameLabel)
        self.receiverStackView.addArrangedSubview(self.receiverAddressLabel)
        self.receiverStackView.addArrangedSubview(self.receiverDistanceLabel)
    }
}
