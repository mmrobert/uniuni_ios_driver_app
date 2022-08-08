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
    
    init(title: String?, text: String?) {
        self.title = title
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title ?? "")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .foregroundColor(.gray)
            Spacer()
            Text(text ?? "")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
    }
}

struct TitleTextView_Previews: PreviewProvider {
    static var previews: some View {
        TitleTextView(title: "", text: "")
    }
}
