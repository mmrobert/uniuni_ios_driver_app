//
//  GeoJsonDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-12.
//

import Foundation
import MapboxMaps

struct GeoJsonDataModel {
    
    private struct Constants {
        static let defaultLatitude: Double = 49.0
        static let defaultLongitude: Double = -123.0
        static let defaultRouteNo: Int = 0
    }
    
    static func map(packagesList: [PackageViewModel], selected: String? = nil) -> GeoJSONObject {
        
        var features: [Feature] = []
        for package in packagesList {
            let lat = Double(package.lat ?? "") ?? Constants.defaultLatitude
            let lng = Double(package.lng ?? "") ?? Constants.defaultLongitude
            let point = Point(CLLocationCoordinate2D(latitude: lat, longitude: lng))
            let geometry: Geometry = .point(point)
            var feature = Feature(geometry: geometry)
            feature.identifier = FeatureIdentifier(package.tracking_no ?? "")
            let isExpress = package.express_type == .express ? true : false
            let routeNo = String(package.route_no ?? Constants.defaultRouteNo)
            
            if package.tracking_no == selected {
                feature.properties = ["express": .boolean(isExpress),
                                      "routeNo": .string(routeNo),
                                      "isService": .boolean(false),
                                      "isSelected": .boolean(true)]
            } else {
                feature.properties = ["express": .boolean(isExpress),
                                      "routeNo": .string(routeNo),
                                      "isService": .boolean(false),
                                      "isSelected": .boolean(false)]
            }
            features.append(feature)
        }
        
        let featureCollection = FeatureCollection(features: features)
        return .featureCollection(featureCollection)
    }
    
    static func map(servicesList: [ServicePointViewModel], selected: String? = nil) -> GeoJSONObject {
        
        var features: [Feature] = []
        for service in servicesList {
            let lat = service.lat ?? Constants.defaultLatitude
            let lng = service.lng ?? Constants.defaultLongitude
            let point = Point(CLLocationCoordinate2D(latitude: lat, longitude: lng))
            let geometry: Geometry = .point(point)
            var feature = Feature(geometry: geometry)
            feature.identifier = FeatureIdentifier(service.name ?? "")
            
            if service.name == selected {
                feature.properties = ["isService": .boolean(true),
                                      "isSelected": .boolean(true)]
            } else {
                feature.properties = ["isService": .boolean(true),
                                      "isSelected": .boolean(false)]
            }
            features.append(feature)
        }

        let featureCollection = FeatureCollection(features: features)
        return .featureCollection(featureCollection)
    }
}
