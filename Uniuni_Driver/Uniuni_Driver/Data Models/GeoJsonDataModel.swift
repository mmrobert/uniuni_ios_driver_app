//
//  GeoJsonDataModel.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-12.
//

import Foundation
import MapboxMaps

struct GeoJsonDataModel {
    
    static func map(packagesList: [PackageViewModel]) -> GeoJSONSourceData {
        
        var features: [Feature] = []
        
        for package in packagesList {
            
            let lat = Double(package.lat ?? "") ?? 49.0
            let lng = Double(package.lng ?? "") ?? -123.0
            let point = Point(CLLocationCoordinate2D(latitude: lat, longitude: lng))
            let geometry: Geometry = .point(point)
            var feature = Feature(geometry: geometry)
            feature.identifier = FeatureIdentifier(package.tracking_no ?? "")
            let isExpress = package.express_type == .express ? true : false
            feature.properties = ["express": .boolean(isExpress)]
            features.append(feature)
        }
        
        for i in 1...5 {
            var lat: Double
            var lng: Double
            if i == 4 {
                lat = 49.1 + Double(i - 1) * 0.001
                lng = -123.0 + Double(i - 1) * 0.001
            } else {
                lat = 49.1 + Double(i) * 0.001
                lng = -123.0 + Double(i) * 0.001
            }
            let point = Point(CLLocationCoordinate2D(latitude: lat, longitude: lng))
            let geometry: Geometry = .point(point)
            var feature = Feature(geometry: geometry)
            feature.identifier = FeatureIdentifier(String(i))
            if i == 3 {
                feature.properties = ["express": .boolean(true)]
            } else {
                feature.properties = ["express": .boolean(false)]
            }
            
            features.append(feature)
        }

        let featureCollection = FeatureCollection(features: features)
        return .featureCollection(featureCollection)
    }
    
    static func map(servicesList: [ServicePointViewModel]) -> GeoJSONSourceData {
        
        var features: [Feature] = []
        
        for service in servicesList {
            
            let lat = service.biz_data?.lat ?? 49.0
            let lng = service.biz_data?.lng ?? -123.0
            let point = Point(CLLocationCoordinate2D(latitude: lat, longitude: lng))
            let geometry: Geometry = .point(point)
            var feature = Feature(geometry: geometry)
            feature.identifier = FeatureIdentifier(service.biz_data?.name ?? "")
            features.append(feature)
        }
        
        let lat = 49.15
        let lng = -123.0
        let point = Point(CLLocationCoordinate2D(latitude: lat, longitude: lng))
        let geometry: Geometry = .point(point)
        var feature = Feature(geometry: geometry)
        feature.identifier = FeatureIdentifier("spoint")
        features.append(feature)

        let featureCollection = FeatureCollection(features: features)
        return .featureCollection(featureCollection)
    }
}
