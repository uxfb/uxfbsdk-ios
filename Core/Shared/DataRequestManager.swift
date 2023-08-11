//
//  UXFBRequestManager.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 16.01.2023.
//  Copyright © 2023 UXF. All rights reserved.
//

import Foundation
import CoreData

protocol RequestManagerDelegate {
    func campaingsLoaded(success: Bool, message: String?, delay: Int?, campaigns: Array<Campaign>)
    func formDataSaved(success: Bool, message: String?, capmaignId: String)
}

@_documentation(visibility: internal)
public struct NetworkSettings {
    var requestTimeout: Double
    var retryCount: Int
    var retryTimeout: Double
}

final class DataRequestManager: NSObject {
    
    private let model: String = "RequestModel"
    
    private var _apiClient: APIClient!
    
    private var delegate: RequestManagerDelegate?
    
    var settings: NetworkSettings!
    
    private var attempts = 0
    
    init(endpoint: String?,
         appID: String,
         parser: Parser,
         delegate: RequestManagerDelegate?) {
        super.init()
        self._apiClient = APIClient(endpoint: endpoint,
                                       appID: appID,
                                       parser: parser)
        self.delegate = delegate
        
        settings = NetworkSettings(requestTimeout: 5,
                                      retryCount: 3,
                                      retryTimeout: 10)
        self.prepareAndSend()
    }
    
    //MARK: - Public methods
    
    public func getAllCampaigns() {
        createRequest("GET_CAMPAIGNS", parameters: nil)
    }
    
    public func sendFormData(projectId: String?,
                             campaignId: String,
                             pages: Array<Dictionary<String,Any>>?,
                             properties: Dictionary<String,Any>?) {
        
        let parameters = ["projectId": projectId as Any,
                          "campaignId": campaignId,
                          "pages": pages as Any,
                          "properties": properties as Any] as [String : Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)

        createRequest("SEND_FORM", parameters: jsonData)
    }
    
    public func sendShowForm(campaignId: String) {
        let parameters = ["campaignId": campaignId]
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        createRequest("SHOW_FORM", parameters: jsonData)
    }
    
    public func sendScreenshotsData(screenshots: [Screenshot]) {
        for screenshot in screenshots {
            let image = screenshot.image
            let data = image.jpegData(compressionQuality: 1)
            let base64image = data?.base64EncodedString() ?? ""
            let dataScreenshot = ScreenshotData(id: screenshot.id, base64image: base64image)
            let jsonData = try? JSONEncoder().encode(dataScreenshot)
            createRequest("SCREENSHOT", parameters: jsonData)
        }
    }
    
    //MARK: - prepare sender
    
    private func prepareAndSend(_ request: DataRequest? = nil) {
        if let request = request {
            self.sendNextRequest(request)
        } else {
            self.fetch { request in
                if let request = request {
                    self.sendNextRequest(request)
                }
            }
        }
    }
    
    //MARK: - Request private methods
    
    private var isActive = false
    
    private func validateResponse(for request: DataRequest,
                                  success: Bool,
                                  httpCode: Int,
                                  completion: @escaping (() -> ()) ) {
        if success || httpCode == 200 {
            attempts = 0
            deleteRequest(request) {
                completion()
            }
        } else if httpCode == 410 || attempts >= settings.retryCount {
            attempts = 0
            deleteRequest(request)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + settings.retryTimeout) {
                self.prepareAndSend(request)
            }
        }
    }
    
    private func sendNextRequest(_ request: DataRequest) {
        isActive = true
        let data = request.parametersData
        self.attempts += 1
        switch request.apiMethod {
        case "GET_CAMPAIGNS":
            self._apiClient.getAllCampaings { [weak self] (success, httpCode, message, delay, campaigns)  in
                self?.validateResponse(for: request, success: success, httpCode: httpCode) {
                    self?.delegate?.campaingsLoaded(success: success, message: message, delay: delay, campaigns: campaigns)
                }
            }
            
        case "SEND_FORM":
            guard let data = data,
                  let dict = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                  let projectId = dict["projectId"] as? String,
                  let campaignId = dict["campaignId"] as? String,
                  let pages = dict["pages"] as? Array<Dictionary<String,Any>>,
                  let properties = dict["properties"] as? Dictionary<String,Any>
            else {
                self.deleteRequest(request, completion: { })
                return
            }
            
            self._apiClient.saveFormData(projectId: projectId,
                                         campaignId: campaignId,
                                         pages: pages,
                                         properties: properties) { (success, httpCode, message) in
                self.validateResponse(for: request, success: success, httpCode: httpCode) {
                    self.delegate?.formDataSaved(success: success,
                                                 message: message,
                                                 capmaignId: campaignId)
                }
            }
            
        case "SHOW_FORM":
            guard let data = data,
                  let dict = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                  let campaignId = dict["campaignId"] as? String
            else {
                self.deleteRequest(request, completion: { })
                return
            }
            self._apiClient.showForm(campaingId: campaignId) { success, httpCode in
                self.validateResponse(for: request, success: success, httpCode: httpCode) { }
            }
            
        case "SCREENSHOT":
            guard let data = data, let dataScreenshot = try? JSONDecoder().decode(ScreenshotData.self, from: data) else {
                self.deleteRequest(request, completion: { })
                return
            }
            
            self._apiClient.saveScreenshotsData(dataScreenshot) { success, httpCode in
                self.validateResponse(for: request, success: success, httpCode: httpCode) { }
            }
            
        default:
            break
        }
    }
    
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
        
        container.loadPersistentStores { (storeDescription, error) in
            if let err = error{
                print("Loading of uxfb store failed: \(err)")
            }
        }
        return container
    }()

    lazy var context = persistentContainer.newBackgroundContext()
   
    private func fetch(completion: @escaping (DataRequest?) -> Void ) {
        context.perform {
            do {
                let fetchRequest = NSFetchRequest<DataRequest>(entityName: "DataRequest")
                let sort = NSSortDescriptor(key: "created", ascending: true)
                fetchRequest.sortDescriptors = [sort]
                fetchRequest.fetchLimit = 1
                let request = try self.context.fetch(fetchRequest).first
                completion(request)
            } catch {
                completion(nil)
            }
        }
    }
    
    private func createRequest(_ apiMethod: String, parameters: Data?) {
        context.performAndWait {
            if apiMethod == "GET_CAMPAIGNS" {
                let fetchRequest = NSFetchRequest<DataRequest>(entityName: "DataRequest")
                fetchRequest.predicate = NSPredicate(format: "apiMethod == %@", apiMethod)
                let numberOfRecords = (try? self.context.count(for: fetchRequest)) ?? 0
                if numberOfRecords > 0 {
                    return
                }
            }
            
            let request = NSEntityDescription.insertNewObject(forEntityName: "DataRequest", into: self.context) as! DataRequest
            request.apiMethod = apiMethod
            request.created = Date()
            request.parametersData = parameters
            try? self.context.save()
            
            if !self.isActive {
                self.finishContext()
            }
        }
    }
    
    private func deleteRequest(_ request: DataRequest, completion: (() -> ())? = nil ) {
        context.performAndWait {
            context.delete(request)
            try? context.save()
            finishContext(completion: completion)
        }
    }
    
    private func finishContext(completion: (() -> ())? = nil ) {
        isActive = false
        completion?()
        self.prepareAndSend()
    }
}
