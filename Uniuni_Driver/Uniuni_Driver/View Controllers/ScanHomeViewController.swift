//
//  ScanHomeViewController.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-11-07.
//

import Foundation
import UIKit
import Combine
import SwiftUI
/*
class ScanHomeViewController: UIViewController {
    
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
    
    private let scrollView: UIScrollView = {
        let container = UIScrollView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.screenBase
        return container
    }()
    
    private let pickupContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.screenBase
        return view
    }()
    
    private lazy var pickupIcon: UIImageView = {
        let imgView = UIImageView(image: UIImage.iconPackage)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.isUserInteractionEnabled = false
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private let pickupInfoStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.alignment = .leading
        return view
    }()
    
    private lazy var pickupTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.lightBlackText
        label.numberOfLines = 1
        label.textAlignment = .left
        label.text = String.orderToPickupStr
        return label
    }()
    
    private lazy var pickupNoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.lightBlackText
        label.numberOfLines = 1
        label.textAlignment = .left
        label.text = String.orderToPickupStr
        return label
    }()
    
    private lazy var pickupAddressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.naviBarButton
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let dropoffContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.screenBase
        return view
    }()
    
    
    
    
    
    
    
    
    private let businessPickupContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.screenBase
        return view
    }()
    
    private var viewModel: ScanHomeViewModel
    private var disposables = Set<AnyCancellable>()
    
    init(viewModel: ScanHomeViewModel) {
        self.viewModel = viewModel
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
        self.navigationController?.navigationBar.backgroundColor = .white
        
        
        
        
        
        self.observingViewModels()
        self.observingError()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchPacksPickDropInfo(driverID: AppConfigurator.shared.driverID)
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
    private func gotoPickupScan() {
        
    }
    
    @objc
    private func gotoDropoffScan() {
        
    }
    
    @objc
    private func gotoBusinessPickupScan() {
        
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
extension ScanHomeViewController {
    
    private func createScanArrowView(hasText: Bool) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.screenBase
        
        let imgView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.isUserInteractionEnabled = false
        imgView.contentMode = .scaleAspectFit
        
        let scanLabel = UILabel()
        scanLabel.translatesAutoresizingMaskIntoConstraints = false
        scanLabel.isUserInteractionEnabled = false
        scanLabel.font = UIFont.boldSystemFont(ofSize: 16)
        scanLabel.textColor = UIColor.naviBarButton
        scanLabel.numberOfLines = 1
        scanLabel.textAlignment = .left
        scanLabel.text = String.scanStr
        
        container.addSubview(scanLabel)
        NSLayoutConstraint.activate(
            [scanLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
             scanLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
             scanLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 6)]
        )
        container.addSubview(imgView)
        NSLayoutConstraint.activate(
            [imgView.leadingAnchor.constraint(equalTo: scanLabel.trailingAnchor, constant: 5),
             imgView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
             imgView.centerYAnchor.constraint(equalTo: scanLabel.centerYAnchor, constant: 0)]
        )
        
        return container
    }
    
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
        self.packagesListViewModel.fetchPackagesFromAPI(driverID: AppConfigurator.shared.driverID)
    }
}
*/
