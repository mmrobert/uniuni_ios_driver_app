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
        view.layoutIfNeeded()
        return view
    }()
    
    private var cardViewTopConstraint: NSLayoutConstraint?
    private var detailCardViewTopConstraint: NSLayoutConstraint?
    
    @Published var packageToShowDetail: PackageViewModel?
    var serviceToShowDetail: ServicePointViewModel?
    var mapViewModel: MapViewModel?
    
    private var languagesList: [LanguageDataModel] = []
    private var msgTemplatesList: [MessageTemplateDataModel] = []
    
    private var templateID: Int?
    
    init(packagesListViewModel: PackagesListViewModel,
         servicesListViewModel: ServicePointsListViewModel,
         mapViewModel: MapViewModel)
    {
        self.packagesListViewModel = packagesListViewModel
        self.servicesListViewModel = servicesListViewModel
        self.mapViewModel = mapViewModel
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
        self.setupBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.detailCardViewTopConstraint?.constant = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showDetailPackageCard()
    }
    
    private func setupBackButton() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        let backButton = UIBarButtonItem(image: UIImage.iconBack, style: .plain, target: self, action: #selector(MapClusterViewController.backButtonAction))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc
    private func backButtonAction() {
        if let const = self.detailCardViewTopConstraint?.constant, const < -8 {
            self.detailCardViewTopConstraint?.constant = 0
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.detailCardView.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func setupMapView() {
        
        self.view.backgroundColor = .white
        mapView = MapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            mapView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        mapView.mapboxMap.onNext(event: .styleLoaded) { [weak self] _ in
            self?.setupCluster()
        }
        mapView.mapboxMap.onNext(event: .mapLoaded) { [weak self] _ in
            self?.setupInitZoom()
            self?.setupSingleTapAction()
            // fetch packages
            self?.observingViewModels()
            self?.observingError()
            self?.packagesListViewModel.fetchPackagesFromCoreData()
            self?.servicesListViewModel.fetchServicesFromAPI(driverID: AppConfigurator.shared.driverID)
            //self?.servicesListViewModel.fetchServicePointsFromCoreData()
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
        let config = Puck2DConfiguration.makeDefault(showBearing: true)
        mapView.location.options.puckType = .puck2D(config)
        mapView.location.addLocationConsumer(newConsumer: self)
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
            with: rect,
            options: queryOptions
        ) { [weak solidView, weak self] tappedQueryResult in
            guard let feature = try? tappedQueryResult.get().first?.feature else {
                self?.hidePackageCard()
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
                        let pack = packFeature?.sorted(by: { (lh, rh) -> Bool in
                            let lhRouteNo = (lh.properties?["routeNo"] as? JSONValue)?.rawValue as? String
                            let rhRouteNo = (rh.properties?["routeNo"] as? JSONValue)?.rawValue as? String
                            if let lhRouteNo = Int(lhRouteNo ?? ""), let rhRouteNo = Int(rhRouteNo ?? "") {
                                return lhRouteNo < rhRouteNo
                            } else {
                                return false
                            }
                        }).first
                        if let pack = pack {
                            self?.showPackageCard(feature: pack)
                        }
                    case .failure(let error):
                        print("No deep cluster \(error.localizedDescription)")
                    }
                }
            } else {
                self?.restoreViewAnnotationColor()
                
                if let isService = (feature.properties?["isService"] as? JSONValue)?.rawValue as? Bool, isService {
                    let service = self?.servicesList.filter {
                        $0.name == feature.identifier?.rawValue as? String
                    }.first
                    if let service = service {
                        let lat = service.lat ?? Constants.defaultLocation.coordinate.latitude
                        let lng = service.lng ?? Constants.defaultLocation.coordinate.longitude
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
        self.cardView.buttonAction = { [weak self] in
            self?.cardViewTopConstraint?.constant = 0
            UIView.animate(withDuration: 0.5, animations: {
                self?.cardView.layoutIfNeeded()
            }) { _ in
                self?.packageToShowDetail = packToShow
                self?.showDetailPackageCard()
            }
        }
        self.cardView.configure(viewModel: viewModel)
        
        self.cardViewTopConstraint?.constant = -self.cardView.bounds.height
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.cardView.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func hidePackageCard() {
        
        self.restoreViewAnnotationColor()
        self.cardViewTopConstraint?.constant = 0
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.cardView.layoutIfNeeded()
        }) { _ in }
    }
    
    private func showServicePointCard(feature: Feature) {
        
        guard let name = feature.identifier?.rawValue as? String else {
            return
        }
        let serviceToShow = self.servicesList.filter {
            $0.name == name
        }.first
        self.serviceToShowDetail = serviceToShow
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
        self.cardView.buttonAction = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let locationLat = strongSelf.currentLocation.coordinate.latitude
            let locationLng = strongSelf.currentLocation.coordinate.longitude
            let lat = strongSelf.serviceToShowDetail?.lat ?? locationLat
            let lng = strongSelf.serviceToShowDetail?.lng ?? locationLng
            strongSelf.navigationAction(lat: lat, lng: lng)
        }
        self.cardView.configure(viewModel: viewModel)
        
        self.cardViewTopConstraint?.constant = -self.cardView.bounds.height
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.cardView.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc
    private func showDetailPackageCard() {
        
        guard var packageToShow = self.packageToShowDetail else {
            return
        }
        let location = (self.currentLocation.coordinate.latitude,
                        self.currentLocation.coordinate.longitude)
        let orderId = packageToShow.order_id ?? 0
        if let needRetry = self.packageToShowDetail?.need_retry, needRetry > 0 {
            self.mapViewModel?.reDeliveryHistory(driverID: AppConfigurator.shared.driverID, orderID: orderId) { [weak self] retryData in
                guard let strongSelf = self else { return }
                strongSelf.packageToShowDetail?.redeliveryData = retryData
                packageToShow.redeliveryData = retryData
                let viewModel = MapPackageDetailCardViewModel(
                    packageViewModel: packageToShow,
                    location: location,
                    failedButtonTitle: String.failedStr,
                    deliveredButtonTitle: String.deliveredStr
                )
                strongSelf.detailCardView.configure(viewModel: viewModel)
            }
        } else {
            let viewModel = MapPackageDetailCardViewModel(
                packageViewModel: packageToShow,
                location: location,
                failedButtonTitle: String.failedStr,
                deliveredButtonTitle: String.deliveredStr
            )
            self.detailCardView.configure(viewModel: viewModel)
        }
        self.updateDataSource(packagesList: [packageToShow], servicesList: [])
        self.detailCardView.chooseAddressTypeAction = { [weak self] in
            self?.showAddressTypePickup()
        }
        self.detailCardView.navigationAction = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let locationLat = strongSelf.currentLocation.coordinate.latitude
            let locationLng = strongSelf.currentLocation.coordinate.longitude
            let lat = Double(strongSelf.packageToShowDetail?.lat ?? "") ?? locationLat
            let lng = Double(strongSelf.packageToShowDetail?.lng ?? "") ?? locationLng
            strongSelf.navigationAction(lat: lat, lng: lng)
        }
        self.detailCardView.longPressAddressAction = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let locationLat = strongSelf.currentLocation.coordinate.latitude
            let locationLng = strongSelf.currentLocation.coordinate.longitude
            let lat = Double(strongSelf.packageToShowDetail?.lat ?? "") ?? locationLat
            let lng = Double(strongSelf.packageToShowDetail?.lng ?? "") ?? locationLng
            strongSelf.showNavigationPickup(lat: lat, lng: lng)
        }
        self.detailCardView.phoneMsgAction = { [weak self] in
            self?.showCallTextPickup()
        }
        
        self.detailCardView.deliveredAction = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            guard let vm = strongSelf.packageToShowDetail else {
                return
            }
            strongSelf.detailCardViewTopConstraint?.constant = 25
            UIView.animate(withDuration: 0.5, animations: {
                strongSelf.detailCardView.layoutIfNeeded()
            }) { _ in
                strongSelf.updateDataSource(packagesList: strongSelf.packagesList, servicesList: strongSelf.servicesList)
                let completeNavi = CompleteDeliveryNavigator(presenter: strongSelf, packageViewModel: vm)
                completeNavi.presentDeliveryDetail()
            }
        }
        
        self.detailCardView.failedAction = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            if let needRetry = strongSelf.packageToShowDetail?.need_retry, needRetry > 0 {
                if let retryTime = strongSelf.packageToShowDetail?.redeliveryData?.retry_times {
                    if retryTime == 0 {
                        strongSelf.mapViewModel?.reDeliveryHistory(driverID: AppConfigurator.shared.driverID, orderID: orderId) { retryData in
                            if let remain = retryData?.remaining_time, remain > 0 {
                                let positiveAction = Action(title: String.OKStr)
                                strongSelf.showAlert(title: String.attemptFailedStr, msg: String.yourTwoAttemptsAreTooCloseStr, positiveAction: positiveAction, negativeAction: nil)
                            } else {
                                strongSelf.showReasonOfFailPickup(failedChoose: .firstDelivery)
                            }
                        }
                    } else if retryTime == 1 {
                        strongSelf.mapViewModel?.reDeliveryHistory(driverID: AppConfigurator.shared.driverID, orderID: orderId) { retryData in
                            if let remain = retryData?.remaining_time, remain > 0 {
                                let positiveAction = Action(title: String.OKStr)
                                strongSelf.showAlert(title: String.attemptFailedStr, msg: String.yourTwoAttemptsAreTooCloseStr, positiveAction: positiveAction, negativeAction: nil)
                            } else {
                                strongSelf.showReasonOfFailPickup(failedChoose: .secondDelivery)
                            }
                        }
                    } else {
                        strongSelf.showReasonOfFailPickup(failedChoose: .thirdDelivery)
                    }
                } else {
                    strongSelf.showReasonOfFailPickup(failedChoose: .noRedelivery)
                }
            } else {
                strongSelf.showReasonOfFailPickup(failedChoose: .noRedelivery)
            }
        }
        
        self.zoomToDetailPackageLocation() {
            
            self.detailCardView.sizeToFit()
            self.detailCardViewTopConstraint?.constant = -self.detailCardView.bounds.height
            
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.detailCardView.layoutIfNeeded()
            }) { _ in }
        }
    }
    
    private func showAddressTypePickup() {
        
        let alert = UIAlertController(title: String.markAddressTypeStr, message: String.pleaseChooseAddressTypeStr, preferredStyle: .actionSheet)
        
        let houseAct = UIAlertAction(title: String.houseStr, style: .default) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.detailCardView.updateAddressType(addressType: .house)
            strongSelf.packageToShowDetail?.address_type = .house
            strongSelf.packagesListViewModel.updatePackageForCoreData(pack: strongSelf.packageToShowDetail)
            strongSelf.mapViewModel?.updateAddressTypeFromAPI(driverID: AppConfigurator.shared.driverID, orderSN: strongSelf.packageToShowDetail?.order_sn ?? "", addressType: AddressType.house.rawValue)
        }
        let townhouseAct = UIAlertAction(title: String.townhouseStr, style: .default) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.detailCardView.updateAddressType(addressType: .townhouse)
            strongSelf.packageToShowDetail?.address_type = .townhouse
            strongSelf.packagesListViewModel.updatePackageForCoreData(pack: strongSelf.packageToShowDetail)
            strongSelf.mapViewModel?.updateAddressTypeFromAPI(driverID: AppConfigurator.shared.driverID, orderSN: strongSelf.packageToShowDetail?.order_sn ?? "", addressType: AddressType.townhouse.rawValue)
        }
        let businessAct = UIAlertAction(title: String.businessStr, style: .default) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.detailCardView.updateAddressType(addressType: .business)
            strongSelf.packageToShowDetail?.address_type = .business
            strongSelf.packagesListViewModel.updatePackageForCoreData(pack: strongSelf.packageToShowDetail)
            strongSelf.mapViewModel?.updateAddressTypeFromAPI(driverID: AppConfigurator.shared.driverID, orderSN: strongSelf.packageToShowDetail?.order_sn ?? "", addressType: AddressType.business.rawValue)
        }
        let apartmentAct = UIAlertAction(title: String.apartmentStr, style: .default) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.detailCardView.updateAddressType(addressType: .apartment)
            strongSelf.packageToShowDetail?.address_type = .apartment
            strongSelf.packagesListViewModel.updatePackageForCoreData(pack: strongSelf.packageToShowDetail)
            strongSelf.mapViewModel?.updateAddressTypeFromAPI(driverID: AppConfigurator.shared.driverID, orderSN: strongSelf.packageToShowDetail?.order_sn ?? "", addressType: AddressType.apartment.rawValue)
        }
        
        alert.addAction(houseAct)
        alert.addAction(townhouseAct)
        alert.addAction(businessAct)
        alert.addAction(apartmentAct)
        
        let cancelAct = UIAlertAction(title: String.cancelStr, style: .cancel)
        
        alert.addAction(cancelAct)
        
        // for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func navigationAction(lat: Double, lng: Double) {
        
        let mapDefaultInt = UserDefaults.standard.object(forKey: AppConstants.userDefaultsKey_map) as? Int
        if let mapDefault = AddressNavigationType.getTypeFrom(value: mapDefaultInt) {
            switch mapDefault {
            case .appleMap:
                self.openAppleNavigation(lat: lat, lng: lng)
            case .googleMap:
                self.openGoogleNavigation(lat: lat, lng: lng)
            case .inAppMap:
                self.openMapboxNavigation(lat: lat, lng: lng)
            case .copyAddress:
                break
            }
            return
        }
        
        self.showNavigationPickup(lat: lat, lng: lng)
    }
    
    private func showNavigationPickup(lat: Double, lng: Double) {
        
        let alert = UIAlertController(title: String.chooseMapStr, message: String.chooseAnApplicationToStartNavigationStr, preferredStyle: .actionSheet)
        
        let appleMapAct = UIAlertAction(title: String.appleMapStr, style: .default) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            let positiveAction = Action(title: String.yesStr) { _ in
                UserDefaults.standard.set(AddressNavigationType.appleMap.rawValue, forKey: AppConstants.userDefaultsKey_map)
                strongSelf.openAppleNavigation(lat: lat, lng: lng)
            }
            let negativeAction = Action(title: String.noStr) { _ in
                strongSelf.openAppleNavigation(lat: lat, lng: lng)
            }
            strongSelf.showAlert(
                title: String.setDefaultMapStr,
                msg: String(format: String.doYouWantToSetDefaultMapStr, String.appleMapStr),
                positiveAction: positiveAction,
                negativeAction: negativeAction
            )
        }
        let googleMapAct = UIAlertAction(title: String.googleMapStr, style: .default) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            let positiveAction = Action(title: String.yesStr) { _ in
                UserDefaults.standard.set(AddressNavigationType.googleMap.rawValue, forKey: AppConstants.userDefaultsKey_map)
                strongSelf.openGoogleNavigation(lat: lat, lng: lng)
            }
            let negativeAction = Action(title: String.noStr) { _ in
                strongSelf.openGoogleNavigation(lat: lat, lng: lng)
            }
            strongSelf.showAlert(
                title: String.setDefaultMapStr,
                msg: String(format: String.doYouWantToSetDefaultMapStr, String.googleMapStr),
                positiveAction: positiveAction,
                negativeAction: negativeAction
            )
        }
        let inAppMapAct = UIAlertAction(title: String.inAppMapStr, style: .default) { [weak self] (UIAlertAction) in
            guard let strongSelf = self else {
                return
            }
            let positiveAction = Action(title: String.yesStr) { _ in
                UserDefaults.standard.set(AddressNavigationType.inAppMap.rawValue, forKey: AppConstants.userDefaultsKey_map)
                strongSelf.openMapboxNavigation(lat: lat, lng: lng)
            }
            let negativeAction = Action(title: String.noStr) { _ in
                strongSelf.openMapboxNavigation(lat: lat, lng: lng)
            }
            strongSelf.showAlert(
                title: String.setDefaultMapStr,
                msg: String(format: String.doYouWantToSetDefaultMapStr, String.inAppMapStr),
                positiveAction: positiveAction,
                negativeAction: negativeAction
            )
        }
        let copyAddAct = UIAlertAction(title: String.copyAddressStr, style: .default) { [weak self] (UIAlertAction) in
            let pasteboard = UIPasteboard.general
            pasteboard.string = self?.packageToShowDetail?.address
        }
        
        alert.addAction(appleMapAct)
        alert.addAction(googleMapAct)
        alert.addAction(inAppMapAct)
        alert.addAction(copyAddAct)
        
        let cancelAct = UIAlertAction(title: String.cancelStr, style: .cancel)
        
        alert.addAction(cancelAct)
        
        // for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func openAppleNavigation(lat: Double, lng: Double) {
        
        guard let url = URL(string: String(format: "http://maps.apple.com/?daddr=%f,%f&dirflg=d", lat, lng)) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func openGoogleNavigation(lat: Double, lng: Double) {
        guard let baseUrl = URL(string:"comgooglemaps://") else {
            return
        }
        guard let url = URL(string: String(format: "comgooglemaps-x-callback://?saddr=&daddr=%f,%f&directionsmode=driving", lat, lng)) else {
            return
        }
        if UIApplication.shared.canOpenURL(baseUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UserDefaults.standard.removeObject(forKey: AppConstants.userDefaultsKey_map)
            let positiveAction = Action(title: String.OKStr)
            self.showAlert(title: nil, msg: String.googleMapIsNotInstalledStr, positiveAction: positiveAction, negativeAction: nil)
        }
    }
    
    private func openMapboxNavigation(lat: Double, lng: Double) {
        
        let origin = self.currentLocation.coordinate
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
                // Render part of the route that has been traversed with full
                // transparency, to give the illusion of a disappearing route.
                navigationViewController.routeLineTracksTraversal = true
                
                strongSelf.present(navigationViewController, animated: true, completion: nil)
            }
        }
    }
    
    private func showCallTextPickup() {
        
        let alert = UIAlertController(title: String.phoneNumberStr, message: self.packageToShowDetail?.mobile, preferredStyle: .actionSheet)
        
        let callAct = UIAlertAction(title: String.callStr, style: .default) { [weak self] _ in
            self?.callPhoneNumber()
        }
        let textAct = UIAlertAction(title: String.textStr, style: .default) { [weak self] _ in
            self?.msgLanguagePickup()
        }
        
        alert.addAction(callAct)
        alert.addAction(textAct)
        
        let cancelAct = UIAlertAction(title: String.cancelStr, style: .cancel)
        
        alert.addAction(cancelAct)
        
        // for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func callPhoneNumber() {
        guard let phone = self.packageToShowDetail?.mobile else {
            return
        }
        guard let url = URL(string: "telprompt://\(phone)"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func msgLanguagePickup() {
        
        guard self.languagesList.count > 0 else {
            return
        }
        
        guard let warehouseID = self.packageToShowDetail?.warehouse_id else {
            return
        }
        
        let alert = UIAlertController(title: String.textLanguageStr, message: String.chooseALanguageStr, preferredStyle: .actionSheet)
        
        for language in self.languagesList {
            let act = UIAlertAction(title: language.name, style: .default) { [weak self] _ in
                self?.fetchMsgTemplatesList(warehouseID: warehouseID, language: language.code)
            }
            alert.addAction(act)
        }
        
        let cancelAct = UIAlertAction(title: String.cancelStr, style: .cancel)
        
        alert.addAction(cancelAct)
        
        // for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func fetchMsgTemplatesList(warehouseID: Int, language: String?) {
        guard let language = language, !language.isEmpty else {
            return
        }
        self.mapViewModel?.fetchMsgTemplatesListFromAPI(warehouseID: warehouseID, language: language)
    }
    
    private func sendMsgPickup() {
        guard self.msgTemplatesList.count > 0 else {
            return
        }
        
        let alert = UIAlertController(title: String.textTemplateStr, message: String.chooseATemplateYouWantToUseStr, preferredStyle: .actionSheet)
        
        for template in self.msgTemplatesList {
            let act = UIAlertAction(title: template.title, style: .default) { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                guard let orderID = strongSelf.packageToShowDetail?.order_id, let templateID = template.id else {
                    return
                }
                strongSelf.templateID = templateID
                strongSelf.mapViewModel?.sendMsgFromAPI(orderID: orderID, templateID: templateID)
            }
            alert.addAction(act)
        }
        
        let cancelAct = UIAlertAction(title: String.cancelStr, style: .cancel)
        
        alert.addAction(cancelAct)
        
        // for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showReasonOfFailPickup(failedChoose: FailedChoose) {
        
        let alert = UIAlertController(title: String.reasonOfFailStr, message: String.chooseAReasonOfFailingDeliveryStr, preferredStyle: .actionSheet)
        
        let redeliveryAct = UIAlertAction(title: String.redeliveryStr, style: .default) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            guard let vm = strongSelf.packageToShowDetail else {
                return
            }
            
            strongSelf.detailCardViewTopConstraint?.constant = 20
            UIView.animate(withDuration: 0.5, animations: {
                strongSelf.detailCardView.layoutIfNeeded()
            }) { _ in
                strongSelf.updateDataSource(packagesList: strongSelf.packagesList, servicesList: strongSelf.servicesList)
                let failedNavi = FailedDeliveryNavigator(presenter: strongSelf, packageViewModel: vm, failedReason: .redelivery, currentLocation: self?.currentLocation)
                failedNavi.presentFailedDetail()
            }
        }
        let contactAct = UIAlertAction(title: String.failToContactCustomerStr, style: .default) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            guard let vm = strongSelf.packageToShowDetail else {
                return
            }
            strongSelf.detailCardViewTopConstraint?.constant = 20
            UIView.animate(withDuration: 0.5, animations: {
                strongSelf.detailCardView.layoutIfNeeded()
            }) { _ in
                strongSelf.updateDataSource(packagesList: strongSelf.packagesList, servicesList: strongSelf.servicesList)
                let failedNavi = FailedDeliveryNavigator(presenter: strongSelf, packageViewModel: vm, failedReason: .failedContactCustomer)
                failedNavi.presentFailedDetail()
            }
        }
        let wrongAddAct = UIAlertAction(title: String.wrongAddressStr, style: .default) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            guard let vm = strongSelf.packageToShowDetail else {
                return
            }
            strongSelf.detailCardViewTopConstraint?.constant = 20
            UIView.animate(withDuration: 0.5, animations: {
                strongSelf.detailCardView.layoutIfNeeded()
            }) { _ in
                strongSelf.updateDataSource(packagesList: strongSelf.packagesList, servicesList: strongSelf.servicesList)
                let failedNavi = FailedDeliveryNavigator(presenter: strongSelf, packageViewModel: vm, failedReason: .wrongAddress)
                failedNavi.presentFailedDetail()
            }
        }
        let poboxAct = UIAlertAction(title: String.POBoxStr, style: .default) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            guard let vm = strongSelf.packageToShowDetail else {
                return
            }
            strongSelf.detailCardViewTopConstraint?.constant = 20
            UIView.animate(withDuration: 0.5, animations: {
                strongSelf.detailCardView.layoutIfNeeded()
            }) { _ in
                strongSelf.updateDataSource(packagesList: strongSelf.packagesList, servicesList: strongSelf.servicesList)
                let failedNavi = FailedDeliveryNavigator(presenter: strongSelf, packageViewModel: vm, failedReason: .poBox)
                failedNavi.presentFailedDetail()
            }
        }
        switch failedChoose {
        case .noRedelivery:
            alert.addAction(contactAct)
            alert.addAction(wrongAddAct)
            alert.addAction(poboxAct)
        case .firstDelivery:
            alert.addAction(redeliveryAct)
            alert.addAction(wrongAddAct)
            alert.addAction(poboxAct)
        case .secondDelivery:
            alert.addAction(redeliveryAct)
        case .thirdDelivery:
            alert.addAction(contactAct)
        }
        
        let cancelAct = UIAlertAction(title: String.cancelStr, style: .cancel)
        alert.addAction(cancelAct)
        
        // for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func zoomToDetailPackageLocation(completion: (() -> ())? = nil) {
        guard let lat = Double(self.packageToShowDetail?.lat ?? ""), let lng = Double(self.packageToShowDetail?.lng ?? "") else {
            return
        }
        let latRegion = (lat - 0.03, lat + 0.01)
        let lngRegion = (lng - 0.01, lng + 0.01)
        self.updateCameraBound(latRegion: latRegion, lngRegion: lngRegion) {
            completion?()
        }
    }
    
    private func showAlert(title: String?, msg: String?, positiveAction: Action?, negativeAction: Action?) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)

        if positiveAction != nil {
            let positiveHandler: (UIAlertAction) -> Void = { alertAction in
                positiveAction?.handler?(alertAction.title)
            }
            alert.addAction(UIAlertAction(title: positiveAction?.title, style: .default, handler: positiveHandler))
        }
        
        if negativeAction != nil {
            let negativeHandler: (UIAlertAction) -> Void = { alertAction in
                negativeAction?.handler?(alertAction.title)
            }
            alert.addAction(UIAlertAction(title: negativeAction?.title, style: .cancel, handler: negativeHandler))
        }
        
        self.present(alert, animated: true, completion: nil)
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
                
                let packs = packList.filter { pack in
                    guard let state = pack.state else {
                        return false
                    }
                    switch state {
                    case .delivering:
                        return true
                    case .delivering231:
                        return true
                    case .delivering232:
                        return true
                    case .undelivered211:
                        return false
                    case .undelivered206:
                        return false
                    case .none:
                        return false
                    }
                }
                
                strongSelf.packagesList = packs
                
                strongSelf.servicesList = serviceList
                if strongSelf.packageToShowDetail == nil {
                    strongSelf.findPackageRegion(packagesList: packList, servicesList: serviceList)
                    strongSelf.updateDataSource(packagesList: packList, servicesList: serviceList)
                }
            })
            .store(in: &disposables)
        
        self.$packageToShowDetail
            .sink(receiveValue: { [weak self] (pack) in
                guard let warehouseID = pack?.warehouse_id else {
                    return
                }
                self?.mapViewModel?.fetchLanguagesFromAPI(warehouseID: warehouseID)
            })
            .store(in: &disposables)
        self.mapViewModel?.$languagesList
            .sink(receiveValue: { [weak self] (languagesList) in
                self?.languagesList = languagesList
            })
            .store(in: &disposables)
        self.mapViewModel?.$msgTemplatesList
            .sink(receiveValue: { [weak self] (templatesList) in
                self?.msgTemplatesList = templatesList
                self?.sendMsgPickup()
            })
            .store(in: &disposables)
        self.mapViewModel?.$responseSendMsg
            .sink(receiveValue: { [weak self] (response) in
                guard response != nil else {
                    return
                }
                let alert = CustomImageAlert.makeAlert(title: String.sentStr, image: UIImage.circledCheckmark)
                
                self?.present(alert, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                    alert.dismiss(animated: true, completion: nil)
                }
            })
            .store(in: &disposables)
    }
    
    private func observingError() {
        self.servicesListViewModel.$networkError
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] err in
                guard let strongSelf = self else { return }
                guard let err = err else {
                    return
                }
                switch err {
                case .invalidURL( _):
                    let positiveAction = Action(title: String.OKStr)
                    strongSelf.showAlert(title: String.networkFailureStr, msg: String.pleaseCheckYourNetworkAndRetryStr, positiveAction: positiveAction, negativeAction: nil)
                case .netConnection( _):
                    let positiveAction = Action(title: String.OKStr)
                    strongSelf.showAlert(title: String.networkFailureStr, msg: String.pleaseCheckYourNetworkAndRetryStr, positiveAction: positiveAction, negativeAction: nil)
                default:
                    break
                }
            })
            .store(in: &disposables)
        self.mapViewModel?.$errorUpdateAddressType
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] err in
                guard let strongSelf = self else { return }
                guard let err = err, !err.isEmpty else {
                    return
                }
                let positiveAction = Action(title: String.OKStr)
                strongSelf.showAlert(title: err, msg: nil, positiveAction: positiveAction, negativeAction: nil)
            })
            .store(in: &disposables)
        self.mapViewModel?.$errorSendMsg
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] err in
                guard let strongSelf = self else { return }
                guard let err = err else {
                    return
                }
                switch err {
                case .invalidURL( _):
                    let positiveAction = Action(title: String.OKStr)
                    strongSelf.showAlert(title: String.networkFailureStr, msg: String.pleaseCheckYourNetworkAndRetryStr, positiveAction: positiveAction, negativeAction: nil)
                case .netConnection( _):
                    let positiveAction = Action(title: String.OKStr)
                    strongSelf.showAlert(title: String.networkFailureStr, msg: String.pleaseCheckYourNetworkAndRetryStr, positiveAction: positiveAction, negativeAction: nil)
                case .failStatusCode( _):
                    let positiveAction = Action(title: String.retryStr) { _ in
                        guard let orderID = strongSelf.packageToShowDetail?.order_id, let templateID = strongSelf.templateID else {
                            return
                        }
                        strongSelf.mapViewModel?.errorSendMsg = nil
                        strongSelf.mapViewModel?.sendMsgFromAPI(orderID: orderID, templateID: templateID)
                    }
                    let negativeAction = Action(title: String.cancelStr)
                    strongSelf.showAlert(title: String.failedSendingMessageStr, msg: String.failToSendAMessageStr, positiveAction: positiveAction, negativeAction: negativeAction)
                default:
                    break
                }
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
            service.lat
        }
        let lngsService: [Double] = servicesList.compactMap { service -> Double? in
            service.lng
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
    
    private func updateCameraBound(latRegion: (min: Double, max: Double), lngRegion: (min: Double, max: Double), completion: (() -> ())? = nil) {
        
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
        self.mapView.camera.fly(to: camera, duration: 0) { _ in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
                completion?()
            }
        }
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
    
    deinit {
        print("🍎 MapClusterViewController - deinit")
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

enum FailedChoose {
    case noRedelivery
    case firstDelivery
    case secondDelivery
    case thirdDelivery
}
