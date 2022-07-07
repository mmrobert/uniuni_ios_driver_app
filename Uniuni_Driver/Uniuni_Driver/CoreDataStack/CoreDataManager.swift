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
            
            let object = NSManagedObject(entity: entity, insertInto: taskContext)
            object.setValue(package.order_id, forKeyPath: "order_id")
            object.setValue(package.order_sn, forKey: "order_sn")
            object.setValue(package.tracking_no, forKeyPath: "tracking_no")
            object.setValue(package.goods_type?.rawValue, forKeyPath: "goods_type")
            object.setValue(package.express_type?.rawValue, forKeyPath: "express_type")
            object.setValue(package.route_no, forKeyPath: "route_no")
            object.setValue(package.assign_time, forKeyPath: "assign_time")
            object.setValue(package.delivery_by, forKeyPath: "delivery_by")
            object.setValue(package.state?.rawValue, forKeyPath: "state")
            object.setValue(package.name, forKeyPath: "name")
            object.setValue(package.mobile, forKeyPath: "mobile")
            object.setValue(package.address, forKeyPath: "address")
            object.setValue(package.zipcode, forKeyPath: "zipcode")
            object.setValue(package.lat, forKeyPath: "lat")
            object.setValue(package.lng, forKeyPath: "lng")
            object.setValue(package.buzz_code, forKeyPath: "buzz_code")
            object.setValue(package.postscript, forKeyPath: "postscript")
            object.setValue(package.failed_handle_type?.rawValue, forKeyPath: "failed_handle_type")
            
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
                    pack.order_id = object.value(forKey: "order_id") as? Int
                    pack.order_sn = object.value(forKey: "order_sn") as? String
                    pack.tracking_no = object.value(forKey: "tracking_no") as? String
                    let goodsTypeInt = object.value(forKey: "goods_type") as? Int
                    pack.goods_type = GoodsType.getTypeFrom(value: goodsTypeInt)
                    let expressTypeInt = object.value(forKey: "express_type") as? Int
                    pack.express_type = ExpressType.getTypeFrom(value: expressTypeInt)
                    pack.route_no = object.value(forKey: "route_no") as? String
                    pack.assign_time = object.value(forKey: "assign_time") as? String
                    pack.delivery_by = object.value(forKey: "delivery_by") as? String
                    let stateInt = object.value(forKey: "state") as? Int
                    pack.state = PackageState.getStateFrom(value: stateInt)
                    pack.name = object.value(forKey: "name") as? String
                    pack.mobile = object.value(forKey: "mobile") as? String
                    pack.address = object.value(forKey: "address") as? String
                    pack.zipcode = object.value(forKey: "zipcode") as? String
                    pack.lat = object.value(forKey: "lat") as? String
                    pack.lng = object.value(forKey: "lng") as? String
                    pack.buzz_code = object.value(forKey: "buzz_code") as? String
                    pack.postscript = object.value(forKey: "postscript") as? String
                    let failedInt = object.value(forKey: "failed_handle_type") as? Int
                    pack.failed_handle_type = FailedHandleType.getTypeFrom(value: failedInt)
                    
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
