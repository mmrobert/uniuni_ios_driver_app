//
//  PackagesListModels.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-18.
//

import Foundation
import Combine

class PackagesListViewModel {
    
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
                        state: package.state
                    )
                }
            })
            .store(in: &disposables)
        self.coreDataManager.fetchPackages()
    }
    
    func saveMockPackagesList() {
        coreDataManager.savePackage(package: PackageDataModel(
            serialNo: "11111",
            date: "5-8-2022",
            routeNo: "111",
            name: "John Lee",
            address: "2367 Bayview St",
            distance: "30KM Away",
            state: .delivering
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            serialNo: "22222",
            date: "1-8-2022",
            routeNo: "222",
            name: "Lucy John",
            address: "88367 Grandview Blvd",
            distance: "60KM Away",
            state: .delivering
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            serialNo: "33333",
            date: "11-10-2022",
            routeNo: "333",
            name: "Kelo Wang",
            address: "8367 Main Ave",
            distance: "20KM Away",
            state: .delivering
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            serialNo: "444444488",
            date: "21-12-2022",
            routeNo: "8888",
            name: "Richard Lee",
            address: "1367 Broadway Ave",
            distance: "10KM Away",
            state: .undelivered
        ))
        coreDataManager.savePackage(package: PackageDataModel(
            serialNo: "00011",
            date: "5-8-2022",
            routeNo: "111",
            name: "John Lee",
            address: "2367 Bayview St",
            distance: "30KM Away",
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
    var state: PackageState?
}

struct PackageViewModel {
    var serialNo: String?
    var date: String?
    var routeNo: String?
    var name: String?
    var address: String?
    var distance: String?
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
