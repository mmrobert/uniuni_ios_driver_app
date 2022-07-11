//
//  TopActionSheet.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-28.
//

import Foundation
import UIKit

class TopActionSheet: UIViewController {
    
    private struct Constants {
        static let cornerRadius: CGFloat = 12
        static let navigationBarHeight: CGFloat = 44
        static let titleHeight: CGFloat = 38
        static let separatorLineHeight: CGFloat = 1
        static let leadingSpacing: CGFloat = 16
        static let verticalSpacing: CGFloat = 8
    }
    
    struct Theme {
        var backgroundColor: UIColor = .clear
        var backgroundOverlayColor: UIColor = .black.withAlphaComponent(0.2)
        var titleTextFont: UIFont = UIFont.systemFont(ofSize: 13)
        var titleTextColor: UIColor? = UIColor.lightBlackText
        var titleBackgroundColor: UIColor = .white
        var actionsBackgroundColor: UIColor = .white
        var separatorLineColor: UIColor? = UIColor.lightGray198
        var actionTitleFont: UIFont = UIFont.systemFont(ofSize: 17)
        var actionTitleColor: UIColor = UIColor.black
        
        static let `default`: Theme = Theme()
    }
    
    private lazy var backgroundOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.default.backgroundOverlayColor
        return view
    }()
    
    private lazy var titleLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.backgroundColor = Theme.default.titleBackgroundColor
        label.font = Theme.default.titleTextFont
        label.textColor = Theme.default.titleTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var actionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Theme.default.actionsBackgroundColor
        stackView.axis = .vertical
        stackView.spacing = Constants.verticalSpacing
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private var viewModel: TopActionSheetViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Theme.default.backgroundColor
        self.setupBackgroundOverlayView()
        self.setupTitleView()
        self.setupActionsStackView()
    }

    func configure(viewModel: TopActionSheetViewModel, theme: TopActionSheet.Theme? = nil) {
        self.viewModel = viewModel
        self.configureTitleView(viewModel: viewModel, theme: theme)
        self.configureActions(viewModel: viewModel, theme: theme)
        
        self.view.layoutIfNeeded()
    }
    
    private func configureTitleView(viewModel: TopActionSheetViewModel, theme: TopActionSheet.Theme?) {
        self.titleLabel.text = viewModel.title
        guard let theme = theme else { return }
        self.titleLabel.font = theme.titleTextFont
        self.titleLabel.textColor = theme.titleTextColor
    }
    
    private func configureActions(viewModel: TopActionSheetViewModel, theme: TopActionSheet.Theme?) {
        
        for action in viewModel.actions {
            self.actionsStackView.addArrangedSubview(self.createSingleActionView(action: action, theme: theme))
        }
        let bottomSpace = UIView()
        NSLayoutConstraint.activate([
            bottomSpace.heightAnchor.constraint(equalToConstant: Constants.verticalSpacing)
        ])
        self.actionsStackView.addArrangedSubview(bottomSpace)
    }
    
    private func createSingleActionView(action: TopActionSheetViewModel.Action, theme: TopActionSheet.Theme?) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let separatorLine = UIView()
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        let actionLabel = UILabel()
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.isUserInteractionEnabled = true
        actionLabel.text = action.title
        if let theme = theme {
            separatorLine.backgroundColor = theme.separatorLineColor
            actionLabel.font = theme.actionTitleFont
            actionLabel.textColor = theme.actionTitleColor
        } else {
            separatorLine.backgroundColor = Theme.default.separatorLineColor
            actionLabel.font = Theme.default.actionTitleFont
            actionLabel.textColor = Theme.default.actionTitleColor
        }
        let actionTap = UITapGestureRecognizer(target: self, action: #selector(TopActionSheet.actionTapped(sender:)))
        actionLabel.addGestureRecognizer(actionTap)
        
        containerView.addSubview(separatorLine)
        containerView.addSubview(actionLabel)
        
        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.leadingSpacing),
            separatorLine.topAnchor.constraint(equalTo: containerView.topAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: Constants.separatorLineHeight)
        ])
        NSLayoutConstraint.activate([
            actionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.leadingSpacing),
            actionLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: Constants.verticalSpacing),
            actionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            actionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    @objc private func actionTapped(sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else {
            return
        }
        let actions = self.viewModel?.actions.filter { $0.title == label.text }
        if let handler = actions?.first?.handler {
            handler(label.text)
        }
        self.dismiss(animated: true)
    }
}

/// UI set up
extension TopActionSheet {
    
    private func setupBackgroundOverlayView() {
        
        self.view.addSubview(self.backgroundOverlayView)
        NSLayoutConstraint.activate([
            backgroundOverlayView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            backgroundOverlayView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: Constants.navigationBarHeight),
            backgroundOverlayView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            backgroundOverlayView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupTitleView() {
        
        self.titleLabel.padding(top: 0, bottom: 0, left: Constants.leadingSpacing, right: 0)
        self.view.addSubview(self.titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: Constants.navigationBarHeight),
            titleLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: Constants.titleHeight)
        ])
    }
    
    private func setupActionsStackView() {
        
        self.actionsStackView.layer.cornerRadius = Constants.cornerRadius
        self.actionsStackView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.view.addSubview(self.actionsStackView)
        NSLayoutConstraint.activate([
            actionsStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            actionsStackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
            actionsStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}
