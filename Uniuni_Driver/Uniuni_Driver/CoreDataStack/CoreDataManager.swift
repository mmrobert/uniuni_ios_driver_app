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
    @Published var services: [ServicePointDataModel] = []
    
    @Published var saveFailedUploadedError: CoreDataError?
    
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
        
        if isPackageSaved(package: package) {
            return
        }

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
            object.setValue(package.address_type?.rawValue, forKeyPath: "address_type")
            object.setValue(package.zipcode, forKeyPath: "zipcode")
            object.setValue(package.lat, forKeyPath: "lat")
            object.setValue(package.lng, forKeyPath: "lng")
            object.setValue(package.buzz_code, forKeyPath: "buzz_code")
            object.setValue(package.postscript, forKeyPath: "postscript")
            object.setValue(package.warehouse_id, forKeyPath: "warehouse_id")
            object.setValue(package.need_retry, forKeyPath: "need_retry")
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
                    pack.route_no = object.value(forKey: "route_no") as? Int
                    pack.assign_time = object.value(forKey: "assign_time") as? String
                    pack.delivery_by = object.value(forKey: "delivery_by") as? String
                    let stateInt = object.value(forKey: "state") as? Int
                    pack.state = PackageState.getStateFrom(value: stateInt)
                    pack.name = object.value(forKey: "name") as? String
                    pack.mobile = object.value(forKey: "mobile") as? String
                    pack.address = object.value(forKey: "address") as? String
                    let addressTypeInt = object.value(forKey: "address_type") as? Int
                    pack.address_type = AddressType.getTypeFrom(value: addressTypeInt)
                    pack.zipcode = object.value(forKey: "zipcode") as? String
                    pack.lat = object.value(forKey: "lat") as? String
                    pack.lng = object.value(forKey: "lng") as? String
                    pack.buzz_code = object.value(forKey: "buzz_code") as? String
                    pack.postscript = object.value(forKey: "postscript") as? String
                    pack.warehouse_id = object.value(forKey: "warehouse_id") as? Int
                    pack.need_retry = object.value(forKey: "need_retry") as? Int
                    let failedInt = object.value(forKey: "failed_handle_type") as? Int
                    pack.failed_handle_type = FailedHandleType.getTypeFrom(value: failedInt)
                    
                    return pack
                }
            } catch let error as NSError {
                print("Could not fetch packages: \(error)")
            }
        }
    }
    
    func updatePackage(package: PackageDataModel) {
        
        guard let orderId = package.order_id else {
            return
        }
        let taskContext = newTaskContext()
        
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Package")
            fetchRequest.predicate = NSPredicate(format: "order_id = %i", orderId)
            do {
                let packs = try taskContext.fetch(fetchRequest)
                if packs.count > 0 {
                    let managedObject = packs[0]
                    managedObject.setValue(package.address_type?.rawValue, forKeyPath: "address_type")
                    managedObject.setValue(package.state?.rawValue, forKeyPath: "state")
                    do {
                        try taskContext.save()
                    } catch let error as NSError {
                        print("Could not save package: \(error)")
                    }
                }
            } catch {
                print("Could not fetch package: \(error)")
            }
        }
    }
    
    private func isPackageSaved(package: PackageDataModel) -> Bool {
        
        guard let orderId = package.order_id else {
            return true
        }
        
        let taskContext = newTaskContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Package")
        fetchRequest.predicate = NSPredicate(format: "order_id = %i", orderId)
            
        var packs: [NSManagedObject]?
        do {
            packs = try taskContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch: \(error)")
        }
        
        if packs?.count ?? 0 > 0 {
            return true
        } else {
            return false
        }
    }
    
    func saveServicePoint(servicePoint: ServicePointDataModel) {
        
        if isServiceSaved(service: servicePoint) {
            return
        }

        let taskContext = newTaskContext()
        
        taskContext.perform {
            guard let entity = NSEntityDescription.entity(forEntityName: "ServicePoint", in: taskContext) else { return }
            
            let object = NSManagedObject(entity: entity, insertInto: taskContext)
            object.setValue(servicePoint.id, forKeyPath: "id")
            object.setValue(servicePoint.name, forKeyPath: "name")
            object.setValue(servicePoint.uni_operator_id, forKeyPath: "uni_operator_id")
            object.setValue(servicePoint.type, forKeyPath: "type")
            object.setValue(servicePoint.code, forKeyPath: "code")
            object.setValue(servicePoint.address, forKeyPath: "address")
            object.setValue(servicePoint.lat, forKeyPath: "lat")
            object.setValue(servicePoint.lng, forKeyPath: "lng")
            object.setValue(servicePoint.district, forKeyPath: "district")
            object.setValue(servicePoint.business_hours, forKeyPath: "business_hours")
            object.setValue(servicePoint.unit_number, forKeyPath: "unit_number")
            object.setValue(servicePoint.phone, forKeyPath: "phone")
            object.setValue(servicePoint.partner_id, forKeyPath: "partner_id")
            object.setValue(servicePoint.company, forKeyPath: "company")
            object.setValue(servicePoint.is_active, forKeyPath: "is_active")
            object.setValue(servicePoint.warehouse, forKeyPath: "warehouse")
            object.setValue(servicePoint.premise_type, forKeyPath: "premise_type")
            object.setValue(servicePoint.device, forKeyPath: "device")
            object.setValue(servicePoint.contact, forKeyPath: "contact")
            object.setValue(servicePoint.login, forKeyPath: "login")
            object.setValue(servicePoint.password, forKeyPath: "password")
            object.setValue(servicePoint.verification_code, forKeyPath: "verification_code")
            object.setValue(servicePoint.storage_space, forKeyPath: "storage_space")
            object.setValue(servicePoint.remark, forKeyPath: "remark")
            
            do {
                try taskContext.save()
            } catch let error as NSError {
                print("Could not save service point: \(error)")
            }
        }
    }
    
    private func isServiceSaved(service: ServicePointDataModel) -> Bool {
        
        guard let id = service.id else {
            return true
        }
        
        let taskContext = newTaskContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ServicePoint")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
            
        var services: [NSManagedObject]?
        do {
            services = try taskContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch: \(error)")
        }
        
        if services?.count ?? 0 > 0 {
            return true
        } else {
            return false
        }
    }
    
    func fetchServicePoints() {
        
        let taskContext = newTaskContext()
        
        taskContext.perform { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ServicePoint")
            do {
                let servicesP = try taskContext.fetch(fetchRequest)
                strongSelf.services = servicesP.map { object in
                    var service = ServicePointDataModel()
                    
                    service.id = object.value(forKey: "id") as? Int
                    service.name = object.value(forKey: "name") as? String
                    service.uni_operator_id = object.value(forKey: "uni_operator_id") as? Int
                    service.type = object.value(forKey: "type") as? Int
                    service.code = object.value(forKey: "code") as? String
                    service.address = object.value(forKey: "address") as? String
                    service.lat = object.value(forKey: "lat") as? Double
                    service.lng = object.value(forKey: "lng") as? Double
                    service.district = object.value(forKey: "district") as? Int
                    service.business_hours = object.value(forKey: "business_hours") as? String
                    service.unit_number = object.value(forKey: "unit_number") as? String
                    service.phone = object.value(forKey: "phone") as? String
                    service.partner_id = object.value(forKey: "partner_id") as? Int
                    service.company = object.value(forKey: "company") as? String
                    service.is_active = object.value(forKey: "is_active") as? Int
                    service.warehouse = object.value(forKey: "warehouse") as? Int
                    service.premise_type = object.value(forKey: "premise_type") as? String
                    service.device = object.value(forKey: "device") as? String
                    service.contact = object.value(forKey: "contact") as? String
                    service.login = object.value(forKey: "login") as? String
                    service.password = object.value(forKey: "password") as? String
                    service.verification_code = object.value(forKey: "verification_code") as? Int
                    service.storage_space = object.value(forKey: "storage_space") as? Int
                    service.remark = object.value(forKey: "remark") as? String
                    
                    return service
                }
            } catch let error as NSError {
                print("Could not fetch service points: \(error)")
            }
        }
    }
    
    func saveFailedUploaded(orderID: Int, deliveryResult: Int, podImages: [Data], failedReason: Int?) {
        
        if isFailedUploadedSaved(orderID: orderID) {
            self.saveFailedUploadedError = nil
            return
        }

        let taskContext = newTaskContext()
        
        taskContext.perform {
            guard let entity = NSEntityDescription.entity(forEntityName: "FailedUploaded", in: taskContext) else { return }
            
            let object = NSManagedObject(entity: entity, insertInto: taskContext)
            object.setValue(orderID, forKeyPath: "order_id")
            object.setValue(deliveryResult, forKeyPath: "delivery_result")
            object.setValue(failedReason, forKeyPath: "failed_reason")
            object.setValue(Date(), forKeyPath: "saved_time")
            if podImages.count == 1 {
                object.setValue(podImages[0], forKeyPath: "image1")
            } else if podImages.count > 1 {
                object.setValue(podImages[0], forKeyPath: "image1")
                object.setValue(podImages[1], forKeyPath: "image2")
            }
            
            do {
                try taskContext.save()
            } catch let error as NSError {
                self.saveFailedUploadedError = CoreDataError.saveFailedUploaded
                print("Could not save: \(error)")
            }
            if self.saveFailedUploadedError == nil {
                self.saveFailedUploadedError = nil
            }
        }
    }
    
    private func isFailedUploadedSaved(orderID: Int) -> Bool {
        
        let taskContext = newTaskContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FailedUploaded")
        fetchRequest.predicate = NSPredicate(format: "order_id = %i", orderID)
            
        var failedUploaded: [NSManagedObject]?
        do {
            failedUploaded = try taskContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch: \(error)")
        }
        
        if failedUploaded?.count ?? 0 > 0 {
            return true
        } else {
            return false
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

enum CoreDataError: Error {
    case saveFailedUploaded
    case fetch
}
