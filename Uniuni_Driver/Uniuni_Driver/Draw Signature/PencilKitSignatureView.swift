//
//  PencilKitSignatureView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-05.
//

import Foundation
import UIKit
import PencilKit

public protocol SignatureViewDelegate: AnyObject {
    func signatureViewDidDrawGesture(_ view: PencilKitSignatureView, _ tap: UIGestureRecognizer)
    func signatureViewDidDraw(_ view: PencilKitSignatureView)
}

@available(iOS 13.0, *)
open class PencilKitSignatureView: UIView {

    private var viewReady: Bool = false

    private lazy var canvas: PKCanvasView = PKCanvasView(frame: CGRect.zero)

    // MARK: Public Properties
    open weak var delegate: SignatureViewDelegate?

    open var scale: CGFloat = 10.0
    
    /// The gesture recognizer that the canvas uses to track touch events.
    open var drawingGestureRecognizer: UIGestureRecognizer? {
        return canvas.drawingGestureRecognizer
    }

    /**
    The maximum stroke width.
    */
    open var maximumStrokeWidth: CGFloat = 3 {
        didSet {
            resetTool()
        }
    }

    /**
    The stroke color.
    */
    open var strokeColor: UIColor = UIColor.black {
        didSet {
            resetTool()
        }
    }

    /**
    The stroke alpha.
    */
    open var strokeAlpha: CGFloat = 1

    /**
    The UIImage representation of the signature. Read/write.
    */
    open var signature: UIImage? {
        get {
            canvas.drawing.image(from: bounds, scale: 1.0)
        }

        set {
            guard let data = newValue?.pngData(), let drawing = try? PKDrawing(data: data) else {
                return
            }
            canvas.drawing = drawing
        }
    }

    open func getCroppedSignature() -> UIImage? {
        return autoreleasepool {
            let fullRender = canvas.drawing.image(from: canvas.bounds, scale: scale)
            let bounds = self.scale(
                canvas.drawing.bounds.insetBy(dx: -maximumStrokeWidth/2, dy: -maximumStrokeWidth/2),
                byFactor: fullRender.scale)
            guard let imageRef: CGImage = fullRender.cgImage?.cropping(to: bounds) else { return nil }
            return UIImage(cgImage: imageRef, scale: scale, orientation: fullRender.imageOrientation)
        }
    }

    open var isEmpty: Bool {
        get {
            canvas.drawing.bounds.isEmpty
        }
    }

    open func clear(cache: Bool) {
        canvas.drawing = PKDrawing()
    }

    open func undo() {
        canvas.undoManager?.undo()
    }

    open func redo() {
        canvas.undoManager?.redo()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    override open func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()
        if viewReady {
            return
        }
        viewReady = true
        addConstraint(NSLayoutConstraint(item: canvas, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: canvas, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: canvas, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: canvas, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
    }

    private func initialize() {
        self.backgroundColor = UIColor.black
        canvas.drawingPolicy = .anyInput
        canvas.delegate = self
        canvas.translatesAutoresizingMaskIntoConstraints = false
        addSubview(canvas)
        resetTool()
        configGestureRecognizer()
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }

    private func resetTool() {
        canvas.tool = PKInkingTool(.pen, color: strokeColor.withAlphaComponent(strokeAlpha), width: maximumStrokeWidth)
    }

    private func configGestureRecognizer() {
        canvas.drawingGestureRecognizer.addTarget(self, action: #selector(PencilKitSignatureView.gesture(_:)))
    }

    @objc
    private func gesture(_ gesture: UIGestureRecognizer) {
        delegate?.signatureViewDidDrawGesture(self, gesture)
    }

    private func scale(_ rect: CGRect, byFactor factor: CGFloat) -> CGRect {
        var scaledRect = rect
        scaledRect.origin.x *= factor
        scaledRect.origin.y *= factor
        scaledRect.size.width *= factor
        scaledRect.size.height *= factor
        return scaledRect
    }
}

@available(iOS 13.0, *)
extension PencilKitSignatureView: PKCanvasViewDelegate {
    
    public func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        delegate?.signatureViewDidDraw(self)
    }
}
