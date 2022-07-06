//
//  CoreDataStackTests.swift
//  Uniuni_DriverTests
//
//  Created by Boqian Cheng on 2022-06-24.
//

import XCTest
@testable import Uniuni_Driver
import Combine

class CoreDataStackTests: XCTestCase {
    
    var subject: MockCoreDataManager!
    var disposables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        subject = MockCoreDataManager.shared
        disposables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        subject = nil
        disposables = nil
    }
    
    func testSavePackage() {
        
        let expectation = XCTestExpectation(description: "Saving package!")
        
        let uuid = UUID().uuidString
        let testedPack = PackageDataModel(
            serialNo: uuid,
            date: "5-8-2022",
            routeNo: "000",
            name: uuid,
            address: "Test St",
            distance: "30KM Away",
            state: .delivering
        )
        subject.$savingFinished
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] savingFinished in
                if savingFinished {
                    self?.subject.fetchPackages()
                }
            })
            .store(in: &disposables)
        subject.$packages
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { packages in
                let packs = packages.filter {
                    $0.serialNo == uuid
                }
                if let pack = packs.first {
                    XCTAssertTrue(pack.name == uuid)
                    XCTAssertTrue(pack.state == .delivering)
                    expectation.fulfill()
                }
            })
            .store(in: &disposables)
        
        subject.savePackage(package: testedPack)
        
        wait(for: [expectation], timeout: 10.0)
    }
}
