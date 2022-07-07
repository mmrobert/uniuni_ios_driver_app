//
//  PackageSearchView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-03.
//

import SwiftUI

struct PackageSearchView: View {
    
    @ObservedObject var viewModel = PackagesListViewModel()
    @State private var searchString = ""

        var body: some View {
            List {
                ForEach(searchString == "" ? viewModel.list : viewModel.list.filter {
                    guard let trackingNo = $0.tracking_no else {
                        return false
                    }
                    return trackingNo.contains(searchString)
                }) {
                    SearchCellView(package: $0)
                }
            }
            .navigationTitle(String.searchStr)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchPackages()
            }
            .searchable(text: $searchString, placement: .navigationBarDrawer(displayMode: .always))
        }
}

struct PackageSearchView_Previews: PreviewProvider {
    static var previews: some View {
        PackageSearchView()
    }
}
