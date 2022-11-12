//
//  LeadingTitleLabel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-17.
//

import Foundation
import UIKit

class LeadingTitleLabel: UIView {
    
    private struct Constants {
        static let leadingSpacing: CGFloat = 8
        static let trailingSpacing: CGFloat = 8
        static let topSpacing: CGFloat = 2
        static let bottomSpacing: CGFloat = 2
        static let horizontalSpacing: CGFloat = 10
    }
    
    struct Theme {
        var backgroundColor: UIColor? = .white
        var leadingTitleTextColor: UIColor? = UIColor.lightGray160
        var leadingTitleTextFont: UIFont? = UIFont.systemFont(ofSize: 14)
        var mainTextColor: UIColor? = UIColor.lightGray160
        var mainTextFont: UIFont? = UIFont.systemFont(ofSize: 16)
        
        static let `default`: Theme = Theme()
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.leadingTitleTextFont
        label.textColor = Theme.default.leadingTitleTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Theme.default.mainTextFont
        label.textColor = Theme.default.mainTextColor
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private var theme: LeadingTitleLabel.Theme?
    
    convenience init(theme: LeadingTitleLabel.Theme? = nil) {
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
        
        self.setupTitleLabel()
        self.setupMainLabel()
        
        guard let theme = self.theme else {
            return
        }
        self.configureTheme(theme: theme)
    }
    
    func configure(theme: LeadingTitleLabel.Theme? = nil, leadingTitle: String?, mainText: String?, textToRight: Bool = false) {
        if textToRight {
            self.mainLabel.textAlignment = .right
        } else {
            self.mainLabel.textAlignment = .left
        }
        self.titleLabel.text = leadingTitle
        self.mainLabel.text = mainText
        guard let theme = theme else {
            self.layoutIfNeeded()
            return
        }
        self.theme = theme
        self.configureTheme(theme: theme)
        self.layoutIfNeeded()
    }
    
    private func configureTheme(theme: LeadingTitleLabel.Theme) {
        self.backgroundColor = theme.backgroundColor ?? Theme.default.backgroundColor
        self.titleLabel.font = theme.leadingTitleTextFont ?? Theme.default.leadingTitleTextFont
        self.titleLabel.textColor = theme.leadingTitleTextColor ?? Theme.default.leadingTitleTextColor
        self.mainLabel.font = theme.mainTextFont ?? Theme.default.mainTextFont
        self.mainLabel.textColor = theme.mainTextColor ?? Theme.default.mainTextColor
    }
}

// UI set up
extension LeadingTitleLabel {
    
    private func setupTitleLabel() {
        self.addSubview(self.titleLabel)
        NSLayoutConstraint.activate(
            [titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.leadingSpacing),
             titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.topSpacing)]
        )
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    private func setupMainLabel() {
        self.addSubview(self.mainLabel)
        NSLayoutConstraint.activate(
            [mainLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Constants.horizontalSpacing),
             mainLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.trailingSpacing),
             mainLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.topSpacing),
             mainLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.bottomSpacing)]
        )
    }
}
