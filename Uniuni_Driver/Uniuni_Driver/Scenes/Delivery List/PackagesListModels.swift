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
        self.list = list.map { package in
            PackageViewModel(
                serialNo: package.serialNo,
                date: package.date,
                routeNo: package.routeNo,
                name: package.name,
                address: package.address,
                distance: package.distance,
                type: package.type,
                state: package.state
            )
        }
    }
    
    func fetchPackages() {
        self.coreDataManager.$packages
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] packages in
                guard let strongSelf = self else { return }
                strongSelf.list = packages.map { package in
                    return PackageViewModel(
                        serialNo: package.serialNo,
                        date: package.date,
                        routeNo: package.routeNo,
                        name: package.name,
                        address: package.address,
                        distance: package.distance,
                        type: package.type,
                        state: package.state
                    )
                }
            })
            .store(in: &disposables)
        self.coreDataManager.fetchPackages()
    }
    
    func sort(list: [PackageViewModel], by: PackageSort) -> [PackageViewModel] {
        var sorted: [PackageViewModel] = []
        switch by {
        case .date:
            sorted = list.sorted(by: { (lh, rh) -> Bool in
                let lhType = lh.type ?? .regular
                let rhType = rh.type ?? .regular
                let lhDate = lh.date ?? Date.dateTimeString()
                let rhDate = rh.date ?? Date.dateTimeString()
                if lhType.rawValue < rhType.rawValue {
                    return true
                } else if lhType.rawValue > rhType.rawValue {
                    return false
                } else {
                    return lhDate < rhDate
                }
            })
        case .route:
            sorted = list.sorted(by: { (lh, rh) -> Bool in
                let lhType = lh.type ?? .regular
                let rhType = rh.type ?? .regular
                let lhRoute = lh.routeNo ?? ""
                let rhRoute = rh.routeNo ?? ""
                if lhType.rawValue < rhType.rawValue {
                    return true
                } else if lhType.rawValue > rhType.rawValue {
                    return false
                } else {
                    return lhRoute < rhRoute
                }
            })
        case .distance:
            sorted = list.sorted(by: { (lh, rh) -> Bool in
                let lhType = lh.type ?? .regular
                let rhType = rh.type ?? .regular
                let lhDistance = lh.distance ?? ""
                let rhDistance = rh.distance ?? ""
                if lhType.rawValue < rhType.rawValue {
                    return true
                } else if lhType.rawValue > rhType.rawValue {
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
            serialNo: "11111",
            date: "5-8-2022",
            routeNo: "111",
            name: "John Lee",
            address: "2367 Bayview St",
            distance: "30KM Away",
            type: .express,
            state: .delivering
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            serialNo: "22222",
            date: "1-8-2022",
            routeNo: "222",
            name: "Lucy John",
            address: "88367 Grandview Blvd",
            distance: "60KM Away",
            type: .express,
            state: .delivering
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            serialNo: "33333",
            date: "11-10-2022",
            routeNo: "333",
            name: "Kelo Wang",
            address: "8367 Main Ave",
            distance: "20KM Away",
            type: .regular,
            state: .delivering
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            serialNo: "444444488",
            date: "21-12-2022",
            routeNo: "8888",
            name: "Richard Lee",
            address: "1367 Broadway Ave",
            distance: "10KM Away",
            type: .regular,
            state: .undelivered
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            serialNo: "00011",
            date: "5-8-2022",
            routeNo: "111",
            name: "John Lee",
            address: "2367 Bayview St",
            distance: "30KM Away",
            type: .regular,
            state: .undelivered
        ))
    }
}

struct PackageDataModel {
    var serialNo: String?
    var date: String?
    var routeNo: String?
    var name: String?
    var address: String?
    var distance: String?
    var type: PackageType?
    var state: PackageState?
}

struct PackageViewModel: Identifiable {
    var id = UUID()
    var serialNo: String?
    var date: String?
    var routeNo: String?
    var name: String?
    var address: String?
    var distance: String?
    var type: PackageType?
    var state: PackageState?
}

enum PackageState: String {
    case delivering
    case undelivered
    
    static func getStateFrom(description: String?) -> PackageState? {
        guard let description = description else {
            return nil
        }
        return PackageState(rawValue: description)
    }
}

enum PackageType: String {
    case express
    case regular
    
    static func getTypeFrom(description: String?) -> PackageType? {
        guard let description = description else {
            return nil
        }
        return PackageType(rawValue: description)
    }
}

enum PackageSort: String {
    case date
    case route
    case distance
    
    static func getSortFrom(description: String?) -> PackageSort? {
        guard let description = description else {
            return nil
        }
        return PackageSort(rawValue: description)
    }
}
