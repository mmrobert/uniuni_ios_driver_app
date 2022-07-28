//
//  MapClusterViewController.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-07-12.
//

import Foundation
import MapboxMaps
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import Combine

class MapClusterViewController: UIViewController {
    
    private struct Constants {
        static let leadingSpacing: CGFloat = 20
        static let trailingSpacing: CGFloat = 20
        static let topSpacing: CGFloat = 10
        static let bottomSpacing: CGFloat = 10
        static let verticalSpacing: CGFloat = 8
        static let segmentedControlHeight: CGFloat = 48
        
        
        static let featureQueryAreaWidth: CGFloat = 36
        static let mapZoneUpdateDuration: TimeInterval = 1.0
        static let defaultLocation: CLLocation = CLLocation(latitude: 49.2, longitude: -123.0)
        static let mapZonePadding: CGFloat = 25
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
    
    private var currentLocation: CLLocation = Constants.defaultLocation
    
    private var packagesList: [PackageViewModel] = []
    private var servicesList: [ServicePointViewModel] = []
    
    private let orangePin = UIImageView(image: UIImage.mapPinOrange)
    private let orangeServicePoint = UIImageView(image: UIImage.mapServiceOrange)
    
    private let cardView: MapPackageCardView = {
        let view = MapPackageCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let detailCardView: MapPackageDetailCardView = {
        let view = MapPackageDetailCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var cardViewTopConstraint: NSLayoutConstraint?
    private var detailCardViewTopConstraint: NSLayoutConstraint?
    
    var packageToShowDetail: PackageViewModel?
    
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
        self.setupDetailCardView()
        self.setupCurrentLocation()
        
        //self.servicesListViewModel.saveMockServicesList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showDetailPackageCard()
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
        
        mapView.mapboxMap.onNext(.styleLoaded) { [weak self] _ in
            self?.setupCluster()
        }
        mapView.mapboxMap.onNext(.mapLoaded) { [weak self] _ in
            self?.setupInitZoom()
            self?.setupSingleTapAction()
            // fetch packages
            self?.observingViewModels()
            self?.packagesListViewModel.fetchPackages()
            self?.servicesListViewModel.fetchServicePoints()
        }
    }
    
    private func setupInitZoom() {
        let defaultLocation = Location(with: Constants.defaultLocation)
        let loc = self.mapView.location.latestLocation ?? defaultLocation
        let cameraOptions = CameraOptions(center: loc.coordinate, zoom: 12.0)
        self.mapView.camera.fly(to: cameraOptions, duration: Constants.mapZoneUpdateDuration)
    }
    
    private func setupCurrentLocation() {
        mapView.location.delegate = self
        mapView.location.options.activityType = .other
        mapView.location.options.puckType = .puck2D()
        mapView.location.locationProvider.startUpdatingLocation()
    }
    
    private func setupSingleTapAction() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(MapClusterViewController.handleMapSingleTap(sender:)))
        mapView.addGestureRecognizer(singleTap)
    }
    
    @objc
    private func handleMapSingleTap(sender: UITapGestureRecognizer) {
        
        guard let solidView = sender.view as? MapView else { return }
        
        guard (try? solidView.mapboxMap.style.source(withId: Constants.packagesSourceID) as? GeoJSONSource) != nil  else {
            return
        }
        
        guard sender.state == .ended else {
            return
        }
        
        let point = sender.location(in: solidView)
        let queryLayerIds = [Constants.clusteredCircleLayerID,
                             Constants.unclusteredSymbolLayerID,
                             Constants.servicePointsLayerID]
        let queryOptions = RenderedQueryOptions(layerIds: queryLayerIds, filter: nil)
        let rect = CGRect(
            x: point.x - Constants.featureQueryAreaWidth / 2,
            y: point.y - Constants.featureQueryAreaWidth / 2,
            width: Constants.featureQueryAreaWidth,
            height: Constants.featureQueryAreaWidth
        )
        solidView.mapboxMap.queryRenderedFeatures(
            in: rect,
            options: queryOptions
        ) { [weak solidView, weak self] tappedQueryResult in
            guard let feature = try? tappedQueryResult.get().first?.feature else {
                return
            }
            if let pointCount = (feature.properties?["point_count"] as? JSONValue)?.rawValue as? Double, pointCount > 0 {
                solidView?.mapboxMap.getGeoJsonClusterLeaves(
                    forSourceId: Constants.packagesSourceID,
                    feature: feature,
                    limit: 20,
                    offset: 0
                ) { result in
                    switch result {
                    case .success(let value):
                        let packFeature = value.features?.filter { ft in
                            let isService = (ft.properties?["isService"] as? JSONValue)?.rawValue as? Bool
                            if let isService = isService, !isService {
                                return true
                            } else {
                                return false
                            }
                        }
                        let express = packFeature?.filter { ft in
                            if let isExpress = (ft.properties?["express"] as? JSONValue)?.rawValue as? Bool, isExpress {
                                return true
                            } else {
                                return false
                            }
                        }.sorted(by: { (lh, rh) -> Bool in
                            let lhRouteNo = (lh.properties?["routeNo"] as? JSONValue)?.rawValue as? String
                            let rhRouteNo = (rh.properties?["routeNo"] as? JSONValue)?.rawValue as? String
                            if let lhRouteNo = Int(lhRouteNo ?? ""), let rhRouteNo = Int(rhRouteNo ?? "") {
                                return lhRouteNo < rhRouteNo
                            } else {
                                return false
                            }
                        }).first
                        let regular = packFeature?.filter { ft in
                            if let isExpress = (ft.properties?["express"] as? JSONValue)?.rawValue as? Bool, !isExpress {
                                return true
                            } else {
                                return false
                            }
                        }.sorted(by: { (lh, rh) -> Bool in
                            let lhRouteNo = (lh.properties?["routeNo"] as? JSONValue)?.rawValue as? String
                            let rhRouteNo = (rh.properties?["routeNo"] as? JSONValue)?.rawValue as? String
                            if let lhRouteNo = Int(lhRouteNo ?? ""), let rhRouteNo = Int(rhRouteNo ?? "") {
                                return lhRouteNo < rhRouteNo
                            } else {
                                return false
                            }
                        }).first
                        if let express = express {
                            self?.showPackageCard(feature: express)
                        } else if let regular = regular {
                            self?.showPackageCard(feature: regular)
                        }
                    case .failure(let error):
                        print("No deep cluster \(error.localizedDescription)")
                    }
                }
            } else {
                self?.restoreViewAnnotationColor()
                if let isService = (feature.properties?["isService"] as? JSONValue)?.rawValue as? Bool, isService {
                    let service = self?.servicesList.filter {
                        $0.biz_data?.name == feature.identifier?.rawValue as? String
                    }.first
                    if let service = service {
                        let lat = service.biz_data?.lat ?? Constants.defaultLocation.coordinate.latitude
                        let lng = service.biz_data?.lng ?? Constants.defaultLocation.coordinate.longitude
                        self?.addOrangeServicePoint(at: CLLocationCoordinate2D(latitude: lat, longitude: lng))
                        self?.showServicePointCard(feature: feature)
                    }
                } else {
                    let package = self?.packagesList.filter {
                        $0.tracking_no == feature.identifier?.rawValue as? String
                    }.first
                    if let package = package {
                        let lat = Double(package.lat ?? "") ?? Constants.defaultLocation.coordinate.latitude
                        let lng = Double(package.lng ?? "") ?? Constants.defaultLocation.coordinate.longitude
                        self?.addOrangePin(at: CLLocationCoordinate2D(latitude: lat, longitude: lng))
                        self?.showPackageCard(feature: feature)
                    }
                }
            }
        }
    }
    
    private func showPackageCard(feature: Feature) {
        
        guard let trackingNo = feature.identifier?.rawValue as? String else {
            return
        }
        let packToShow = self.packagesList.filter {
            $0.tracking_no == trackingNo
        }.first
        self.packageToShowDetail = packToShow
        guard let packToShow = packToShow else {
            return
        }
        let location = (self.currentLocation.coordinate.latitude,
                        self.currentLocation.coordinate.longitude)
        let viewModel = MapPackageCardViewModel(
            packageViewModel: packToShow,
            location: location,
            buttonTitle: String.parcelDetailsStr
        )
        self.cardView.buttonAction = {
            self.cardViewTopConstraint?.constant = 0
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.cardView.layoutIfNeeded()
            }) { _ in
                self.showDetailPackageCard()
            }
        }
        self.cardView.configure(viewModel: viewModel)
        
        self.cardViewTopConstraint?.constant = -self.cardView.bounds.height
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.cardView.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func showServicePointCard(feature: Feature) {
        
        guard let name = feature.identifier?.rawValue as? String else {
            return
        }
        let serviceToShow = self.servicesList.filter {
            $0.biz_data?.name == name
        }.first
        guard let serviceToShow = serviceToShow else {
            return
        }
        let location = (self.currentLocation.coordinate.latitude,
                        self.currentLocation.coordinate.longitude)
        let viewModel = MapPackageCardViewModel(
            serviceViewModel: serviceToShow,
            location: location,
            buttonTitle: String.navigateToServicePointStr
        )
        self.cardView.configure(viewModel: viewModel)
        
        self.cardViewTopConstraint?.constant = -self.cardView.bounds.height
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.cardView.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc
    private func showDetailPackageCard() {
        
        guard let packageToShow = self.packageToShowDetail else {
            return
        }
        let location = (self.currentLocation.coordinate.latitude,
                        self.currentLocation.coordinate.longitude)
        let viewModel = MapPackageDetailCardViewModel(
            packageViewModel: packageToShow,
            location: location,
            failedButtonTitle: String.failedStr,
            deliveredButtonTitle: String.deliveredStr
        )
        self.detailCardView.chooseAddressTypeAction = {
            self.showAddressTypePickup()
        }
        self.detailCardView.navigationAction = {
            self.showNavigationPickup()
        }
        self.detailCardView.phoneMsgAction = {
            
        }
        
        self.detailCardView.configure(viewModel: viewModel)
        
        self.detailCardViewTopConstraint?.constant = -self.detailCardView.bounds.height
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.detailCardView.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func showAddressTypePickup() {
        
        let alert = UIAlertController(title: String.markAddressTypeStr, message: String.pleaseChooseAddressTypeStr, preferredStyle: .actionSheet)
        
        let houseAct = UIAlertAction(title: String.houseStr, style: .default) { _ in
            self.detailCardView.updateAddressType(addressType: .house)
            self.packageToShowDetail?.address_type = .house
            self.packagesListViewModel.updatePackage(pack: self.packageToShowDetail)
            
        }
        let townhouseAct = UIAlertAction(title: String.townhouseStr, style: .default) { _ in
            self.detailCardView.updateAddressType(addressType: .townhouse)
            self.packageToShowDetail?.address_type = .townhouse
            self.packagesListViewModel.updatePackage(pack: self.packageToShowDetail)
        }
        let businessAct = UIAlertAction(title: String.businessStr, style: .default) { _ in
            self.detailCardView.updateAddressType(addressType: .business)
            self.packageToShowDetail?.address_type = .business
            self.packagesListViewModel.updatePackage(pack: self.packageToShowDetail)
        }
        let apartmentAct = UIAlertAction(title: String.apartmentStr, style: .default) { _ in
            self.detailCardView.updateAddressType(addressType: .apartment)
            self.packageToShowDetail?.address_type = .apartment
            self.packagesListViewModel.updatePackage(pack: self.packageToShowDetail)
        }
        
        alert.addAction(houseAct)
        alert.addAction(townhouseAct)
        alert.addAction(businessAct)
        alert.addAction(apartmentAct)
        
        let cancelAct = UIAlertAction(title: String.cancelStr, style: .cancel) { (UIAlertAction) in
            print("cheng= cancel")
        }
        
        alert.addAction(cancelAct)
        
        // for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showNavigationPickup() {
        
        let alert = UIAlertController(title: String.chooseMapStr, message: String.chooseAnApplicationToStartNavigationStr, preferredStyle: .actionSheet)
        
        let appleMapAct = UIAlertAction(title: String.appleMapStr, style: .default) { _ in
            guard let lat = self.packageToShowDetail?.lat, let lng = self.packageToShowDetail?.lng else {
                return
            }
            guard let url = URL(string: String(format: "http://maps.apple.com/?daddr=%f,%f&dirflg=d", lat, lng)) else {
                return
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        let googleMapAct = UIAlertAction(title: String.googleMapStr, style: .default) { _ in
            guard let baseUrl = URL(string:"comgooglemaps://") else {
                return
            }
            guard let lat = self.packageToShowDetail?.lat, let lng = self.packageToShowDetail?.lng else {
                return
            }
            guard let url = URL(string: String(format: "comgooglemaps-x-callback://?saddr=&daddr=%f,%f&directionsmode=driving", lat, lng)) else {
                return
            }
            if UIApplication.shared.canOpenURL(baseUrl) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                NSLog("Can't use comgooglemaps://");
            }
        }
        let inAppMapAct = UIAlertAction(title: String.inAppMapStr, style: .default) { (UIAlertAction) in
            self.openMapboxNavigation()
        }
        let copyAddAct = UIAlertAction(title: String.copyAddressStr, style: .default) { (UIAlertAction) in
            print("cheng= copy")
        }
        
        alert.addAction(appleMapAct)
        alert.addAction(googleMapAct)
        alert.addAction(inAppMapAct)
        alert.addAction(copyAddAct)
        
        let cancelAct = UIAlertAction(title: String.cancelStr, style: .cancel) { (UIAlertAction) in
            print("cheng= cancel")
        }
        
        alert.addAction(cancelAct)
        
        // for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func openMapboxNavigation() {
        
        guard let lat = Double(self.packageToShowDetail?.lat ?? ""), let lng = Double(self.packageToShowDetail?.lng ?? "") else {
            return
        }
        
        let origin = self.currentLocation.coordinate
        //CLLocationCoordinate2DMake(37.77440680146262, -122.43539772352648)
        let destination = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        let options = NavigationRouteOptions(coordinates: [origin, destination])
        
        Directions.shared.calculate(options) { [weak self] (_, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let strongSelf = self else {
                    return
                }
                
                // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
                // Since first route is retrieved from response `routeIndex` is set to 0.
                //let navigationService = MapboxNavigationService(routeResponse: response, routeIndex: 0, routeOptions: options, simulating: .always)
                
                let credentials = Credentials()
                let navigationService = MapboxNavigationService(
                    routeResponse: response,
                    routeIndex: 0,
                    routeOptions: options,
                    credentials: credentials
                )
                
                let navigationOptions = NavigationOptions(navigationService: navigationService)
                let navigationViewController = NavigationViewController(for: response, routeIndex: 0, routeOptions: options, navigationOptions: navigationOptions)
                navigationViewController.modalPresentationStyle = .fullScreen
                // Render part of the route that has been traversed with full transparency, to give the illusion of a disappearing route.
                navigationViewController.routeLineTracksTraversal = true
                
                strongSelf.present(navigationViewController, animated: true, completion: nil)
            }
        }
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
        do {
            try mapView.viewAnnotations.add(self.orangePin, options: options)
        } catch {
            print("Failed to add viewAnnotation: \(error.localizedDescription)")
        }
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
        do {
            try mapView.viewAnnotations.add(self.orangeServicePoint, options: options)
        } catch {
            print("Failed to add viewAnnotation: \(error.localizedDescription)")
        }
    }
    
    private func restoreViewAnnotationColor() {
        mapView.viewAnnotations.remove(self.orangePin)
        mapView.viewAnnotations.remove(self.orangeServicePoint)
    }
    
    private func observingViewModels() {
        Publishers.CombineLatest(self.packagesListViewModel.$list, self.servicesListViewModel.$list)
            .sink(receiveValue: { [weak self] (packList, serviceList) in
                guard let strongSelf = self else { return }
                strongSelf.packagesList = packList
                strongSelf.servicesList = serviceList
                
                strongSelf.findPackageRegion(packagesList: packList, servicesList: serviceList)
                strongSelf.updateDataSource(packagesList: packList, servicesList: serviceList)
            })
            .store(in: &disposables)
    }
    
    private func findPackageRegion(packagesList: [PackageViewModel], servicesList: [ServicePointViewModel]) {
        
        let latsPack: [Double] = packagesList.compactMap { pack -> Double? in
            Double(pack.lat ?? "")
        }
        let lngsPack: [Double] = packagesList.compactMap { pack -> Double? in
            Double(pack.lng ?? "")
        }
        let latsService: [Double] = servicesList.compactMap { service -> Double? in
            service.biz_data?.lat
        }
        let lngsService: [Double] = servicesList.compactMap { service -> Double? in
            service.biz_data?.lng
        }
        let lats = latsPack + latsService
        let lngs = lngsPack + lngsService
        
        guard lats.count > 0 else {
            return
        }
        
        let defaultLocation = Location(with: Constants.defaultLocation)
        let loc = self.mapView.location.latestLocation ?? defaultLocation
        
        var latMin = lats.min() ?? loc.coordinate.latitude
        var latMax = lats.max() ?? loc.coordinate.latitude
        
        if latMin == latMax {
            latMin -= 0.05
            latMax += 0.05
        }
        
        var lngMin = lngs.min() ?? loc.coordinate.longitude
        var lngMax = lngs.max() ?? loc.coordinate.longitude
        
        if lngMin == lngMax {
            lngMin -= 0.05
            lngMax += 0.05
        }
        
        updateCameraBound(latRegion: (latMin, latMax), lngRegion: (lngMin, lngMax))
    }
    
    private func updateCameraBound(latRegion: (min: Double, max: Double), lngRegion: (min: Double, max: Double)) {
        
        let coordinates = [
            CLLocationCoordinate2DMake(latRegion.min, lngRegion.min),
            CLLocationCoordinate2DMake(latRegion.min, lngRegion.max),
            CLLocationCoordinate2DMake(latRegion.max, lngRegion.min),
            CLLocationCoordinate2DMake(latRegion.max, lngRegion.max)
        ]
        let padding = UIEdgeInsets(
            top: Constants.mapZonePadding,
            left: Constants.mapZonePadding,
            bottom: Constants.mapZonePadding,
            right: Constants.mapZonePadding
        )
        let camera = mapView.mapboxMap.camera(
            for: coordinates,
            padding: padding,
            bearing: nil,
            pitch: nil
        )
        mapView.camera.ease(to: camera, duration: Constants.mapZoneUpdateDuration)
    }
    
    private func updateDataSource(packagesList: [PackageViewModel], servicesList: [ServicePointViewModel]) {
        
        let packGeoJsonObject = GeoJsonDataModel.map(packagesList: packagesList)
        do {
            try self.mapView.mapboxMap.style.updateGeoJSONSource(withId: Constants.packagesSourceID, geoJSON: packGeoJsonObject)
        } catch {
            print("Failed to update the layer: \(error.localizedDescription)")
        }
        
        let serviceGeoJsonObject = GeoJsonDataModel.map(servicesList: servicesList)
        do {
            try self.mapView.mapboxMap.style.updateGeoJSONSource(withId: Constants.servicesSourceID, geoJSON: serviceGeoJsonObject)
        } catch {
            print("Failed to update the layer: \(error.localizedDescription)")
        }
    }
    
    private func setupCluster() {
        
        let style = self.mapView.mapboxMap.style
        
        self.addIconSource()
        
        // Create a GeoJSONSource
        var packageSource = GeoJSONSource()
        packageSource.data = .empty
        // Set the clustering properties directly on the source.
        packageSource.cluster = true
        packageSource.clusterRadius = 50
        // The maximum zoom level where points will be clustered.
        packageSource.clusterMaxZoom = 14
        
        var serviceSource = GeoJSONSource()
        serviceSource.data = .empty
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
        do {
            try style.addSource(packageSource, id: Constants.packagesSourceID)
            try style.addSource(serviceSource, id: Constants.servicesSourceID)
            try style.addLayer(clusteredLayer)
            try style.addLayer(unclusteredLayer, layerPosition: .below(clusteredLayer.id))
            try style.addLayer(clusterCountLayer)
            try style.addLayer(servicesLayer)
        } catch {
            print("Failed to add sources and layers: \(error.localizedDescription)")
        }
    }
    
    private func addIconSource() {
        
        let mapStyle = self.mapView.mapboxMap.style
        
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
        unclusteredLayer.textField = .expression(Exp(.get) { "routeNo" })
        unclusteredLayer.textSize = .constant(9)
        unclusteredLayer.textColor = .constant(StyleColor(.white))
        unclusteredLayer.textOffset = .constant([0.0, -0.5])
        
        return unclusteredLayer
    }
    
    private func createServicePointsLayer() -> SymbolLayer {
        
        var servicesLayer = SymbolLayer(id: Constants.servicePointsLayerID)
        servicesLayer.iconImage = .constant(.name(Constants.serviceBlackIcon))
        
        return servicesLayer
    }
}

extension MapClusterViewController: LocationPermissionsDelegate, LocationConsumer {
    
    func locationUpdate(newLocation: Location) {
        self.currentLocation = newLocation.location
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
    
    private func setupDetailCardView() {
        
        self.view.addSubview(detailCardView)
        
        self.detailCardViewTopConstraint = detailCardView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        guard let topDetailConstraint = self.detailCardViewTopConstraint else {
            return
        }
        NSLayoutConstraint.activate([
            detailCardView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            topDetailConstraint,
            detailCardView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)]
        )
    }
}