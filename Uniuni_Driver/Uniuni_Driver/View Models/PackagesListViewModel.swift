//
//  PackagesListViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-18.
//

import Foundation
import Combine

class PackagesListViewModel: ObservableObject {
    
    let coreDataManager = CoreDataManager.shared
    
    @Published var list: [PackageViewModel] = []
    
    private var disposables = Set<AnyCancellable>()
    
    init(list: [PackageDataModel]? = nil) {
        guard let list = list else {
            return
        }
        self.list = list.map {
            PackageViewModel(dataModel: $0)
        }
    }
    
    func fetchPackages() {
        self.coreDataManager.$packages
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] packages in
                guard let strongSelf = self else { return }
                strongSelf.list = packages.map {
                    return PackageViewModel(dataModel: $0)
                }
            })
            .store(in: &disposables)
        self.coreDataManager.fetchPackages()
    }
    
    func updatePackage(pack: PackageViewModel?) {
        guard let pack = pack else {
            return
        }
        let dataModel = PackageDataModel.dataModelFrom(viewModel: pack)
        self.coreDataManager.updatePackage(package: dataModel)
    }
    
    func sort(list: [PackageViewModel], by: PackageSort, location: (lat: Double, lng: Double)) -> [PackageViewModel] {
        var sorted: [PackageViewModel] = []
        switch by {
        case .date:
            sorted = list.sorted(by: { (lh, rh) -> Bool in
                let lhExpressType = lh.express_type ?? .regular
                let rhExpressType = rh.express_type ?? .regular
                let lhDate = lh.delivery_by ?? Date.dateTimeString()
                let rhDate = rh.delivery_by ?? Date.dateTimeString()
                if lhExpressType.rawValue > rhExpressType.rawValue {
                    return true
                } else if lhExpressType.rawValue < rhExpressType.rawValue {
                    return false
                } else {
                    return lhDate < rhDate
                }
            })
        case .route:
            sorted = list.sorted(by: { (lh, rh) -> Bool in
                let lhExpressType = lh.express_type ?? .regular
                let rhExpressType = rh.express_type ?? .regular
                let lhRoute = lh.route_no ?? 0
                let rhRoute = rh.route_no ?? 0
                if lhExpressType.rawValue > rhExpressType.rawValue {
                    return true
                } else if lhExpressType.rawValue < rhExpressType.rawValue {
                    return false
                } else {
                    return lhRoute < rhRoute
                }
            })
        case .distance:
            sorted = list.sorted(by: { (lh, rh) -> Bool in
                let lhExpressType = lh.express_type ?? .regular
                let rhExpressType = rh.express_type ?? .regular
                
                let lhDistance = lh.getDistanceFrom(location: location, distanceUnit: .KM)
                let rhDistance = rh.getDistanceFrom(location: location, distanceUnit: .KM)
                
                if lhExpressType.rawValue > rhExpressType.rawValue {
                    return true
                } else if lhExpressType.rawValue < rhExpressType.rawValue {
                    return false
                } else {
                    return lhDistance < rhDistance
                }
            })
        }
        return sorted
    }
    
    func saveMockPackagesList() {
        coreDataManager.savePackage(package: PackageDataModel(
            order_id: 11,
            order_sn: "",
            tracking_no: "11111",
            goods_type: .regular,
            express_type: .express,
            route_no: 111,
            assign_time: "",
            delivery_by: "5-1-2022",
            state: .delivering,
            name: "John Lee",
            mobile: "",
            address: "1111 Bayview St",
            zipcode: "11",
            lat: "49.17",
            lng: "-123.11",
            buzz_code: "11",
            postscript: nil,
            failed_handle_type: nil
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            order_id: 22,
            order_sn: "",
            tracking_no: "22222",
            goods_type: .regular,
            express_type: .regular,
            route_no: 222,
            assign_time: "",
            delivery_by: "5-3-2022",
            state: .delivering,
            name: "Lucy Su",
            mobile: "",
            address: "222 Bayview St",
            zipcode: "22",
            lat: "49.25",
            lng: "-122.78",
            buzz_code: "22",
            postscript: nil,
            failed_handle_type: nil
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            order_id: 33,
            order_sn: "",
            tracking_no: "33333",
            goods_type: .medical,
            express_type: .regular,
            route_no: 33,
            assign_time: "",
            delivery_by: "5-4-2022",
            state: .delivering,
            name: "Charlie John",
            mobile: "",
            address: "333 Bayview St",
            zipcode: "33",
            lat: "49.27",
            lng: "-122.86",
            buzz_code: "33",
            postscript: nil,
            failed_handle_type: nil
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            order_id: 999,
            order_sn: "",
            tracking_no: "99999",
            goods_type: .medical,
            express_type: .express,
            route_no: 99,
            assign_time: "",
            delivery_by: "5-4-2019",
            state: .delivering,
            name: "Charlie Peter",
            mobile: "",
            address: "999 Bayview St",
            zipcode: "99",
            lat: "49.27",
            lng: "-122.86",
            buzz_code: "99",
            postscript: nil,
            failed_handle_type: nil
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            order_id: 44,
            order_sn: "",
            tracking_no: "44444",
            goods_type: .medical,
            express_type: .regular,
            route_no: 444,
            assign_time: "",
            delivery_by: "7-1-2022",
            state: .undelivered,
            name: "Peter Lee",
            mobile: "",
            address: "4444 Bayview St",
            zipcode: "44",
            lat: "49.24",
            lng: "-122.98",
            buzz_code: "44",
            postscript: nil,
            failed_handle_type: nil
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            order_id: 55,
            order_sn: "",
            tracking_no: "55555",
            goods_type: .regular,
            express_type: .regular,
            route_no: 555,
            assign_time: "",
            delivery_by: "9-1-2022",
            state: .undelivered,
            name: "Water Lee",
            mobile: "",
            address: "555 Bayview St",
            zipcode: "55",
            lat: "49.25",
            lng: "-123.13",
            buzz_code: "55",
            postscript: nil,
            failed_handle_type: nil
        ))
    }
}

enum PackageSort: String {
    case date
    case route
    case distance
    
    func getDisplayString() -> String {
        switch self {
        case .date:
            return String.dateStr
        case .route:
            return String.routeStr
        case .distance:
            return String.distanceStr
        }
    }
    
    static func getSortFrom(description: String?) -> PackageSort? {
        guard let description = description else {
            return nil
        }
        return PackageSort(rawValue: description)
    }
}
