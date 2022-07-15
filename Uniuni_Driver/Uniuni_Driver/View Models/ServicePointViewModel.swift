//
//  ServicePointViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-12.
//

import Foundation
import Combine

struct ServicePointViewModel: Identifiable {
    var id = UUID()
    var biz_code: String?
    var biz_message: String?
    var biz_data: Biz_DataViewModel?
    
    struct Biz_DataViewModel {
        var id: Int?
        var name: String?
        var address: String?
        var lat: Double?
        var lng: Double?
    }
    
    init(dataModel: ServicePointDataModel) {
        self.biz_code = dataModel.biz_code
        self.biz_message = dataModel.biz_message
        
        var bizData = Biz_DataViewModel()
        
        bizData.id = dataModel.biz_data?.id
        bizData.name = dataModel.biz_data?.name
        bizData.address = dataModel.biz_data?.address
        bizData.lat = dataModel.biz_data?.lat
        bizData.lng = dataModel.biz_data?.lng
        
        self.biz_data = bizData
    }
    
    func getDistanceFrom(location: (lat: Double, lng: Double), distanceUnit: DistanceUnit) -> Double {
        
        let serviceLng = self.biz_data?.lng ?? -122.0
        let theta = location.lng - serviceLng
        let serviceLat = self.biz_data?.lat ?? 49.0
        var dist = sin(deg2rad(deg: location.lat)) * sin(deg2rad(deg: serviceLat)) + cos(deg2rad(deg: location.lat)) * cos(deg2rad(deg: serviceLat)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515
        
        switch distanceUnit {
        case .KM:
            dist = dist * 1.609344
        case .MI:
            dist = dist * 1.0
        }
        
        return dist
    }
    
    private func deg2rad(deg: Double) -> Double {
        return deg * Double.pi / 180
    }
    
    private func rad2deg(rad: Double) -> Double {
        return rad * 180.0 / Double.pi
    }
}
