//
//  MapViewController.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-07.
//

import Foundation
import MapboxMaps

class MapViewController: UIViewController {
    
    private struct Constants {
        static let cornerRadius: CGFloat = 12
        static let navigationBarHeight: CGFloat = 44
        static let titleHeight: CGFloat = 38
        static let separatorLineHeight: CGFloat = 1
        static let leadingSpacing: CGFloat = 16
        static let verticalSpacing: CGFloat = 8
    }
    
    var mapView: MapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = String.routeStr
        self.setupMapView()
        self.setupCurrentLocation()
    }
    
    private func setupMapView() {
        
        mapView = MapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            mapView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        generatePointAnnotations(points: [(49.1, -123.0), (49.1, -123.0), (49.1, -123.0)])
    }
    
    private func setupCurrentLocation() {
        mapView.location.delegate = self
        mapView.location.options.activityType = .other
        mapView.location.options.puckType = .puck2D()
        mapView.location.locationProvider.startUpdatingLocation()
        
        mapView.mapboxMap.onNext(.mapLoaded) { [weak self] _ in
            self?.updateCameraBound(latRegion: (48.85, 49.4), lngRegion: (-123.25, -122.85))
            guard let loc = self?.mapView.location.latestLocation else {
                return
            }
            self?.locationUpdate(newLocation: loc)
        }
    }
    
    private func updateCameraBound(latRegion: (min: Double, max: Double), lngRegion: (min: Double, max: Double)) {
        let coordinates = [
            CLLocationCoordinate2DMake(latRegion.min, lngRegion.min),
            CLLocationCoordinate2DMake(latRegion.min, lngRegion.max),
            CLLocationCoordinate2DMake(latRegion.max, lngRegion.min),
            CLLocationCoordinate2DMake(latRegion.max, lngRegion.max)
        ]
        let camera = mapView.mapboxMap.camera(
            for: coordinates,
            padding: .zero,
            bearing: nil,
            pitch: nil
        )
        mapView.camera.ease(to: camera, duration: 1.0)
    }
    
    private func generatePointAnnotations(points: [(lat: Double, lng: Double)]) {
        
        let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
        pointAnnotationManager.delegate = self
        
        var pointAnnotations: [PointAnnotation] = []
        var ii = 1
        for point in points {
            let pointCoor = CLLocationCoordinate2D(latitude: point.lat, longitude: point.lng)
            var pointAnnotation = PointAnnotation(coordinate: pointCoor)
            if let img = UIImage.mapPinBlack {
                pointAnnotation.image = PointAnnotation.Image(image: img, name: "\(ii)")
                pointAnnotations.append(pointAnnotation)
            }
            ii += 1
        }
        pointAnnotationManager.annotations = pointAnnotations
    }
}

extension MapViewController: AnnotationInteractionDelegate {
    
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        
        print("Annotations tapped: \(annotations)")
    }
}

extension MapViewController: LocationPermissionsDelegate, LocationConsumer {
    
    func locationUpdate(newLocation: Location) {
        let cameraOptions = CameraOptions(center: newLocation.coordinate)
        mapView.camera.ease(to: cameraOptions, duration: 1.0)
    }
}
