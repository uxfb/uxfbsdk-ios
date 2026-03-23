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
    func campaingsLoaded(success: Bool, message: String?, delay: Int?, campaigns: Array<CampaignData>, state: String)
    func formDataSaved(success: Bool, message: String?, campaignId: Int, invocationId: String)
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
    
    private var _parser: Parser!
    
    private var delegate: RequestManagerDelegate?
    
    var settings: NetworkSettings!
    
    private var attempts = 0
    
    init(endpoint: String?,
         appID: String,
         parser: Parser,
         sdkSettings: SettingsProtocol,
         delegate: RequestManagerDelegate?) {
        super.init()
        context = persistentContainer.newBackgroundContext()
        
        self._apiClient = APIClient(endpoint: endpoint,
                                    appID: appID,
                                    parser: parser,
                                    settings: sdkSettings)
        self.delegate = delegate
        self._parser = parser
        settings = NetworkSettings(requestTimeout: 5,
                                   retryCount: 3,
                                   retryTimeout: 10)
        self.prepareAndSend()
    }
    
    //MARK: - Public methods
    
    public func removeCampaign(campaignId: Int) {
        context.performAndWait {
            let request = NSFetchRequest<DataCampaign>(entityName: "DataCampaign")
            request.predicate = NSPredicate(format: "id == %d", campaignId)
            
            if let record = try? self.context.fetch(request).first  {
                context.delete(record)
                try? context.save()
            }
        }
    }
    
    public func getAllCampaigns() {
        createRequest("GET_CAMPAIGNS", parameters: nil)
    }
    
    public func sendFormData(projectId: String?,
                             createdAtClient: String,
                             campaignId: Int,
                             pages: Array<Dictionary<String,Any>>?,
                             properties: Dictionary<String,Any>?) {
        
        
        let uuid: String = UUID().uuidString
        
        let parameters = ["projectId": projectId as Any,
                          "createdAtClient": createdAtClient as Any,
                          "campaignId": campaignId,
                          "pages": pages as Any,
                          "properties": properties as Any,
                          "idempotency": uuid] as [String : Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        
        createRequest("SEND_FORM", parameters: jsonData)
    }
    
    public func sendShowForm(campaignId: Int) {
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
    
    public func sendAttributes(appId: String, campaignId: Int, attributes: [Attribute], completion: @escaping (Bool) -> Void) {
        self._apiClient.checkAttribues(appId, campaignId, attributes, false) { success in
            completion(success)
        }
    }
    
    public func checkToggles(completion: @escaping (Bool) -> Void) {
        self._apiClient.checkToggle { toggleStatus in
            completion(toggleStatus ?? true)
        }
    }
    
    private func clearLastUpdate(completion: @escaping (Bool) -> Void) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DataCampaignLastUpdate")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(batchDeleteRequest)
                completion(true)
            } catch {
                completion(false)
            }
    }
    
    public func getLastUpdate(completion: @escaping (String) -> Void) {
        context.perform {
            var result = ""
            do {
                let fetchRequest = NSFetchRequest<DataCampaignLastUpdate>(entityName: "DataCampaignLastUpdate")
                let fetchResult = try self.context.fetch(fetchRequest)
                result = fetchResult.first?.stateHeader ?? ""
            } catch { }
            
            completion(result)
        }
    }
    
    public func setLastUpdate(_ value: String, completion: @escaping (Bool) -> Void) {
        clearLastUpdate { success in
            if success {
                self.context.performAndWait {
                    do {
                        let request = NSEntityDescription.insertNewObject(forEntityName: "DataCampaignLastUpdate", into: self.context) as! DataCampaignLastUpdate
                        request.stateHeader = value
                        try self.context.save()
                        
                        completion(true)
                    } catch {
                        completion(false)
                    }
                }
            } else {
                self.context.performAndWait {
                    let fetchRequest: NSFetchRequest<DataCampaignLastUpdate> = DataCampaignLastUpdate.fetchRequest()
                    
                    do {
                        let allRecords = try self.context.fetch(fetchRequest)
                        for record in allRecords {
                            record.stateHeader = value
                        }
                        try self.context.save()
                        completion(true)
                    } catch {
                        completion(false)
                    }
                }
            }
        }
    }
    
    public func getCampaignCanditates(eventName: String, completion: @escaping ([CampaignData]?) -> Void) {
        context.perform {
            let fetchRequest = NSFetchRequest<DataCampaign>(entityName: "DataCampaign")
            let records = try? self.context.fetch(fetchRequest)
            
            var fullData: [CampaignData] = []
            records?.forEach { record in
                var fullItem = CampaignData(campaignId: record.id, priority: record.priority)
                
                if let jsonData = record.data as Data?,
                   let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
                   var jsonDict = jsonObject as? [String: Any] {
                    
                    var copyright: Copyright?
                    if let copyrightData = record.copyright as Data?,
                       let jsonObject = try? JSONSerialization.jsonObject(with: copyrightData, options: []),
                       let jsonDict = jsonObject as? [String: Any],
                       let copyrightValue = self._parser.parseCopyright(copyrightInfo: jsonDict) {
                        copyright = copyrightValue
                    }
                    
                    var textProperties: TextProperties?
                    if let textPropertiesData = record.textProperties as Data?,
                       let jsonObject = try? JSONSerialization.jsonObject(with: textPropertiesData, options: []),
                       let jsonDict = jsonObject as? [String: Any],
                       let textPropertiesValue = self._parser.parseTextProperties(textPropertiesInfo: jsonDict) {
                        textProperties = textPropertiesValue
                    }
                    
                    if jsonDict["campaignId"] == nil {
                        jsonDict["campaignId"] = record.id
                    }
                    
                   let campaign = self._parser.parseCampaign(campaignInfo: jsonDict,
                                                         copyright: copyright,
                                                        textProperties: textProperties)
                    
                    fullItem.campaign = campaign
                    fullData.append(fullItem)
                }
            }
            if fullData.count == 0 {
                completion(nil)
            } else {
                let filtered = fullData.filter {
                    if let value = $0.campaign?.targeting.value {
                        return value == eventName
                    }
                    return false
                }
                
                if filtered.count > 0 {
                    completion(filtered)
                } else {
                    completion(nil)
                }
                
            }
        }
    }
    
    public func setCampaigns(_ campaigns: [CampaignData], completion: @escaping (Bool) -> Void) {
        
        var ids = campaigns.map { $0.campaignId }
        var needsReload: Bool = false
        
        context.performAndWait {
            let fetchRequest = NSFetchRequest<DataCampaign>(entityName: "DataCampaign")
            let records = try? self.context.fetch(fetchRequest)
            
            campaigns.forEach { campaign in
                if let record = records?.first(where: { record in
                    record.id == campaign.campaignId
                }) {
                    if let data = campaign.data {
                        record.data = data
                    }
                    
                    if let copyright = campaign.copyright {
                        record.copyright = copyright
                    }
                    
                    if let textProperties = campaign.textProperties {
                        record.textProperties = textProperties
                    }
                    record.priority = campaign.priority
                    
                    try? context.save()
                } else {
                    if campaign.data == nil {
                        needsReload = true
                        return
                    } else {
                        let request = NSEntityDescription.insertNewObject(forEntityName: "DataCampaign", into: self.context) as! DataCampaign
                        request.id = campaign.campaignId
                        request.priority = campaign.priority
                        request.data = campaign.data
                        request.copyright = campaign.copyright
                        request.textProperties = campaign.textProperties
                        try? context.save()
                    }
                }
            }
            
            if needsReload {
                ids = []
                setLastUpdate("") { success in }
            }
            
            let deleteRequest = NSFetchRequest<DataCampaign>(entityName: "DataCampaign")
            let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
            deleteRequest.predicate = predicate
            if let records = try? self.context.fetch(deleteRequest)  {
                for record in records {
                    context.delete(record)
                }
                
                try? context.save()
            }
        }
        
        completion(needsReload)
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
        } else if httpCode == 410 || attempts >= settings.retryCount { //423 also
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
                getLastUpdate { state in
                    self._apiClient.getAllCampaings(state: state) { [weak self] (success, httpCode, message, delay, campaigns, state)  in
                        self?.validateResponse(for: request, success: success, httpCode: httpCode) {
                            self?.delegate?.campaingsLoaded(success: success, message: message, delay: delay, campaigns: campaigns, state: state)
                        }
                    }
                }
                
                
            case "SEND_FORM":
                guard let data = data,
                      let dict = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                      let projectId = dict["projectId"] as? String,
                      let createdAtClient = dict["createdAtClient"] as? String,
                      let campaignId = dict["campaignId"] as? Int,
                      let pages = dict["pages"] as? Array<Dictionary<String,Any>>,
                      let properties = dict["properties"] as? Dictionary<String,Any>
                else {
                    self.deleteRequest(request, completion: { })
                    return
                }
                let idempotency = dict["idempotency"] as? String ?? ""
                self._apiClient.saveFormData(projectId: projectId,
                                             createdAtClient: createdAtClient,
                                             campaignId: campaignId,
                                             pages: pages,
                                             properties: properties,
                                             idempotency: idempotency) { (success, httpCode, message) in
                    self.validateResponse(for: request, success: success, httpCode: httpCode) {
                        self.delegate?.formDataSaved(success: success,
                                                     message: message,
                                                     campaignId: campaignId,
                                                     invocationId: <#String#>)
                    }
                }
                
            case "SHOW_FORM":
                guard let data = data,
                      let dict = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                      let campaignId = dict["campaignId"] as? Int
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
        let sdkBundle = Bundle(identifier: Consts.identifier)
        let modelURL = sdkBundle!.url(forResource: self.model, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: self.model,
                                              managedObjectModel: managedObjectModel!)
        
        let storeURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent("\(model).sqlite")
        
        let storeDirectory = storeURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(
            at: storeDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        let description = NSPersistentStoreDescription(url: storeURL)
        description.type = NSSQLiteStoreType
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    private var context: NSManagedObjectContext!
    
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
            //            request.time = settings.requestTimeout
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
