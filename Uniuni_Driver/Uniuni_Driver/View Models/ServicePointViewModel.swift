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
    }
    
    init(dataModel: ServicePointDataModel) {
        self.biz_code = dataModel.biz_code
        self.biz_message = dataModel.biz_message
        
        var bizData = Biz_DataViewModel()
        
        bizData.id = dataModel.biz_data?.id
        bizData.name = dataModel.biz_data?.name
        bizData.uni_operator_id = dataModel.biz_data?.uni_operator_id
        bizData.type = dataModel.biz_data?.type
        bizData.code = dataModel.biz_data?.code
        bizData.address = dataModel.biz_data?.address
        bizData.lat = dataModel.biz_data?.lat
        bizData.lng = dataModel.biz_data?.lng
        bizData.district = dataModel.biz_data?.district
        bizData.business_hours = dataModel.biz_data?.business_hours
        bizData.unit_number = dataModel.biz_data?.unit_number
        bizData.phone = dataModel.biz_data?.phone
        bizData.partner_id = dataModel.biz_data?.partner_id
        bizData.company = dataModel.biz_data?.company
        bizData.is_active = dataModel.biz_data?.is_active
        bizData.warehouse = dataModel.biz_data?.warehouse
        bizData.premise_type = dataModel.biz_data?.premise_type
        bizData.device = dataModel.biz_data?.device
        bizData.contact = dataModel.biz_data?.contact
        bizData.login = dataModel.biz_data?.login
        bizData.password = dataModel.biz_data?.password
        bizData.verification_code = dataModel.biz_data?.verification_code
        bizData.storage_space = dataModel.biz_data?.storage_space
        bizData.remark = dataModel.biz_data?.remark
        
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
