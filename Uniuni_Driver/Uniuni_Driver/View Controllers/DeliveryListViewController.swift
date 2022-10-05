//
//  DeliveryListViewController.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-18.
//

import Foundation
import UIKit
import Combine
import SwiftUI
import MapKit

class DeliveryListViewController: UIViewController {
    
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
        
        static let cellReuseIdentifier: String = "deliveryListCell"
    }
    
    private let segmentedControlContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.screenBase
        return container
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl()
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.backgroundColor = UIColor.screenBase
        sc.setTitleTextAttributes([.foregroundColor: UIColor.highlightedBlue as Any], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.lightBlackText as Any], for: .normal)
        sc.selectedSegmentTintColor = UIColor.screenBase
        return sc
    }()
    
    let tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.screenBase
        return view
    }()
    
    private var packagesListViewModel: PackagesListViewModel
    private var disposables = Set<AnyCancellable>()
    
    private var packagesList: [PackageViewModel] = []
    
    private var listToDisplay: [PackageViewModel] = []
    
    private var sortTitleLabel: UILabel?
    private var packageSort: PackageSort = .route
    
    private let locationManager = CLLocationManager()
    
    private var currentLocation: (lat: Double, lng: Double) = (49.14, -122.98)
    
    private var listRefreshing: Bool = false
    
    init(packagesListViewModel: PackagesListViewModel) {
        self.packagesListViewModel = packagesListViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.screenBase
        self.navigationController?.configureNavigationBar(isLargeTitle: false, backgroundColor: UIColor.tabbarBackground, tintColor: UIColor.naviBarButton)
        self.navigationController?.configureStatusBar(backgroundColor: UIColor.tabbarBackground)
        self.configureLeftButtonItems()
        self.configureRightButtonItems()
        
        self.setupSegmentedControlContainer()
        self.setupSegmentedControl()
        self.setupTableView()
        
        self.locationManager.delegate = self
        self.checkLocationManager()
        
        self.observingViewModels()
        self.observingError()
        
        // fetch packages
        self.packagesListViewModel.fetchPackagesFromAPI(driverID: 100)
        //self.packagesListViewModel.saveMockPackagesList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if CoreDataManager.shared.packagesListUpdated {
            self.packagesListViewModel.fetchPackagesFromCoreData()
        }
    }
    
    private func checkLocationManager() {
        let authStatus = locationManager.authorizationStatus
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if authStatus == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
    }
    
    private func observingViewModels() {
        self.packagesListViewModel.$list
            .sink(receiveValue: { [weak self] list in
                guard let strongSelf = self else { return }
                if strongSelf.listRefreshing {
                    strongSelf.tableView.refreshControl?.endRefreshing()
                    strongSelf.listRefreshing = false
                }
                strongSelf.packagesList = list
                strongSelf.segmentSelected()
            })
            .store(in: &disposables)
    }
    
    private func observingError() {
        self.packagesListViewModel.$networkError
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] err in
                guard let strongSelf = self else { return }
                guard let err = err else {
                    return
                }
                if strongSelf.listRefreshing {
                    strongSelf.tableView.refreshControl?.endRefreshing()
                    strongSelf.listRefreshing = false
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
    }
    
    @objc
    private func segmentSelected() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.listToDisplay = self.packagesList.filter {
                $0.state == .delivering
            }
        case 1:
            self.listToDisplay = self.packagesList.filter { pack in
                guard let state = pack.state else {
                    return false
                }
                switch state {
                case .delivering:
                    return false
                case .undelivered211:
                    return true
                case .undelivered206:
                    return true
                }
            }
        default:
            self.listToDisplay = self.packagesList.filter {
                $0.state == .delivering
            }
        }
        
        self.listToDisplay = self.packagesListViewModel.sort(list: self.listToDisplay, by: self.packageSort, location: self.currentLocation)
        self.tableView.reloadData()
    }
    
    private func configureLeftButtonItems() {
        let burgerBtn = UIBarButtonItem(image: UIImage.burger, style: .plain, target: self, action: #selector(DeliveryListViewController.burgerButtonAction))
        self.navigationItem.leftBarButtonItems = [burgerBtn]
    }
    
    private func configureRightButtonItems() {
        let searchBtn = UIBarButtonItem(image: UIImage.search, style: .plain, target: self, action: #selector(DeliveryListViewController.searchButtonAction))
        let routeBtn = UIBarButtonItem(image: UIImage.route, style: .plain, target: self, action: #selector(DeliveryListViewController.routeButtonAction))
        let sortTitle = UILabel()
        sortTitle.text = self.packageSort.getDisplayString()
        let sortImage = UIImageView(image: UIImage.sort)
        let sortBtnView = UIStackView(arrangedSubviews: [sortTitle, sortImage])
        sortBtnView.axis = .horizontal
        sortBtnView.spacing = Constants.stackSpacing
        let sortTap = UITapGestureRecognizer(target: self, action: #selector(DeliveryListViewController.sortButtonAction))
        sortBtnView.addGestureRecognizer(sortTap)
        let sortBtn = UIBarButtonItem(customView: sortBtnView)
        self.sortTitleLabel = sortTitle
        self.navigationItem.rightBarButtonItems = [searchBtn, routeBtn, sortBtn]
    }
    
    @objc
    private func burgerButtonAction() {
        
    }
    
    @objc
    private func searchButtonAction() {
        let searchView = PackageSearchView(naviController: self.navigationController)

        let searchVC = UIHostingController(rootView: searchView)
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc
    private func routeButtonAction() {
        let mapView = MapClusterViewController(
            packagesListViewModel: PackagesListViewModel(),
            servicesListViewModel: ServicePointsListViewModel(),
            mapViewModel: MapViewModel())
        mapView.packageToShowDetail = nil
        self.navigationController?.pushViewController(mapView, animated: true)
    }
    
    @objc
    private func sortButtonAction() {
        let sortSelection = TopActionSheet()
        let expressSort = Action(title: String.expressStr) { [weak self] _ in
            self?.sortTitleLabel?.text = String.expressStr
            self?.packageSort = .express
            self?.segmentSelected()
        }
        let dateSort = Action(title: String.dateStr) { [weak self] _ in
            self?.sortTitleLabel?.text = String.dateStr
            self?.packageSort = .date
            self?.segmentSelected()
        }
        let routeSort = Action(title: String.routeStr) { [weak self] _ in
            self?.sortTitleLabel?.text = String.routeStr
            self?.packageSort = .route
            self?.segmentSelected()
        }
        let distanceSort = Action(title: String.distanceStr) { [weak self] _ in
            self?.sortTitleLabel?.text = String.distanceStr
            self?.packageSort = .distance
            self?.segmentSelected()
        }
        let actions = [expressSort, dateSort, routeSort, distanceSort]
        sortSelection.configure(viewModel: TopActionSheetViewModel(title: String.sortListByStr, actions: actions))
        sortSelection.modalPresentationStyle = .overCurrentContext
        self.present(sortSelection, animated: true)
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
}

// UI set up
extension DeliveryListViewController {
    
    private func setupSegmentedControlContainer() {
        self.view.addSubview(self.segmentedControlContainer)
        NSLayoutConstraint.activate(
            [segmentedControlContainer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
             segmentedControlContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
             segmentedControlContainer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
             segmentedControlContainer.heightAnchor.constraint(equalToConstant: Constants.segmentedControlHeight)]
        )
    }
    
    private func setupSegmentedControl() {
        self.segmentedControl.insertSegment(withTitle: String.deliveringStr, at: 0, animated: false)
        self.segmentedControl.insertSegment(withTitle: String.undeliveredStr, at: 1, animated: false)
        self.segmentedControl.addTarget(self, action: #selector(DeliveryListViewController.segmentSelected), for: .valueChanged)
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControlContainer.addSubview(self.segmentedControl)
        NSLayoutConstraint.activate(
            [segmentedControl.leadingAnchor.constraint(equalTo: self.segmentedControlContainer.leadingAnchor, constant: Constants.leadingSpacing),
             segmentedControl.trailingAnchor.constraint(equalTo: self.segmentedControlContainer.trailingAnchor, constant: -Constants.trailingSpacing),
             segmentedControl.centerYAnchor.constraint(equalTo: self.segmentedControlContainer.centerYAnchor)]
        )
    }
    
    private func setupTableView() {
        self.tableView.register(PackageTableViewCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(DeliveryListViewController.refreshPackagesListFromAPI), for: .valueChanged)
        self.view.addSubview(self.tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: self.segmentedControlContainer.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc
    private func refreshPackagesListFromAPI() {
        self.listRefreshing = true
        self.packagesListViewModel.fetchPackagesFromAPI(driverID: 100)
    }
}

// Table datasource and delegate
extension DeliveryListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier, for: indexPath) as! PackageTableViewCell
        let viewModel = self.listToDisplay[indexPath.row]
        cell.configure(packageViewModel: viewModel, location: self.currentLocation)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pack = self.listToDisplay[indexPath.row]
        let mapView = MapClusterViewController(
            packagesListViewModel: PackagesListViewModel(),
            servicesListViewModel: ServicePointsListViewModel(),
            mapViewModel: MapViewModel())
        mapView.packageToShowDetail = pack
        self.navigationController?.pushViewController(mapView, animated: true)
    }
}

extension DeliveryListViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLo = locations.first else {
            return
        }
        self.currentLocation = (latestLo.coordinate.latitude, latestLo.coordinate.longitude)
        self.tableView.reloadData()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.checkLocationManager()
    }
}
