//
//  PackagesListViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-18.
//

import Foundation
import Combine
import SDWebImageSwiftUI

class PackagesListViewModel: ObservableObject {
    
    let coreDataManager = CoreDataManager.shared
    
    @Published var list: [PackageViewModel] = []
    @Published var networkError: NetworkRequestError?
    
    private var failedUploaded: [Int] = []
    
    private var disposables = Set<AnyCancellable>()
    
    init(list: [PackageDataModel]? = nil) {
        guard let list = list else {
            return
        }
        self.list = list.map {
            PackageViewModel(dataModel: $0)
        }
        
        self.coreDataManager.$failedUploadeds
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] failed in
                guard let strongSelf = self else { return }
                strongSelf.failedUploaded = failed
            })
            .store(in: &disposables)
        self.coreDataManager.fetchFailedUploadeds()
        
        let tempToken = AppConfigurator.shared.token
        let bearer = "Bearer \(tempToken)"
        SDWebImageDownloader.shared.setValue(bearer, forHTTPHeaderField: "Authorization")
    }
    
    func fetchPackagesFromAPI(driverID: Int) {
        
        coreDataManager.deleteAllPackages()
        self.list = []
        
        NetworkService.shared.fetchDeliveringList(driverID: driverID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                guard let strongSelf = self else { return }
                switch value {
                case .failure(let error):
                    strongSelf.networkError = error
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] packages in
                guard let strongSelf = self else { return }
                guard let biz_data = packages.biz_data else { return }
                let newData = strongSelf.removeFailedUploaded(biz_data: biz_data)
                strongSelf.savePackagesToCoreData(packs: newData)
                let newVM = newData.map {
                    PackageViewModel(dataModel: $0)
                }
                strongSelf.updatePackagesList(data: newVM)
            })
            .store(in: &disposables)
        
        NetworkService.shared.fetchUndeliveredList(driverID: driverID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                guard let strongSelf = self else { return }
                switch value {
                case .failure(let error):
                    strongSelf.networkError = error
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] packages in
                guard let strongSelf = self else { return }
                guard let biz_data = packages.biz_data else { return }
                let newData = strongSelf.removeFailedUploaded(biz_data: biz_data)
                strongSelf.savePackagesToCoreData(packs: newData)
                let newVM = newData.map {
                    PackageViewModel(dataModel: $0)
                }
                strongSelf.updatePackagesList(data: newVM)
            })
            .store(in: &disposables)
    }
    
    private func updatePackagesList(data: [PackageViewModel]) {
        for pack in data {
            if let packIndex = self.list.firstIndex(where: {
                $0.tracking_no == pack.tracking_no
            }) {
                _ = self.list.remove(at: packIndex)
                self.list.append(pack)
            } else {
                self.list.append(pack)
            }
        }
    }
    
    private func removeFailedUploaded(biz_data: [PackageDataModel]) -> [PackageDataModel] {
        var biz_data = biz_data
        for failed in self.failedUploaded {
            if let packIndex = biz_data.firstIndex(where: {
                $0.order_id == failed
            }) {
                _ = biz_data.remove(at: packIndex)
            }
        }
        return biz_data
    }
    
    private func savePackagesToCoreData(packs: [PackageDataModel]) {
        for pack in packs {
            coreDataManager.savePackage(package: pack)
        }
    }
    
    func fetchPackagesFromCoreData() {
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
    
    func updatePackageForCoreData(pack: PackageViewModel?) {
        guard let pack = pack else {
            return
        }
        let dataModel = PackageDataModel.dataModelFrom(viewModel: pack)
        self.coreDataManager.updatePackage(package: dataModel)
    }
    
    func sort(list: [PackageViewModel], by: PackageSort, location: (lat: Double, lng: Double)) -> [PackageViewModel] {
        var sorted: [PackageViewModel] = []
        switch by {
        case .express:
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
        case .date:
            sorted = list.sorted(by: { (lh, rh) -> Bool in
                let lhDate = lh.delivery_by ?? Date.dateTimeString()
                let rhDate = rh.delivery_by ?? Date.dateTimeString()
                return lhDate < rhDate
            })
        case .route:
            sorted = list.sorted(by: { (lh, rh) -> Bool in
                let lhRoute = lh.route_no ?? 0
                let rhRoute = rh.route_no ?? 0
                return lhRoute < rhRoute
            })
        case .distance:
            sorted = list.sorted(by: { (lh, rh) -> Bool in
                let lhDistance = lh.getDistanceFrom(location: location, distanceUnit: .KM)
                let rhDistance = rh.getDistanceFrom(location: location, distanceUnit: .KM)
                return lhDistance < rhDistance
            })
        }
        return sorted
    }
    
    func saveMockPackagesList() {
        coreDataManager.savePackage(package: PackageDataModel(
            order_id: 11,
            order_sn: "11100",
            tracking_no: "11111",
            goods_type: .regular,
            express_type: .express,
            route_no: 111,
            assign_time: "4-1-2022",
            delivery_by: "5-1-2022",
            state: 202,
            name: "John Lee",
            mobile: "11111111",
            address: "1111 Bayview St",
            address_type: .townhouse,
            zipcode: "11",
            lat: "49.17",
            lng: "-123.11",
            buzz_code: "11",
            postscript: "This pack 11",
            warehouse_id: 1,
            failed_handle_type: .returned
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            order_id: 22,
            order_sn: "22200",
            tracking_no: "22222",
            goods_type: .regular,
            express_type: .regular,
            route_no: 222,
            assign_time: "4-3-2022",
            delivery_by: "5-3-2022",
            state: 202,
            name: "Lucy Su",
            mobile: "222222222",
            address: "222 Bayview St",
            address_type: .house,
            zipcode: "22",
            lat: "49.25",
            lng: "-122.78",
            buzz_code: "220",
            postscript: "This pack 22",
            warehouse_id: 2,
            failed_handle_type: .returned
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            order_id: 33,
            order_sn: "33300",
            tracking_no: "33333",
            goods_type: .medical,
            express_type: .regular,
            route_no: 33,
            assign_time: "5-1-2022",
            delivery_by: "5-4-2022",
            state: 206,
            name: "Charlie John",
            mobile: "33333333",
            address: "333 Bayview St",
            address_type: .business,
            zipcode: "33",
            lat: "49.27",
            lng: "-122.86",
            buzz_code: "33",
            postscript: "This pack 33",
            warehouse_id: 3,
            failed_handle_type: .returned
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            order_id: 999,
            order_sn: "99900",
            tracking_no: "99999",
            goods_type: .medical,
            express_type: .express,
            route_no: 99,
            assign_time: "5-2-2019",
            delivery_by: "5-4-2019",
            state: 211,
            name: "Charlie Peter",
            mobile: "999999999",
            address: "999 Bayview St",
            address_type: .apartment,
            zipcode: "99",
            lat: "49.27",
            lng: "-122.86",
            buzz_code: "99",
            postscript: "This pack 99",
            warehouse_id: 9,
            failed_handle_type: .drop_off
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            order_id: 44,
            order_sn: "44400",
            tracking_no: "44444",
            goods_type: .medical,
            express_type: .regular,
            route_no: 444,
            assign_time: "6-29-2022",
            delivery_by: "7-1-2022",
            state: 211,
            name: "Peter Lee",
            mobile: "444444444",
            address: "4444 Bayview St",
            address_type: .house,
            zipcode: "44",
            lat: "49.24",
            lng: "-122.98",
            buzz_code: "44",
            postscript: "This pack 44",
            warehouse_id: 4,
            failed_handle_type: .drop_off
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            order_id: 55,
            order_sn: "555500",
            tracking_no: "55555",
            goods_type: .regular,
            express_type: .regular,
            route_no: 555,
            assign_time: "8-29-2022",
            delivery_by: "9-1-2022",
            state: 206,
            name: "Water Lee",
            mobile: "55555555",
            address: "555 Bayview St",
            address_type: .business,
            zipcode: "55",
            lat: "49.25",
            lng: "-123.13",
            buzz_code: "55",
            postscript: "This pack 55",
            warehouse_id: 5,
            failed_handle_type: .returned
        ))
    }
}

enum PackageSort: String {
    case express
    case date
    case route
    case distance
    
    func getDisplayString() -> String {
        switch self {
        case .express:
            return String.expressStr
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
