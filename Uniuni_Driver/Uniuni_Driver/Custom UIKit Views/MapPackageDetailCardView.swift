//
//  MapPackageDetailCardView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-17.
//

import Foundation
import UIKit
import Combine

class MapPackageDetailCardView: UIView {
    
    private struct Constants {
        static let cornerRadius: CGFloat = 18
        static let leadingSpacing: CGFloat = 18
        static let trailingSpacing: CGFloat = 18
        static let topSpacing: CGFloat = 18
        static let bottomSpacing: CGFloat = 18
        static let horizontalSpacing: CGFloat = 12
        static let verticalSpacing: CGFloat = 5
        static let addressTypeWidth: CGFloat = 90
        static let addressTypeHeight: CGFloat = 20
        static let addressTypeBorderWidth: CGFloat = 1
        static let routeContainerWidth: CGFloat = 100
        static let buttonHeight: CGFloat = 40
    }
    
    struct Theme {
        var backgroundColor: UIColor = .white
        var routeValueTextFont: UIFont = UIFont.boldSystemFont(ofSize: 34)
        var routeValueTextColor: UIColor = .black
        var routeLabelTextFont: UIFont = UIFont.systemFont(ofSize: 14)
        var nameTextColor: UIColor = .black
        var nameTextFont: UIFont = UIFont.boldSystemFont(ofSize: 16)
        var addressTextColor: UIColor = .black
        var addressTextFont: UIFont = UIFont.boldSystemFont(ofSize: 16)
        var remindingTextColor: UIColor = .white
        var remindingTextFont: UIFont = UIFont.systemFont(ofSize: 14)
        var remindingBackgroundColor: UIColor? = UIColor.lightRed
        var buzzNoteTextColor: UIColor? = UIColor.lightBlue
        var buzzNoteTextFont: UIFont = UIFont.systemFont(ofSize: 16)
        var failedBtnColor: UIColor? = UIColor.naviBarButton
        var deliveredBtnColor: UIColor? = UIColor.tabbarTint
        var buttonTitleColor: UIColor = UIColor.white
        var buttonFont: UIFont = UIFont.boldSystemFont(ofSize: 17)
        
        var generalTextColor: UIColor? = UIColor.lightBlackText
        var generalTextFont: UIFont = UIFont.systemFont(ofSize: 12)
        
        static let `default`: Theme = Theme()
    }
    
    private lazy var packDetailContainer1: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.alignment = .leading
        view.spacing = -4
        return view
    }()
    
    private lazy var signatureRemindingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.backgroundColor = Theme.default.remindingBackgroundColor
        label.font = Theme.default.remindingTextFont
        label.textColor = Theme.default.remindingTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private lazy var routeAddressContainer: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 16
        view.distribution = .fill
        view.alignment = .bottom
        return view
    }()
    
    private lazy var routeContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
        label.textColor = UIColor.lightGray160
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var addressTypeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.naviBarButton, for: .normal)
        button.titleLabel?.font = Theme.default.generalTextFont
        button.layer.cornerRadius = Constants.addressTypeHeight / 2
        button.layer.borderWidth = Constants.addressTypeBorderWidth
        button.layer.borderColor = UIColor.naviBarButton?.cgColor
        button.layer.masksToBounds = true
        
        return button
    }()
    
    private lazy var addressContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.nameTextFont
        label.textColor = Theme.default.nameTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private lazy var phoneLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.nameTextFont
        label.textColor = Theme.default.generalTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private lazy var addressLabel: UnderlinedLabel = {
        let label = UnderlinedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.addressTextFont
        label.textColor = Theme.default.addressTextColor
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.generalTextFont
        label.textColor = Theme.default.generalTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private lazy var orderTypeLabel: LeadingTitleLabel = {
        let label = LeadingTitleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var customerSignatureLabel: LeadingTitleLabel = {
        let label = LeadingTitleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var assignedTimeLabel: LeadingTitleLabel = {
        let label = LeadingTitleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var deliveryTypeLabel: LeadingTitleLabel = {
        let label = LeadingTitleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var deliveryAttemptLabel: LeadingTitleLabel = {
        let label = LeadingTitleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var deliveryByLabel: LeadingTitleLabel = {
        let label = LeadingTitleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var buzzLabel: LeadingTitleLabel = {
        let theme = LeadingTitleLabel.Theme(
            backgroundColor: nil,
            leadingTitleTextColor: UIColor.lightBlue,
            leadingTitleTextFont: nil,
            mainTextColor: UIColor.lightBlue,
            mainTextFont: nil
        )
        let label = LeadingTitleLabel(theme: theme)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var noteLabel: LeadingTitleLabel = {
        let theme = LeadingTitleLabel.Theme(
            backgroundColor: nil,
            leadingTitleTextColor: UIColor.lightBlue,
            leadingTitleTextFont: nil,
            mainTextColor: UIColor.lightBlue,
            mainTextFont: nil
        )
        let label = LeadingTitleLabel(theme: theme)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var buttonsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var failedButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Theme.default.failedBtnColor
        button.setTitleColor(Theme.default.buttonTitleColor, for: .normal)
        button.titleLabel?.font = Theme.default.buttonFont
        button.layer.cornerRadius = Constants.buttonHeight / 2
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var deliveredButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Theme.default.deliveredBtnColor
        button.setTitleColor(Theme.default.buttonTitleColor, for: .normal)
        button.titleLabel?.font = Theme.default.buttonFont
        button.layer.cornerRadius = Constants.buttonHeight / 2
        button.layer.masksToBounds = true
        return button
    }()
    
    private var theme: MapPackageDetailCardView.Theme?
    private var viewModel: MapPackageDetailCardViewModel?
    
    private var signatureRemindingHeightConstraint: NSLayoutConstraint?
    
    var chooseAddressTypeAction: (() -> Void)?
    var navigationAction: (() -> Void)?
    var longPressAddressAction: (() -> Void)?
    var phoneMsgAction: (() -> Void)?
    
    var deliveredAction: (() -> Void)?
    var failedAction: (() -> Void)?
    
    convenience init(theme: MapPackageDetailCardView.Theme? = nil) {
        self.init(frame: .zero)
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
        
        self.setupRouteContainer()
        self.setupAddressContainer()
        self.setupRouteAddressContainer()
        self.setupPackDetailContainer1()
        self.setupSignatureReminding()
        self.setupPackDetailContainer2()
        self.setupButtons()
        
        guard let theme = self.theme else {
            return
        }
        self.configureTheme(theme: theme)
    }
    
    func configure(theme: MapPackageDetailCardView.Theme? = nil, viewModel: MapPackageDetailCardViewModel) {
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
    
    private func configureViewModel(viewModel: MapPackageDetailCardViewModel) {
        self.routeValueLabel.text = "\(viewModel.routeNo ?? 0)"
        self.routeLabelLabel.text = String.routeStr
        let addType = viewModel.addressType?.getDisplayString() ?? String.addressTypeStr
        self.addressTypeButton.setTitle(addType, for: .normal)
        self.nameLabel.text = viewModel.name
        self.phoneLabel.text = viewModel.phone
        self.addressLabel.text = viewModel.address
        self.distanceLabel.text = viewModel.distance?.kmDistance()
        var orderTypeTheme = LeadingTitleLabel.Theme.default
        let orderType = viewModel.goodsType ?? .regular
        switch orderType {
        case .regular:
            orderTypeTheme.mainTextColor = UIColor.lightGray160
        case .medical:
            orderTypeTheme.mainTextColor = UIColor.lightRed
        }
        self.orderTypeLabel.configure(theme: orderTypeTheme, leadingTitle: String.orderTypeStr + ":", mainText: viewModel.goodsType?.getDisplayString(), textToRight: false)
        
        var signatureLabelText = ""
        if let signature = viewModel.SG, signature == 1 {
            signatureLabelText = String.yesStr
        } else {
            signatureLabelText = String.noStr
        }
        self.customerSignatureLabel.configure(theme: nil, leadingTitle: String.customerSignatureStr + ":", mainText: signatureLabelText, textToRight: false)
        
        self.assignedTimeLabel.configure(theme: nil, leadingTitle: String.assignedTimeStr + ":", mainText: viewModel.assignedTime, textToRight: false)
        var deliveryTypeTheme = LeadingTitleLabel.Theme.default
        let deliveryType = viewModel.expressType ?? .regular
        switch deliveryType {
        case .regular:
            deliveryTypeTheme.mainTextColor = UIColor.lightGray160
        case .express:
            deliveryTypeTheme.mainTextColor = UIColor.redBackground
        }
        self.deliveryTypeLabel.configure(theme: deliveryTypeTheme, leadingTitle: String.deliveryTypeStr + ":", mainText: viewModel.expressType?.getDisplayString(), textToRight: false)
        
        if let needRetry = viewModel.needRetry, needRetry > 0 {
            self.deliveryAttemptLabel.configure(theme: nil, leadingTitle: String.deliveryAttemptStr, mainText: viewModel.getDeliveryAttemptValue(maxAttempt: 3), textToRight: false)
        } else {
            self.deliveryAttemptLabel.configure(theme: nil, leadingTitle: String.deliveryAttemptStr, mainText: viewModel.getDeliveryAttemptValue(maxAttempt: 1), textToRight: false)
        }
        
        self.deliveryByLabel.configure(theme: nil, leadingTitle: String.deliveryByStr + ":", mainText: viewModel.deliveryBy, textToRight: false)
        self.signatureRemindingLabel.text = String.thisParcelRequiresCustomerSignatureStr
        if viewModel.SG == 1 {
            self.signatureRemindingHeightConstraint?.constant = 28
        } else {
            self.signatureRemindingHeightConstraint?.constant = 0
        }
        self.buzzLabel.configure(theme: nil, leadingTitle: String.buzzStr + ":", mainText: viewModel.buzz, textToRight: false)
        self.noteLabel.configure(theme: nil, leadingTitle: String.noteStr + ":", mainText: viewModel.note, textToRight: false)
        self.failedButton.setTitle(viewModel.failedButtonTitle, for: .normal)
        self.deliveredButton.setTitle(viewModel.deliveredButtonTitle, for: .normal)
        
        self.addressTypeButton.addTarget(self, action: #selector(MapPackageDetailCardView.toChooseAddressType), for: .touchUpInside)
        
        self.deliveredButton.addTarget(self, action: #selector(MapPackageDetailCardView.deliveredTapped), for: .touchUpInside)
        self.failedButton.addTarget(self, action: #selector(MapPackageDetailCardView.failedTapped), for: .touchUpInside)
        
        self.addressLabel.isUserInteractionEnabled = true
        let navigationTap = UITapGestureRecognizer(target: self, action: #selector(MapPackageDetailCardView.navigationCheck))
        self.addressLabel.addGestureRecognizer(navigationTap)
        
        let addressLongPress = UILongPressGestureRecognizer(target: self, action: #selector(MapPackageDetailCardView.addressLongPressCheck))
        self.addressLabel.addGestureRecognizer(addressLongPress)
        
        self.phoneLabel.isUserInteractionEnabled = true
        let phoneTap = UITapGestureRecognizer(target: self, action: #selector(MapPackageDetailCardView.phoneCheck))
        self.phoneLabel.addGestureRecognizer(phoneTap)
    }
    
    private func configureTheme(theme: MapPackageDetailCardView.Theme) {
        
    }
    
    @objc
    private func toChooseAddressType() {
        self.chooseAddressTypeAction?()
    }
    
    @objc
    private func phoneCheck() {
        self.phoneMsgAction?()
    }
    
    @objc
    private func navigationCheck() {
        self.navigationAction?()
    }
    
    @objc
    private func addressLongPressCheck() {
        self.longPressAddressAction?()
    }
    
    @objc
    private func deliveredTapped() {
        self.deliveredAction?()
    }
    
    @objc
    private func failedTapped() {
        self.failedAction?()
    }
    
    func updateAddressType(addressType: AddressType) {
        self.addressTypeButton.setTitle(addressType.getDisplayString(), for: .normal)
        self.viewModel?.addressType = addressType
    }
}

// UI set up
extension MapPackageDetailCardView {
    
    private func setupRouteContainer() {
        
        NSLayoutConstraint.activate(
            [routeContainer.widthAnchor.constraint(equalToConstant: Constants.routeContainerWidth)]
        )
        
        self.routeContainer.addSubview(routeValueLabel)
        NSLayoutConstraint.activate(
            [routeValueLabel.topAnchor.constraint(equalTo: routeContainer.topAnchor, constant: Constants.verticalSpacing),
             routeValueLabel.centerXAnchor.constraint(equalTo: routeContainer.centerXAnchor)]
        )
        self.routeContainer.addSubview(routeLabelLabel)
        NSLayoutConstraint.activate(
            [routeLabelLabel.topAnchor.constraint(equalTo: routeValueLabel.bottomAnchor, constant: -Constants.verticalSpacing),
             routeLabelLabel.centerXAnchor.constraint(equalTo: routeContainer.centerXAnchor)]
        )
        self.routeContainer.addSubview(addressTypeButton)
        NSLayoutConstraint.activate(
            [addressTypeButton.widthAnchor.constraint(equalToConstant: Constants.addressTypeWidth),
             addressTypeButton.heightAnchor.constraint(equalToConstant: Constants.addressTypeHeight),
             addressTypeButton.topAnchor.constraint(equalTo: routeLabelLabel.bottomAnchor, constant: 2 * Constants.verticalSpacing),
             addressTypeButton.bottomAnchor.constraint(equalTo: routeContainer.bottomAnchor, constant: -Constants.verticalSpacing),
             addressTypeButton.centerXAnchor.constraint(equalTo: routeContainer.centerXAnchor)]
        )
    }
    
    private func setupAddressContainer() {
        
        self.addressContainer.addSubview(nameLabel)
        NSLayoutConstraint.activate(
            [nameLabel.topAnchor.constraint(equalTo: addressContainer.topAnchor, constant: Constants.verticalSpacing),
             nameLabel.leadingAnchor.constraint(equalTo: addressContainer.leadingAnchor),
             nameLabel.trailingAnchor.constraint(equalTo: addressContainer.trailingAnchor)]
        )
        self.addressContainer.addSubview(phoneLabel)
        NSLayoutConstraint.activate(
            [phoneLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
             phoneLabel.leadingAnchor.constraint(equalTo: addressContainer.leadingAnchor),
             phoneLabel.trailingAnchor.constraint(equalTo: addressContainer.trailingAnchor)]
        )
        self.addressContainer.addSubview(addressLabel)
        NSLayoutConstraint.activate(
            [addressLabel.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 2 * Constants.verticalSpacing),
             addressLabel.leadingAnchor.constraint(equalTo: addressContainer.leadingAnchor),
             addressLabel.trailingAnchor.constraint(equalTo: addressContainer.trailingAnchor)]
        )
        self.addressContainer.addSubview(distanceLabel)
        NSLayoutConstraint.activate(
            [distanceLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor),
             distanceLabel.leadingAnchor.constraint(equalTo: addressContainer.leadingAnchor),
             distanceLabel.trailingAnchor.constraint(equalTo: addressContainer.trailingAnchor),
             distanceLabel.bottomAnchor.constraint(equalTo: addressContainer.bottomAnchor, constant: -4)]
        )
    }
    
    private func setupRouteAddressContainer() {
        self.routeAddressContainer.addArrangedSubview(routeContainer)
        self.routeAddressContainer.addArrangedSubview(addressContainer)
        
        self.addSubview(routeAddressContainer)
        NSLayoutConstraint.activate(
            [routeAddressContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.leadingSpacing),
             routeAddressContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.topSpacing),
             routeAddressContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.trailingSpacing)]
        )
    }
    
    private func setupPackDetailContainer1() {
        self.addSubview(packDetailContainer1)
        NSLayoutConstraint.activate(
            [packDetailContainer1.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.leadingSpacing),
             packDetailContainer1.topAnchor.constraint(equalTo: routeAddressContainer.bottomAnchor, constant: 5),
             packDetailContainer1.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.trailingSpacing)]
        )
        
        self.packDetailContainer1.addArrangedSubview(orderTypeLabel)
        self.packDetailContainer1.addArrangedSubview(customerSignatureLabel)
        self.packDetailContainer1.addArrangedSubview(assignedTimeLabel)
        self.packDetailContainer1.addArrangedSubview(deliveryTypeLabel)
        self.packDetailContainer1.addArrangedSubview(deliveryAttemptLabel)
        self.packDetailContainer1.addArrangedSubview(deliveryByLabel)
    }
    
    private func setupSignatureReminding() {
        self.addSubview(signatureRemindingLabel)
        self.signatureRemindingHeightConstraint = signatureRemindingLabel.heightAnchor.constraint(equalToConstant: 28)
        guard let heightConstraint = self.signatureRemindingHeightConstraint else {
            return
        }
        NSLayoutConstraint.activate(
            [signatureRemindingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 26),
             signatureRemindingLabel.topAnchor.constraint(equalTo: packDetailContainer1.bottomAnchor, constant: 4),
             signatureRemindingLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -26),
             heightConstraint]
        )
    }
    
    private func setupPackDetailContainer2() {
        self.addSubview(buzzLabel)
        self.addSubview(noteLabel)
        NSLayoutConstraint.activate(
            [buzzLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.leadingSpacing),
             buzzLabel.topAnchor.constraint(equalTo: signatureRemindingLabel.bottomAnchor, constant: 4),
             buzzLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.trailingSpacing),
             buzzLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18)]
        )
        NSLayoutConstraint.activate(
            [noteLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.leadingSpacing),
             noteLabel.topAnchor.constraint(equalTo: buzzLabel.bottomAnchor, constant: 4),
             noteLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.trailingSpacing)]
        )
    }
    
    private func setupButtons() {
        
        self.buttonsContainer.addSubview(self.failedButton)
        NSLayoutConstraint.activate(
            [failedButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
             failedButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 3),
             failedButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
             failedButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
             failedButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor)]
        )
        self.buttonsContainer.addSubview(self.deliveredButton)
        NSLayoutConstraint.activate(
            [deliveredButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
             deliveredButton.leadingAnchor.constraint(equalTo: failedButton.trailingAnchor, constant: Constants.horizontalSpacing),
             deliveredButton.centerYAnchor.constraint(equalTo: failedButton.centerYAnchor),
             deliveredButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor)]
        )
        self.addSubview(buttonsContainer)
        NSLayoutConstraint.activate(
            [buttonsContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.leadingSpacing),
             buttonsContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.trailingSpacing),
             buttonsContainer.topAnchor.constraint(equalTo: noteLabel.bottomAnchor, constant: 3 * Constants.verticalSpacing),
             buttonsContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.bottomSpacing)]
        )
    }
}
