//
//  DeliveryListModels.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-18.
//

import Foundation
import Combine

class DeliveryListViewModel {
    
    @Published var list: [PackageViewModel] = []
    
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
                distance: package.distance
            )
        }
    }
    
    func mockDeliveringList() {
        self.list = [PackageViewModel(
                serialNo: "11111",
                date: "5-8-2022",
                routeNo: "111",
                name: "John Lee",
                address: "2367 Bayview St",
                distance: "30KM Away"
            ),
            PackageViewModel(
                serialNo: "22222",
                date: "1-8-2022",
                routeNo: "222",
                name: "Lucy John",
                address: "88367 Grandview Blvd",
                distance: "60KM Away"
            ),
            PackageViewModel(
                serialNo: "33333",
                date: "11-10-2022",
                routeNo: "333",
                name: "Kelo Wang",
                address: "8367 Main Ave",
                distance: "20KM Away"
            ),
            PackageViewModel(
                serialNo: "444444488",
                date: "21-12-2022",
                routeNo: "8888",
                name: "Richard Lee",
                address: "1367 Broadway Ave",
                distance: "10KM Away"
            )
        ]
    }
    
    func mockUndeliveredList() {
        self.list = [PackageViewModel(
                serialNo: "00011",
                date: "5-8-2022",
                routeNo: "111",
                name: "John Lee",
                address: "2367 Bayview St",
                distance: "30KM Away"
            ),
            PackageViewModel(
                serialNo: "00022",
                date: "1-8-2022",
                routeNo: "211",
                name: "Lucy John",
                address: "88367 Grandview Blvd",
                distance: "60KM Away"
            ),
            PackageViewModel(
                serialNo: "00033",
                date: "11-10-2022",
                routeNo: "311",
                name: "Kelo Wang",
                address: "8367 Main Ave",
                distance: "20KM Away"
            )
        ]
    }
}

struct PackageDataModel {
    var serialNo: String?
    var date: String?
    var routeNo: String?
    var name: String?
    var address: String?
    var distance: String?
}

struct PackageViewModel {
    var serialNo: String?
    var date: String?
    var routeNo: String?
    var name: String?
    var address: String?
    var distance: String?
}
