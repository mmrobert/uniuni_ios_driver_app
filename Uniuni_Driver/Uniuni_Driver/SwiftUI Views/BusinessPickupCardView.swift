//
//  BusinessPickupCardView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-09-04.
//

import SwiftUI

struct BusinessPickupCardView: View {
    
    init() {}
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image("icon-business-package")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 51, height: 51)
            VStack(alignment: .leading, spacing: 10) {
                Text(String.businessPickupStr)
                    .frame(maxWidth: 172, alignment: .leading)
                    .font(.bold(.system(size: 14))())
                    .foregroundColor(Color("navi-bar-button"))
                Text(String.pickupParcelsFromABusinessPartnerStr)
                    .frame(maxWidth: 172, alignment: .leading)
                    .font(.system(size: 12))
                    .foregroundColor(Color("light-black-text"))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 24)
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 16, trailing: 15))
    }
}

struct BusinessPickupCardView_Previews: PreviewProvider {
    static var previews: some View {
        BusinessPickupCardView()
    }
}
