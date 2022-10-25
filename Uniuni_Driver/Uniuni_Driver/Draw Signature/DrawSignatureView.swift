//
//  DrawSignatureView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-10-05.
//

import Foundation
import SwiftUI

struct DrawSignatureView: UIViewRepresentable {
    
    typealias UIViewType = PencilKitSignatureView
    
    private var delegate: SignatureViewDelegate
    
    init(delegate: SignatureViewDelegate) {
        self.delegate = delegate
    }
    
    func makeUIView(context: UIViewRepresentableContext<DrawSignatureView>) -> PencilKitSignatureView {
        let view = PencilKitSignatureView()
        view.delegate = self.delegate
        return view
    }
    
    func updateUIView(_ uiView: PencilKitSignatureView, context: UIViewRepresentableContext<DrawSignatureView>) {}
    
    static func dismantleUIView(_ uiView: PencilKitSignatureView, coordinator: ()) {}
}
