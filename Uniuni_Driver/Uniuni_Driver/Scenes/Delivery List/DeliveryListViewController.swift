//
//  DeliveryListViewController.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-18.
//

import Foundation
import UIKit
import Combine

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
        
        self.observingViewModels()
        
        // fetch packages
        self.packagesListViewModel.fetchPackages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func observingViewModels() {
        self.packagesListViewModel.$list
            .sink(receiveValue: { [weak self] list in
                guard let strongSelf = self else { return }
                strongSelf.packagesList = list
                strongSelf.segmentSelected()
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
            self.listToDisplay = self.packagesList.filter {
                $0.state == .undelivered
            }
        default:
            self.listToDisplay = self.packagesList.filter {
                $0.state == .delivering
            }
        }
        
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
        sortTitle.text = String.dateStr
        let sortImage = UIImageView(image: UIImage.sort)
        let sortBtnView = UIStackView(arrangedSubviews: [sortTitle, sortImage])
        sortBtnView.axis = .horizontal
        sortBtnView.spacing = Constants.stackSpacing
        let sortBtn = UIBarButtonItem(customView: sortBtnView)
        self.navigationItem.rightBarButtonItems = [searchBtn, routeBtn, sortBtn]
    }
    
    @objc
    private func burgerButtonAction() {
        
    }
    
    @objc
    private func searchButtonAction() {
        
    }
    
    @objc
    private func routeButtonAction() {
        
    }
    
    @objc
    private func sortButtonAction() {
        
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
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: self.segmentedControlContainer.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// Table datasource and delegate
extension DeliveryListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.listToDisplay[indexPath.row].serialNo
        return cell
    }
}
