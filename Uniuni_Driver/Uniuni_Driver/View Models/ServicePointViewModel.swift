//
//  ServicePointViewModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-12.
//

import Foundation
import Combine

struct ServicePointViewModel {
    var id: Int?
    var name: String?
    var uni_operator_id: Int?
    var type: Int?
    var code: String?
    var address: String?
    var lat: Double?
    var lng: Double?
    var district: Int?
    var business_hours: String?
    var unit_number: String?
    var phone: String?
    var partner_id: Int?
    var company: String?
    var is_active: Int?
    var warehouse: Int?
    var premise_type: String?
    var device: String?
    var contact: String?
    var login: String?
    var password: String?
    var verification_code: Int?
    var storage_space: Int?
    var remark: String?
    
    init(dataModel: ServicePointDataModel) {
        
        self.id = dataModel.id
        self.name = dataModel.name
        self.uni_operator_id = dataModel.uni_operator_id
        self.type = dataModel.type
        self.code = dataModel.code
        self.address = dataModel.address
        self.lat = dataModel.lat
        self.lng = dataModel.lng
        self.district = dataModel.district
        self.business_hours = dataModel.business_hours
        self.unit_number = dataModel.unit_number
        self.phone = dataModel.phone
        self.partner_id = dataModel.partner_id
        self.company = dataModel.company
        self.is_active = dataModel.is_active
        self.warehouse = dataModel.warehouse
        self.premise_type = dataModel.premise_type
        self.device = dataModel.device
        self.contact = dataModel.contact
        self.login = dataModel.login
        self.password = dataModel.password
        self.verification_code = dataModel.verification_code
        self.storage_space = dataModel.storage_space
        self.remark = dataModel.remark
    }
    
    func getDistanceFrom(location: (lat: Double, lng: Double), distanceUnit: DistanceUnit) -> Double {
        
        let serviceLng = self.lng ?? -122.0
        let theta = location.lng - serviceLng
        let serviceLat = self.lat ?? 49.0
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
