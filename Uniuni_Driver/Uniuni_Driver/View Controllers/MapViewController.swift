//
//  MapViewController.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-07.
//

import Foundation
import MapboxMaps
import Combine

class MapViewController: UIViewController {
    
    private var mapView: MapView!
    private var packagesListViewModel: PackagesListViewModel
    private var servicesListViewModel: ServicePointsListViewModel
    private var disposables = Set<AnyCancellable>()
    private var pointAnnotationManager: PointAnnotationManager?
    
    private var currentLocation: (lat: Double, lng: Double)?
    
    private var packagesList: [PackageViewModel] = []
    private var servicesList: [ServicePointViewModel] = []
    
    private var lastShownPackage: String?   // tracking no
    
    private let orangePin = UIImageView(image: UIImage.mapPinOrange)
    private let orangeServicePoint = UIImageView(image: UIImage.mapServiceOrange)
    
    private let cardView: MapPackageCardView = {
        let view = MapPackageCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var cardViewTopConstraint: NSLayoutConstraint?
    
    init(packagesListViewModel: PackagesListViewModel, servicesListViewModel: ServicePointsListViewModel) {
        self.packagesListViewModel = packagesListViewModel
        self.servicesListViewModel = servicesListViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = String.routeStr
        self.setupMapView()
        self.setupCardView()
        
        self.setupCurrentLocation()
        
        self.observingViewModels()
        
        // fetch packages
        self.packagesListViewModel.fetchPackages()
        self.servicesListViewModel.fetchServicePoints()
        //self.servicesListViewModel.saveMockServicesList()
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
    }
    
    private func setupCurrentLocation() {
        mapView.location.delegate = self
        mapView.location.options.activityType = .other
        mapView.location.options.puckType = .puck2D()
        mapView.location.locationProvider.startUpdatingLocation()
    }
    
    private func observingViewModels() {
        Publishers.CombineLatest(self.packagesListViewModel.$list, self.servicesListViewModel.$list)
            .sink(receiveValue: { [weak self] (packList, serviceList) in
                guard let strongSelf = self else { return }
                strongSelf.packagesList = packList
                strongSelf.servicesList = serviceList
                strongSelf.updatePinsShowing(packagesList: packList, servicesList: serviceList)
            })
            .store(in: &disposables)
    }
    
    private func updatePinsShowing(packagesList: [PackageViewModel], servicesList: [ServicePointViewModel]) {
        
        guard packagesList.count > 0 else {
            let defaultLocation = Location(with: CLLocation(latitude: 49.14, longitude: -122.98))
            let loc = self.mapView.location.latestLocation ?? defaultLocation
            let cameraOptions = CameraOptions(center: loc.coordinate, zoom: 12.0)
            self.mapView.camera.fly(to: cameraOptions, duration: 1.0)
            return
        }
        
        let packageRegion = self.findPackageRegion(packagesList: packagesList)
        
        self.updateCameraBound(latRegion: packageRegion.latRegion, lngRegion: packageRegion.lngRegion)
        
        self.generateAnnotations(packagesList: packagesList, servicesList: servicesList)
    }
    
    private func findPackageRegion(packagesList: [PackageViewModel]) -> (latRegion: (min: Double, max: Double), lngRegion: (min: Double, max: Double)) {
        let lats: [Double] = packagesList.compactMap { pack -> Double? in
            Double(pack.lat ?? "")
        }
        let lngs: [Double] = packagesList.compactMap { pack -> Double? in
            Double(pack.lng ?? "")
        }
        
        var latMin = lats.min() ?? 49.0
        var latMax = lats.max() ?? 49.2
        
        if latMin == latMax {
            latMin -= 0.05
            latMax += 0.05
        }
        
        var lngMin = lngs.min() ?? -123.1
        var lngMax = lngs.max() ?? -122.9
        
        if lngMin == lngMax {
            lngMin -= 0.05
            lngMax += 0.05
        }
        
        return ((latMin, latMax), (lngMin, lngMax))
    }
    
    private func updateCameraBound(latRegion: (min: Double, max: Double), lngRegion: (min: Double, max: Double)) {
        let coordinates = [
            CLLocationCoordinate2DMake(latRegion.min, lngRegion.min),
            CLLocationCoordinate2DMake(latRegion.min, lngRegion.max),
            CLLocationCoordinate2DMake(latRegion.max, lngRegion.min),
            CLLocationCoordinate2DMake(latRegion.max, lngRegion.max)
        ]
        let padding = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        let camera = mapView.mapboxMap.camera(
            for: coordinates,
            padding: padding,
            bearing: nil,
            pitch: nil
        )
        mapView.camera.ease(to: camera, duration: 1.0)
    }
    
    private func generateAnnotations(packagesList: [PackageViewModel], servicesList: [ServicePointViewModel]) {
        self.pointAnnotationManager = mapView.annotations.makePointAnnotationManager(id: "UniPointManager", layerPosition: nil)
        self.pointAnnotationManager?.delegate = self
        
        self.pointAnnotationManager?.annotations = self.generatePackageAnnotations(packagesList: packagesList) + self.generateServiceAnnotations(servicesList: servicesList)
    }
    
    private func generatePackageAnnotations(packagesList: [PackageViewModel]) -> [PointAnnotation] {
        
        var pointAnnotations: [PointAnnotation] = []
        
        let notExpress = packagesList.filter {
            $0.express_type != .express
        }.sorted {
            $0.route_no ?? 0 > $1.route_no ?? 0
        }
        for package in notExpress {
            guard let latDouble = Double(package.lat ?? ""), let lngDouble = Double(package.lng ?? "") else {
                continue
            }
            
            let pointCoor = CLLocationCoordinate2D(latitude: latDouble, longitude: lngDouble)
            var pointAnnotation = PointAnnotation(id: package.tracking_no ?? "", coordinate: pointCoor)
            pointAnnotation.userInfo = [
                "trackingNo": package.tracking_no as Any,
                "expressType": package.express_type as Any,
                "routeNo": package.route_no as Any,
                "lat": latDouble,
                "lng": lngDouble
            ]
            let pinBlack = UIImage.mapPinBlack ?? UIImage()
            pointAnnotation.image = PointAnnotation.Image(image: pinBlack, name: package.tracking_no ?? "")
            pointAnnotations.append(pointAnnotation)
        }
        
        let express = packagesList.filter {
            $0.express_type == .express
        }.sorted {
            $0.route_no ?? 0 > $1.route_no ?? 0
        }
        for package in express {
            guard let latDouble = Double(package.lat ?? ""), let lngDouble = Double(package.lng ?? "") else {
                continue
            }
            
            let pointCoor = CLLocationCoordinate2D(latitude: latDouble, longitude: lngDouble)
            var pointAnnotation = PointAnnotation(id: package.tracking_no ?? "", coordinate: pointCoor)
            pointAnnotation.userInfo = [
                "trackingNo": package.tracking_no as Any,
                "expressType": package.express_type as Any,
                "routeNo": package.route_no as Any,
                "lat": latDouble,
                "lng": lngDouble
            ]
            let pinRed = UIImage.mapPinRed ?? UIImage()
            pointAnnotation.image = PointAnnotation.Image(image: pinRed, name: package.tracking_no ?? "")
            pointAnnotations.append(pointAnnotation)
        }
        return pointAnnotations
    }
    
    private func generateServiceAnnotations(servicesList: [ServicePointViewModel]) -> [PointAnnotation] {
        
        var pointAnnotations: [PointAnnotation] = []
        
        for service in servicesList {
            guard let latDouble = service.biz_data?.lat, let lngDouble = service.biz_data?.lng else {
                continue
            }
            
            let pointCoor = CLLocationCoordinate2D(latitude: latDouble, longitude: lngDouble)
            var pointAnnotation = PointAnnotation(id: service.biz_data?.name ?? "", coordinate: pointCoor)
            let serviceBlack = UIImage.mapServiceBlack ?? UIImage()
            pointAnnotation.image = PointAnnotation.Image(image: serviceBlack, name: service.biz_data?.name ?? "")
            pointAnnotations.append(pointAnnotation)
        }
        return pointAnnotations
    }
}

extension MapViewController: AnnotationInteractionDelegate {
    
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        guard annotations.count > 0 else {
            return
        }
        self.restorePinColor()
        let serviceP = annotations.filter { annotation in
            if annotation.id == "YY99" {
                return true
            } else {
                return false
            }
        }.first
        if let serviceP = serviceP as? PointAnnotation {
            self.addOrangeServicePoint(at: serviceP.point.coordinates)
            self.showServicePointCard()
            return
        }
        
        
        let expressPackage = annotations.filter { annotation in
            if let type = annotation.userInfo?["expressType"] as? ExpressType, type == .express {
                return true
            } else {
                return false
            }
        }.sorted { (lh, rh) -> Bool in
            let lhRoute = lh.userInfo?["routeNo"] as? Int ?? 0
            let rhRoute = rh.userInfo?["routeNo"] as? Int ?? 0
            return lhRoute < rhRoute
        }.first
        
        if let expressPackage = expressPackage as? PointAnnotation {
            self.lastShownPackage = expressPackage.userInfo?["trackingNo"] as? String
            self.addOrangePin(at: expressPackage.point.coordinates)
            self.showPackageCard()
            
            return
        }
        
        let regularPackage = annotations.sorted { (lh, rh) -> Bool in
            let lhRoute = lh.userInfo?["routeNo"] as? Int ?? 0
            let rhRoute = rh.userInfo?["routeNo"] as? Int ?? 0
            return lhRoute < rhRoute
        }.first
        
        if let regularPackage = regularPackage as? PointAnnotation {
            self.lastShownPackage = regularPackage.userInfo?["trackingNo"] as? String
            self.addOrangePin(at: regularPackage.point.coordinates)
            self.showPackageCard()
        }
    }
    
    private func showPackageCard() {
        
        guard let trackingNo = self.lastShownPackage else {
            return
        }
        let packToShow = self.packagesList.filter {
            $0.tracking_no == trackingNo
        }.first
        guard let packToShow = packToShow else {
            return
        }
        let currentLocation = self.currentLocation ?? (49.14, -122.98)
        let viewModel = MapPackageCardViewModel(
            packageViewModel: packToShow,
            location: currentLocation,
            buttonTitle: String.parcelDetailsStr
        )
        self.cardView.configure(viewModel: viewModel)
        
        self.cardViewTopConstraint?.constant = -self.cardView.bounds.height
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.cardView.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func showServicePointCard() {
        
        let serviceToShow = self.servicesList.filter {
            $0.biz_data?.name == "YY99"
        }.first
        guard let serviceToShow = serviceToShow else {
            return
        }
        let currentLocation = self.currentLocation ?? (49.14, -122.98)
        let viewModel = MapPackageCardViewModel(
            serviceViewModel: serviceToShow,
            location: currentLocation,
            buttonTitle: String.navigateToServicePointStr
        )
        self.cardView.configure(viewModel: viewModel)
        
        self.cardViewTopConstraint?.constant = -self.cardView.bounds.height
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.cardView.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func restorePinColor() {
        mapView.viewAnnotations.remove(self.orangePin)
        mapView.viewAnnotations.remove(self.orangeServicePoint)
        /*
        guard let lastShown = self.lastShownPackage else {
            return
        }
        guard let pAnnos = self.pointAnnotationManager?.annotations, pAnnos.count > 0 else {
            return
        }
        
        let lastPin = pAnnos.enumerated().filter {
            $0.1.id == lastShown
        }.first
        
        if let lastPin = lastPin {
            let pointCoor = lastPin.1.point.coordinates
            var newPointAnno = PointAnnotation(id: lastPin.1.id, coordinate: pointCoor)
            newPointAnno.userInfo = lastPin.1.userInfo
            
            if let expressType = lastPin.1.userInfo?["expressType"] as? ExpressType, expressType == .express {
                
                let pinRed = UIImage.mapPinRed ?? UIImage()
                newPointAnno.image = PointAnnotation.Image(image: pinRed, name: lastPin.1.id)
                
                self.pointAnnotationManager?.annotations.remove(at: lastPin.0)
                self.pointAnnotationManager?.annotations.insert(newPointAnno, at: lastPin.0)
                
            } else if let expressType = lastPin.1.userInfo?["expressType"] as? ExpressType, expressType == .regular {
                
                let pinBlack = UIImage.mapPinBlack ?? UIImage()
                newPointAnno.image = PointAnnotation.Image(image: pinBlack, name: lastPin.1.id)
                
                self.pointAnnotationManager?.annotations.remove(at: lastPin.0)
                self.pointAnnotationManager?.annotations.insert(newPointAnno, at: lastPin.0)
            }
        }
        */
    }
    
    private func addOrangePin(at coordinate: CLLocationCoordinate2D) {
        let options = ViewAnnotationOptions(
            geometry: Point(coordinate),
            width: nil,
            height: nil,
            associatedFeatureId: nil,
            allowOverlap: false,
            visible: true,
            anchor: .center,
            offsetX: nil,
            offsetY: nil,
            selected: false
        )
        try? mapView.viewAnnotations.add(self.orangePin, options: options)
    }
    
    private func addOrangeServicePoint(at coordinate: CLLocationCoordinate2D) {
        let options = ViewAnnotationOptions(
            geometry: Point(coordinate),
            width: nil,
            height: nil,
            associatedFeatureId: nil,
            allowOverlap: false,
            visible: true,
            anchor: .center,
            offsetX: nil,
            offsetY: nil,
            selected: false
        )
        try? mapView.viewAnnotations.add(self.orangeServicePoint, options: options)
    }
}

extension MapViewController: LocationPermissionsDelegate, LocationConsumer {
    
    func locationUpdate(newLocation: Location) {
        self.currentLocation = (newLocation.coordinate.latitude,
                                newLocation.coordinate.longitude)
    }
}

// card view
extension MapViewController {
    
    private func setupCardView() {
        self.view.addSubview(cardView)
        self.cardViewTopConstraint = cardView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        guard let topConstraint = self.cardViewTopConstraint else {
            return
        }
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            topConstraint,
            cardView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)]
        )
    }
}
