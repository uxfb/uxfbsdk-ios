//
//  DataCampaignManager.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 10.07.2025.
//  Copyright © 2025 UXF. All rights reserved.
//

import CoreData

final class DataCampaignManager {
    
    init() { }
    
    private let model: String = "CampaignModel"
    
    //MARK: - Core data methods
    
    lazy var persistentContainer: NSPersistentContainer = {
        let messageKitBundle = Bundle(identifier: Consts.identifier)
        let modelURL = messageKitBundle!.url(forResource: self.model, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: self.model,
                                              managedObjectModel: managedObjectModel!)
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        
        description.setOption(FileProtectionType.none as NSObject?,
                              forKey: NSPersistentStoreFileProtectionKey)
        container.persistentStoreDescriptions = [description]
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.loadPersistentStores { (storeDescription, error) in
            if let err = error{
                print("Loading of uxfb store failed")
            }
        }
        return container
    }()
    
    lazy var context = persistentContainer.newBackgroundContext()
    
    
}
