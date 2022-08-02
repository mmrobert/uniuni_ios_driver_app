//
//  PackageSearchView.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-03.
//

import SwiftUI

struct PackageSearchView: View {
    
    var naviController: UINavigationController?
    
    @ObservedObject var viewModel = PackagesListViewModel()
    @State private var searchString = ""
    @State private var selectedPackage: PackageViewModel?
    
    var body: some View {
        List {
            ForEach(searchString == "" ? viewModel.list : viewModel.list.filter {
                guard let trackingNo = $0.tracking_no else {
                    return false
                }
                return trackingNo.contains(searchString)
            }) {
                SearchCellView(package: $0, selectedPackage: $selectedPackage)
            }
        }
        .navigationTitle(String.searchStr)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchPackagesFromCoreData()
        }
        .searchable(text: $searchString, placement: .navigationBarDrawer(displayMode: .always))
        .onChange(of: selectedPackage) { _ in
            guard let selectedPackage = self.selectedPackage else {
                return
            }
            self.naviController?.popViewController(animated: false)
            let mapView = MapClusterViewController(
                packagesListViewModel: PackagesListViewModel(),
                servicesListViewModel: ServicePointsListViewModel(),
                mapViewModel: MapViewModel())
            mapView.packageToShowDetail = selectedPackage
            self.naviController?.pushViewController(mapView, animated: true)
        }
    }
}

struct PackageSearchView_Previews: PreviewProvider {
    static var previews: some View {
        PackageSearchView()
    }
}
