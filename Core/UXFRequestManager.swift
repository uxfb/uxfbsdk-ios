//
//  UXFBRequestManager.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 16.01.2023.
//  Copyright © 2023 UXF. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    @discardableResult public func saveIfNeeded() throws -> Bool {
        guard hasChanges else { return false }
        try save()
        return true
    }
}

protocol UXFRequestManagerDelegate {
    func campaingsLoaded(success: Bool, message: String?, delay: Int?, campaigns: Array<UXFCampaign>)
    func formDataSaved(success: Bool, message: String?, capmaignId: String)
}

internal struct UXFNetworkSettings {
    var requestTimeout: Double
    var retryCount: Int
    var retryTimeout: Double
}

final internal class UXFRequestManager: NSObject {
    private let identifier: String  = "biz.andalex.uxfeedback.sdk"
    private let model: String = "RequestModel"
    
    private var _apiClient: UXFAPIClient!
    
    private var delegate: UXFRequestManagerDelegate?
    
    var settings: UXFNetworkSettings!
    
    private var attempts = 0
    
    private var isReady = true
    
    init(endpoint: String?,
         appID: String,
         parser: UXFParser,
         delegate: UXFRequestManagerDelegate?) {
        super.init()
        self._apiClient = UXFAPIClient(endpoint: endpoint,
                                       appID: appID,
                                       parser: parser)
        self.delegate = delegate
        
        settings = UXFNetworkSettings(requestTimeout: 5,
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
    
    public func sendScreenshotsData(screenshots: [UXFScreenshot]) {
        for screenshot in screenshots {
            let image = screenshot.image
            let data = image.jpegData(compressionQuality: 1)
            let base64image = data?.base64EncodedString() ?? ""
            let dataScreenshot = UXFScreenshotData(id: screenshot.id, base64image: base64image)
            let jsonData = try? JSONEncoder().encode(dataScreenshot)
            createRequest("SCREENSHOT", parameters: jsonData)
        }
    }
    
    //MARK: - prepare sender
    
    private func prepareAndSend(_ request: UXFRequest? = nil) {
//        DispatchQueue.global(qos: .background).async {
            guard self.isReady else {
                return
            }
            if let request = request {
                self.sendNextRequest(request)
            } else if let request = self.fetch() {
                self.sendNextRequest(request)
            }
//        }
    }
    
    //MARK: - Request private methods
    
    private func validateResponse(for request: UXFRequest,
                                  success: Bool,
                                  httpCode: Int,
                                  completion: @escaping (() -> ()) ) {
        isReady = true
        if success || httpCode == 200 {
            attempts = 0
            deleteRequest(request) {
                completion()
            }
        } else if httpCode == 410 || attempts >= settings.retryCount {
            attempts = 0
            deleteRequest(request)
        } else {
//            print("RM: RETRY will after timeout")
            DispatchQueue.main.asyncAfter(deadline: .now() + settings.retryTimeout) {
//                print("RM: RETRY!")
                self.prepareAndSend(request)
            }
        }
    }
    
    private func sendNextRequest(_ request: UXFRequest) {
        self.isReady = false
        let data = request.parametersData
        self.attempts += 1
        switch request.apiMethod {
        case "GET_CAMPAIGNS":
//            print("RM: GET_CAMPAIGNS \(Date().timeIntervalSince1970)")
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
//            print("RM: SEND_FORM \(Date().timeIntervalSince1970)")
            
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
//            print("RM: SHOW_FORM \(Date().timeIntervalSince1970)")
            self._apiClient.showForm(campaingId: campaignId) { success, httpCode in
                self.validateResponse(for: request, success: success, httpCode: httpCode) { }
            }
            
        case "SCREENSHOT":
            guard let data = data, let dataScreenshot = try? JSONDecoder().decode(UXFScreenshotData.self, from: data) else {
                self.deleteRequest(request, completion: { })
                return
            }
            
//            print("RM: SCREENSHOT \(Date().timeIntervalSince1970)")
            
            self._apiClient.saveScreenshotsData(dataScreenshot) { success, httpCode in
                self.validateResponse(for: request, success: success, httpCode: httpCode) { }
            }
            
        default:
            break
        }
    }
    
    //MARK: - Core data methods
    
    lazy var persistentContainer: NSPersistentContainer = {
        let messageKitBundle = Bundle(identifier: self.identifier)
        let modelURL = messageKitBundle!.url(forResource: self.model, withExtension: "momd")!
        let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: self.model, managedObjectModel: managedObjectModel!)
        container.loadPersistentStores { (storeDescription, error) in
            if let err = error{
                fatalError("Loading of store failed:\(err)")
            }
        }
        return container
    }()
   
    private func fetch() -> UXFRequest? {
        let fetchRequest = NSFetchRequest<UXFRequest>(entityName: "UXFRequest")
        let sort = NSSortDescriptor(key: "created", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchLimit = 1
        do{
            let request = try persistentContainer.viewContext.fetch(fetchRequest).first
            return request
        } catch {
            return nil
        }
    }
    
    private func createRequest(_ apiMethod: String, parameters: Data?) {
        let context = persistentContainer.viewContext
        
        if apiMethod == "GET_CAMPAIGNS" {
            let fetchRequest = NSFetchRequest<UXFRequest>(entityName: "UXFRequest")
            fetchRequest.predicate = NSPredicate(format: "apiMethod == %@", apiMethod)
            let numberOfRecords = (try? context.count(for: fetchRequest)) ?? 0
            if numberOfRecords > 0 {
                return
            }
        }
        
        let request = NSEntityDescription.insertNewObject(forEntityName: "UXFRequest", into: context) as! UXFRequest
        request.apiMethod = apiMethod
        request.created = Date()
        request.parametersData = parameters
        saveContext()
    }
    
    private func deleteRequest(_ request: UXFRequest, completion: (() -> ())? = nil ) {
        persistentContainer.viewContext.delete(request)
        saveContext(completion: completion)
    }
    
    
    private func saveContext(completion: (() -> ())? = nil ) {
        do {
            _ = try persistentContainer.viewContext.saveIfNeeded()
        } catch { }
        completion?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.prepareAndSend()
        }
    }
}
