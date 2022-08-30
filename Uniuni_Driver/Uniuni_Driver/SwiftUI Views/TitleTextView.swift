//
//  TitleTextView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-08-07.
//

import SwiftUI

struct TitleTextView: View {
    
    private var title: String?
    private var text: String?
    private var titleColor: Color = .gray
    private var textColor: Color = .black
    
    init(title: String?, text: String?, titleColor: Color? = nil, textColor: Color? = nil) {
        self.title = title
        self.text = text
        if let titleColor = titleColor {
            self.titleColor = titleColor
        }
        if let textColor = textColor {
            self.textColor = textColor
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title ?? "")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .foregroundColor(titleColor)
            Spacer()
            Text(text ?? "")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .foregroundColor(textColor)
                .lineLimit(nil)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct TitleTextView_Previews: PreviewProvider {
    static var previews: some View {
        TitleTextView(title: "", text: "")
    }
}
