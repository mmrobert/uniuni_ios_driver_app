//
//  MapClusterViewController.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-12.
//

import Foundation
import MapboxMaps
import Combine

class MapClusterViewController: UIViewController {
    
    private struct Constants {
        static let leadingSpacing: CGFloat = 20
        static let trailingSpacing: CGFloat = 20
        static let topSpacing: CGFloat = 10
        static let bottomSpacing: CGFloat = 10
        static let verticalSpacing: CGFloat = 8
        static let segmentedControlHeight: CGFloat = 48
        static let cornerRadius: CGFloat = 6
        static let borderWidth: CGFloat = 1
        static let stackSpacing: CGFloat = 2
        
        static let packagesSourceID: String = "packages-sources-id"
        static let servicesSourceID: String = "services-sources-id"
        static let clusteredCircleLayerID: String = "clustered-circle-layer-id"
        static let unclusteredSymbolLayerID: String = "unclustered-symbol-layer-id"
        static let clusteredCountLayerID: String = "cluster-count-layer-id"
        static let servicePointsLayerID: String = "service-points-layer-id"
        static let packageBlackIcon: String = "package-black-icon"
        static let packageRedIcon: String = "package-red-icon"
        static let packageOrangeIcon: String = "package-orange-icon"
        static let serviceBlackIcon: String = "service-black-icon"
        static let serviceOrangeIcon: String = "service-orange-icon"
    }
    
    private var mapView: MapView!
    private var packagesListViewModel: PackagesListViewModel
    private var servicesListViewModel: ServicePointsListViewModel
    private var disposables = Set<AnyCancellable>()
    
    private var currentLocation: (lat: Double, lng: Double)?
    
    private var packagesList: [PackageViewModel] = []
    private var servicesList: [ServicePointViewModel] = []
    
    private var lastShownPackage: String?   // tracking no
    
    private let orangePin = UIImageView(image: UIImage.mapPinOrange)
    
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
        
        mapView.mapboxMap.onNext(.styleLoaded) { _ in
            self.setupCluster(packagesList: [])
        }
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
                strongSelf.setupInitZoom(packagesList: packList)
                //strongSelf.setupCluster(packagesList: packList)
            })
            .store(in: &disposables)
    }
    
    private func setupInitZoom(packagesList: [PackageViewModel]) {
        guard packagesList.count > 0 else {
            let defaultLocation = Location(with: CLLocation(latitude: 49.1, longitude: -123.0))
            let loc = self.mapView.location.latestLocation ?? defaultLocation
            let cameraOptions = CameraOptions(center: loc.coordinate, zoom: 12.0)
            self.mapView.camera.fly(to: cameraOptions, duration: 1.0)
            return
        }
        
        let packageRegion = self.findPackageRegion(packagesList: packagesList)
        
        self.updateCameraBound(latRegion: packageRegion.latRegion, lngRegion: packageRegion.lngRegion)
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
    
    private func setupCluster(packagesList: [PackageViewModel]) {
        
        let style = self.mapView.mapboxMap.style
        self.addIconSource(mapStyle: style)
        // Create a GeoJSONSource
        var packageSource = GeoJSONSource()
        packageSource.data = GeoJsonDataModel.map(packagesList: packagesList)
        
        // Set the clustering properties directly on the source.
        packageSource.cluster = true
        packageSource.clusterRadius = 50
        
        // The maximum zoom level where points will be clustered.
        packageSource.clusterMaxZoom = 14
        
        var serviceSource = GeoJSONSource()
        serviceSource.data = GeoJsonDataModel.map(servicesList: [])
        
        // Set the clustering properties directly on the source.
        serviceSource.cluster = false
        
        // Create three separate layers from the same source.
        // clusteredLayer contains clustered point features.
        var clusteredLayer = createClusteredLayer()
        clusteredLayer.source = Constants.packagesSourceID
        
        // unclusteredLayer contains individual point features that do not represent clusters
        var unclusteredLayer = createUnclusteredLayer()
        unclusteredLayer.source = Constants.packagesSourceID
        
        // clusterCountLayer is a SymbolLayer that represents the point count
        // within individual clusters.
        var clusterCountLayer = createNumberLayer()
        clusterCountLayer.source = Constants.packagesSourceID
        
        var servicesLayer = createServicePointsLayer()
        servicesLayer.source = Constants.servicesSourceID
        
        // Add layers to the map view's style
        try! style.addSource(packageSource, id: Constants.packagesSourceID)
        try! style.addSource(serviceSource, id: Constants.servicesSourceID)
        try! style.addLayer(clusteredLayer)
        try! style.addLayer(unclusteredLayer, layerPosition: .below(clusteredLayer.id))
        try! style.addLayer(clusterCountLayer)
        try! style.addLayer(servicesLayer)
    }
    
    private func addIconSource(mapStyle: Style) {
        if let packBlack = UIImage.mapPinBlack {
            try! mapStyle.addImage(
                packBlack,
                id: Constants.packageBlackIcon,
                stretchX: [],
                stretchY: []
            )
        }
        if let packRed = UIImage.mapPinRed {
            try! mapStyle.addImage(
                packRed,
                id: Constants.packageRedIcon,
                stretchX: [],
                stretchY: []
            )
        }
        if let packOrange = UIImage.mapPinOrange {
            try! mapStyle.addImage(
                packOrange,
                id: Constants.packageOrangeIcon,
                stretchX: [],
                stretchY: []
            )
        }
        if let serviceBlack = UIImage.mapServiceBlack {
            try! mapStyle.addImage(
                serviceBlack,
                id: Constants.serviceBlackIcon,
                stretchX: [],
                stretchY: []
            )
        }
        if let serviceOrange = UIImage.mapServiceOrange {
            try! mapStyle.addImage(
                serviceOrange,
                id: Constants.serviceOrangeIcon,
                stretchX: [],
                stretchY: []
            )
        }
    }
    
    private func createClusteredLayer() -> CircleLayer {
        // Create a CircleLayer that only contains clustered points.
        var clusteredLayer = CircleLayer(id: Constants.clusteredCircleLayerID)
        clusteredLayer.filter = Exp(.has) { "point_count" }
        
        // Set the circle's color and radius based on the number of points within each cluster.
        clusteredLayer.circleColor =  .expression(Exp(.step) {
            Exp(.get) { "point_count" }
            UIColor.grayHalfTransparent ?? UIColor.lightGray
            100
            UIColor.grayHalfTransparent ?? UIColor.lightGray
            750
            UIColor.grayHalfTransparent ?? UIColor.lightGray
        })
        
        clusteredLayer.circleRadius = .expression(Exp(.step) {
            Exp(.get) { "point_count" }
            15
            100
            22
            750
            30
        })
        
        return clusteredLayer
    }
    
    private func createUnclusteredLayer() -> SymbolLayer {
        
        var unclusteredLayer = SymbolLayer(id: Constants.unclusteredSymbolLayerID)
        // Filter out clusters by checking for point_count.
        unclusteredLayer.filter = Exp(.not) {
            Exp(.has) { "point_count" }
        }
        
        let expression = Exp(.switchCase) {
            Exp(.eq) {
                Exp(.get) { "express" }
                false
            }
            Constants.packageBlackIcon
            Exp(.eq) {
                Exp(.get) { "express" }
                true
            }
            Constants.packageRedIcon
            ""
        }
        unclusteredLayer.iconImage = .expression(expression)
        
        return unclusteredLayer
    }
    
    private func createNumberLayer() -> SymbolLayer {
        var numberLayer = SymbolLayer(id: Constants.clusteredCountLayerID)
        
        // Check whether the point feature is clustered.
        numberLayer.filter = Exp(.has) { "point_count" }
        
        // Display the value for 'point_count' in the text field.
        numberLayer.textField = .expression(Exp(.get) { "point_count" })
        numberLayer.textSize = .constant(12)
        numberLayer.textColor = .constant(StyleColor(.white))
        return numberLayer
    }
    
    private func createServicePointsLayer() -> SymbolLayer {
        
        var servicesLayer = SymbolLayer(id: Constants.servicePointsLayerID)
        
        servicesLayer.iconImage = .constant(.name(Constants.serviceBlackIcon))
        
        return servicesLayer
    }
}

extension MapClusterViewController: LocationPermissionsDelegate, LocationConsumer {
    
    func locationUpdate(newLocation: Location) {
        self.currentLocation = (newLocation.coordinate.latitude,
                                newLocation.coordinate.longitude)
    }
}

// card view
extension MapClusterViewController {
    
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
