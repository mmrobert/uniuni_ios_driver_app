//
//  UnderlinedLabel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-17.
//

import Foundation
import UIKit

class UnderlinedLabel: UILabel {
    
    override var text: String? {
        didSet {
            guard let text = text else { return }
            let textRange = NSRange(location: 0, length: text.count)
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(.underlineStyle,
                                        value: NSUnderlineStyle.single.rawValue,
                                        range: textRange)
            // Add other attributes if needed
            self.attributedText = attributedText
        }
    }
}
