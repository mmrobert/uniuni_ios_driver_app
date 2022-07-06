//
//  MockCoreDataManager.swift
//  Uniuni_DriverTests
//
//  Created by Boqian Cheng on 2022-06-25.
//

import Foundation
@testable import Uniuni_Driver
import Combine
import CoreData

class MockCoreDataManager {
    
    static let shared = MockCoreDataManager()
    
    private init() {}
    
    @Published var packages: [PackageDataModel] = []
    // added for test
    @Published var savingFinished: Bool = false
    
    /// A persistent container to set up the Core Data stack.
    lazy var container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Uniuni_Driver")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    func savePackage(package: PackageDataModel) {

        let taskContext = newTaskContext()
        
        taskContext.perform { [weak self] in
            guard let entity = NSEntityDescription.entity(forEntityName: "Package", in: taskContext) else { return }
            
            let object = NSManagedObject(entity: entity, insertInto: taskContext)
            object.setValue(package.serialNo, forKeyPath: "serialNo")
            object.setValue(package.routeNo, forKey: "routeNo")
            object.setValue(package.name, forKeyPath: "name")
            object.setValue(package.date, forKeyPath: "date")
            object.setValue(package.address, forKeyPath: "address")
            object.setValue(package.distance, forKeyPath: "distance")
            object.setValue(package.state?.rawValue, forKeyPath: "state")
            
            do {
                try taskContext.save()
            } catch let error as NSError {
                print("Could not save package: \(error)")
            }
            self?.savingFinished = true
        }
    }
    
    func fetchPackages() {
        
        let taskContext = newTaskContext()
        
        taskContext.perform { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Package")
            do {
                let packs = try taskContext.fetch(fetchRequest)
                strongSelf.packages = packs.map { object in
                    var pack = PackageDataModel()
                    pack.serialNo = object.value(forKey: "serialNo") as? String
                    pack.date = object.value(forKey: "date") as? String
                    pack.routeNo = object.value(forKey: "routeNo") as? String
                    pack.name = object.value(forKey: "name") as? String
                    pack.address = object.value(forKey: "address") as? String
                    pack.distance = object.value(forKey: "distance") as? String
                    let stateStr = object.value(forKey: "state") as? String
                    pack.state = PackageState.getStateFrom(description: stateStr)
                    return pack
                }
            } catch let error as NSError {
                print("Could not fetch packages: \(error)")
            }
        }
    }
    
    /// Creates and configures a private queue context.
    private func newTaskContext() -> NSManagedObjectContext {
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        taskContext.automaticallyMergesChangesFromParent = true
        return taskContext
    }
}

