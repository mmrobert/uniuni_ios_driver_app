//
//  CameraView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-05.
//

import UIKit

class CameraView<Scanner>: UIView where Scanner: BarCodeScannerProtocol {
    
    private let cornerRadius: CGFloat = 6
    private let borderWidth: CGFloat = 1
    private let borderColor: UIColor = UIColor.white
    private let leadingSpacing: CGFloat = 17
    private let trailingSpacing: CGFloat = 17
    private let topSpacing: CGFloat = 45
    private let bottomSpacing: CGFloat = 45
    
    private lazy var focusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    private var barCodeScanner: Scanner?
    private weak var focusRectLayer: CAShapeLayer?
    
    convenience init(barCodeScanner: Scanner) {
        self.init(frame: .zero)
        self.barCodeScanner = barCodeScanner
        self.backgroundColor = .darkGray
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        self.layoutSubviews()
        self.setupFocusView()
        self.barCodeScanner?.startRunningCaptureSession()
        guard let layer = self.barCodeScanner?.previewLayer else {
            return
        }
        layer.frame = self.bounds
        layer.videoGravity = .resizeAspectFill
        self.layer.insertSublayer(layer, at: 0)
        self.addFocusRect()
    }
    
    private func addFocusRect() {
        // remove any old layers
        self.focusRectLayer?.removeFromSuperlayer()
        
        // camera preview's rect
        let cameraContainerRect: CGRect = self.frame
        // the transparent focus rectangle
        let focusRect: CGRect = self.focusView.frame
        
        // create the path for the preview rect
        let boundingPath = UIBezierPath(roundedRect: cameraContainerRect, cornerRadius: 0)
        
        // append focus rect path to the bounding rect
        let focusRectPath = UIBezierPath(roundedRect: focusRect, cornerRadius: cornerRadius)
        
        boundingPath.append(focusRectPath)
        boundingPath.usesEvenOddFillRule = true
        
        // instantiate the layer and add it as a sublayer
        let fillLayer = CAShapeLayer()
        fillLayer.path = boundingPath.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = 0.5
        
        self.layer.addSublayer(fillLayer)
        self.focusRectLayer = fillLayer
        
        // update the barcode scanner's rectOfInterest
        self.barCodeScanner?.updateScannerRectOfInterest(to: focusRect)
    }
    
    
    private func setupFocusView() {
        self.addSubview(self.focusView)
        NSLayoutConstraint.activate(
            [focusView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leadingSpacing),
             focusView.topAnchor.constraint(equalTo: self.topAnchor, constant: topSpacing),
             focusView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -trailingSpacing),
             focusView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -bottomSpacing)]
        )
    }
}
