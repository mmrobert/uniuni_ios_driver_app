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
        VStack {
            Divider()
                .frame(width: 0, height: 0)
            VStack {
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
                .listStyle(.plain)
                .background(.white)
                .searchable(text: $searchString, placement: .navigationBarDrawer(displayMode: .always))
            }
            .navigationTitle(String.searchStr)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button {
                self.naviController?.popViewController(animated: true)
            } label: {
                Image("icon-back")
            })
        }
        .onAppear {
            viewModel.fetchPackagesFromCoreData()
        }
        .onChange(of: selectedPackage) { _ in
            guard let selectedPackage = self.selectedPackage else {
                return
            }
            self.naviController?.popViewController(animated: false)
            
            if let state = selectedPackage.state {
                switch state {
                case .delivering, .delivering231, .delivering232 :
                    let mapView = MapClusterViewController(
                        packagesListViewModel: PackagesListViewModel(),
                        servicesListViewModel: ServicePointsListViewModel(),
                        mapViewModel: MapViewModel())
                    mapView.packageToShowDetail = selectedPackage
                    AppGlobalVariables.shared.originOfDeliveryFlow = .fromList
                    mapView.hidesBottomBarWhenPushed = true
                    self.naviController?.pushViewController(mapView, animated: true)
                case .undelivered211, .undelivered206:
                    let undeliveredVM = UndeliveredPackageDetailViewModel(packageViewModel: selectedPackage)
                    let undeliveredView = UndeliveredPackageDetailView(naviController: self.naviController, viewModel: undeliveredVM)
                    let undeliveredVC = UIHostingController(rootView: undeliveredView)
                    undeliveredVC.hidesBottomBarWhenPushed = true
                    self.naviController?.pushViewController(undeliveredVC, animated: true)
                case .none:
                    break
                }
            }
        }
    }
}

struct PackageSearchView_Previews: PreviewProvider {
    static var previews: some View {
        PackageSearchView()
    }
}
