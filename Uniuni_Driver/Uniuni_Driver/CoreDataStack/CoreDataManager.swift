//
//  CoreDataManager.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-21.
//

import Foundation
import Combine
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    @Published var packages: [PackageDataModel] = []
    
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
        
        taskContext.perform {
            guard let entity = NSEntityDescription.entity(forEntityName: "Package", in: taskContext) else { return }
            
            let pack = NSManagedObject(entity: entity, insertInto: taskContext)
            pack.setValue(package.serialNo, forKeyPath: "serialNo")
            pack.setValue(package.routeNo, forKey: "routeNo")
            pack.setValue(package.name, forKeyPath: "name")
            pack.setValue(package.date, forKeyPath: "date")
            pack.setValue(package.address, forKeyPath: "address")
            pack.setValue(package.distance, forKeyPath: "distance")
            pack.setValue(package.state?.rawValue, forKeyPath: "state")
            
            do {
                try taskContext.save()
            } catch let error as NSError {
                print("Could not save package: \(error)")
            }
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
