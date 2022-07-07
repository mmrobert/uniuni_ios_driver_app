//
//  PackagesListModels.swift
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
                let lhRoute = lh.route_no ?? ""
                let rhRoute = rh.route_no ?? ""
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
                
                let lhDistance = lh.getDistanceFrom(location: location)
                let rhDistance = rh.getDistanceFrom(location: location)
                
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
            route_no: "111",
            assign_time: "",
            delivery_by: "5-1-2022",
            state: .delivering,
            name: "John Lee",
            mobile: "",
            address: "1111 Bayview St",
            zipcode: "11",
            lat: "49.294",
            lng: "-123.117",
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
            route_no: "222",
            assign_time: "",
            delivery_by: "5-3-2022",
            state: .delivering,
            name: "Lucy Su",
            mobile: "",
            address: "222 Bayview St",
            zipcode: "22",
            lat: "49.190",
            lng: "-123.536",
            buzz_code: "22",
            postscript: nil,
            failed_handle_type: nil
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            order_id: 33,
            order_sn: "",
            tracking_no: "33333",
            goods_type: .medical,
            express_type: .express,
            route_no: "333",
            assign_time: "",
            delivery_by: "5-4-2022",
            state: .delivering,
            name: "Charlie John",
            mobile: "",
            address: "333 Bayview St",
            zipcode: "33",
            lat: "48.246",
            lng: "-130.041",
            buzz_code: "33",
            postscript: nil,
            failed_handle_type: nil
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            order_id: 44,
            order_sn: "",
            tracking_no: "44444",
            goods_type: .medical,
            express_type: .regular,
            route_no: "444",
            assign_time: "",
            delivery_by: "7-1-2022",
            state: .undelivered,
            name: "Peter Lee",
            mobile: "",
            address: "4444 Bayview St",
            zipcode: "44",
            lat: "51.217",
            lng: "-126.926",
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
            route_no: "555",
            assign_time: "",
            delivery_by: "9-1-2022",
            state: .undelivered,
            name: "Water Lee",
            mobile: "",
            address: "555 Bayview St",
            zipcode: "55",
            lat: "58.268",
            lng: "-128.814",
            buzz_code: "55",
            postscript: nil,
            failed_handle_type: nil
        ))
    }
}

struct PackageViewModel: Identifiable {
    var id = UUID()
    var order_id: Int?
    var order_sn: String?
    var tracking_no: String?
    var goods_type: GoodsType?
    var express_type: ExpressType?
    var route_no: String?
    var assign_time: String?    // 2021-11-25 13:38:42
    var delivery_by: String?    // 2021-11-28 13:38:42
    var state: PackageState?
    var name: String?
    var mobile: String?
    var address: String?
    var zipcode: String?
    var lat: String?
    var lng: String?
    var buzz_code: String?
    var postscript: String?
    var failed_handle_type: FailedHandleType?
    
    init(dataModel: PackageDataModel) {
        self.order_id = dataModel.order_id
        self.order_sn = dataModel.order_sn
        self.tracking_no = dataModel.tracking_no
        self.goods_type = dataModel.goods_type
        self.express_type = dataModel.express_type
        self.route_no = dataModel.route_no
        self.assign_time = dataModel.assign_time
        self.delivery_by = dataModel.delivery_by
        self.state = dataModel.state
        self.name = dataModel.name
        self.mobile = dataModel.mobile
        self.address = dataModel.address
        self.zipcode = dataModel.zipcode
        self.lat = dataModel.lat
        self.lng = dataModel.lng
        self.buzz_code = dataModel.buzz_code
        self.postscript = dataModel.postscript
        self.failed_handle_type = dataModel.failed_handle_type
    }
    
    func getDistanceFrom(location: (lat: Double, lng: Double)) -> Double {
        let latDouble = Double(self.lat ?? "") ?? 49.0
        let lngDouble = Double(self.lng ?? "") ?? -122.0
        
        return sqrt((location.0 - latDouble) * (location.0 - latDouble) + (location.1 - lngDouble) * (location.1 - lngDouble))
    }
}

struct PackageDataModel {
    var order_id: Int?
    var order_sn: String?
    var tracking_no: String?
    var goods_type: GoodsType?
    var express_type: ExpressType?
    var route_no: String?
    var assign_time: String?    // 2021-11-25 13:38:42
    var delivery_by: String?    // 2021-11-28 13:38:42
    var state: PackageState?
    var name: String?
    var mobile: String?
    var address: String?
    var zipcode: String?
    var lat: String?
    var lng: String?
    var buzz_code: String?
    var postscript: String?
    var failed_handle_type: FailedHandleType?
    
    static func dataModelFrom(viewModel: PackageViewModel) -> PackageDataModel {
        return PackageDataModel(
            order_id: viewModel.order_id,
            order_sn: viewModel.order_sn,
            tracking_no: viewModel.tracking_no,
            goods_type: viewModel.goods_type,
            express_type: viewModel.express_type,
            route_no: viewModel.route_no,
            assign_time: viewModel.assign_time,
            delivery_by: viewModel.delivery_by,
            state: viewModel.state,
            name: viewModel.name,
            mobile: viewModel.mobile,
            address: viewModel.address,
            zipcode: viewModel.zipcode,
            lat: viewModel.lat,
            lng: viewModel.lng,
            buzz_code: viewModel.buzz_code,
            postscript: viewModel.postscript,
            failed_handle_type: viewModel.failed_handle_type
        )
    }
}

enum GoodsType: Int {
    case regular = 0
    case medical = 1
    
    func getDisplayString() -> String {
        switch self {
        case .regular:
            return String.regularStr
        case .medical:
            return String.medicalStr
        }
    }
    
    static func getTypeFrom(value: Int?) -> GoodsType? {
        guard let value = value else {
            return nil
        }
        return GoodsType(rawValue: value)
    }
}

enum PackageState: Int {
    case delivering = 202
    case undelivered = 211
    
    func getDisplayString() -> String {
        switch self {
        case .delivering:
            return String.deliveringStr
        case .undelivered:
            return String.undeliveredStr
        }
    }
    
    static func getStateFrom(value: Int?) -> PackageState? {
        guard let value = value else {
            return nil
        }
        return PackageState(rawValue: value)
    }
}

enum ExpressType: Int {
    case regular = 0
    case express = 1
    
    func getDisplayString() -> String {
        switch self {
        case .regular:
            return String.regularStr
        case .express:
            return String.expressStr
        }
    }
    
    static func getTypeFrom(value: Int?) -> ExpressType? {
        guard let value = value else {
            return nil
        }
        return ExpressType(rawValue: value)
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

enum FailedHandleType: Int {
    case wrongAddress = 0
    
    func getDisplayString() -> String {
        switch self {
        case .wrongAddress:
            return String.wrongAddressStr
        }
    }
    
    static func getTypeFrom(value: Int?) -> FailedHandleType? {
        guard let value = value else {
            return nil
        }
        return FailedHandleType(rawValue: value)
    }
}
