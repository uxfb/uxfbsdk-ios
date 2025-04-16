//
//  UXFAPIClient.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

enum APIClientResponseResult{
    case success
    case fail
    case cancelled
}

internal func DDLogDebug(_ value: Any){
#if DEBUG
    //    print(value)
#endif
}

let uxfErrorRequestCancelled = -999
let uxfTokenErrorMessage: String = "Invalid token".localized()

@objcMembers
internal class ApiError : NSError {
    
    private var desc: String? = nil
    
    init(description: String?){
        super.init(domain: "uxfeedback", code: 0, userInfo: ["description": description ?? ""])
        self.desc = description
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class APIClient {
    private(set) var appID: String!
    private var _parser: Parser!
    private var _endpoint: String
    private var _settings: SettingsProtocol
    
    private var _version: String = Consts.apiVersion
    
    public var timeout: Int = 5
    
    init(endpoint: String?, appID: String, parser: Parser, settings: SettingsProtocol) {
        _parser = parser
        self.appID = appID
        self._settings = settings
        if let endpoint = endpoint {
            self._endpoint = endpoint
        } else {
            self._endpoint = APIWebRouter.defaultEndpoint
        }
        
        NotificationCenter.default.addObserver(self,selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func applicationDidBecomeActive(){
        //self.getAllCampaings(completion: nil)
    }
    
    func checkToggle(completion: ((_ toggleStatus: Bool?)->())?) {
        DDLogDebug("Check toggles:")
        
        _ = self.performRequest(route: APIWebRouter.checkToggle(appID: self.appID))
        { (status, httpCode, message, result) in
            if status == .success,
               let result = result as? Dictionary<String, Any>  {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                    let decoder = JSONDecoder()
                    let checkValue = try decoder.decode(ToggleStatus.self, from: jsonData)
                    completion?(checkValue.togglesStatus)
                } catch {
                    DDLogDebug("Check toggle failed")
                    completion?(false)
                }
            } else {
                DDLogDebug("Check toggle failed")
                completion?(false)
            }
        }
    }
    
    func getAllCampaings(completion: ((_ success: Bool,
                                       _ httpCode: Int,
                                       _ message: String?,
                                       _ intervalIos: Int?,
                                       _ campaigns: Array<Campaign>)->())?) {
        
        DDLogDebug("Get all campaings:")
        
        _ = self.performRequest(route: APIWebRouter.getCampaing(appID: self.appID))
        { [weak self] (status, httpCode, message, result) in
            if status == .success {
                if let results = result as? Dictionary<String, Any> {
                    if let campaignsResults = results["campaigns"] as? Array<Dictionary<String, Any>> {
                        var campaigns: Array<Campaign> = []
                        var copyright: Copyright? = nil
                        if let copyrightInfo = results["copyright"] as? Dictionary<String, Any> {
                            copyright = self?._parser.parseCopyright(copyrightInfo: copyrightInfo)
                        }
                        
                        var textProperties: TextProperties? = nil
                        if let textPropertiesInfo = results["textProperties"] as? Dictionary<String, Any> {
                            textProperties = self?._parser.parseTextProperties(textPropertiesInfo: textPropertiesInfo)
                        }
                        
                        for compaignInfo in campaignsResults {
                            if let campaign =  self?._parser.parseCampaign(campaignInfo: compaignInfo,
                                                                           copyright: copyright,
                                                                           textProperties: textProperties) {
                                campaigns.append(campaign)
                                if campaign.campaignId == "21" {
                                    
                                }
                            }
                        }
                        
                        let delay = results["showCampaignsInterval"] as? Int
                        DDLogDebug("Get all campaings successful")
                        completion?(true, httpCode, nil, delay, campaigns)
                    } else {
                        DDLogDebug("No campaings detected")
                        completion?(false, httpCode, "No campaings detected", nil, [])
                    }
                } else {
                    DDLogDebug("No campaings detected")
                    completion?(false, httpCode, "No campaings detected", nil, [])
                }
            }
            else{
                DDLogDebug("Get all campaings failed")
                completion?(false, httpCode, message, nil, [])
            }
        }
    }
    
    func saveFormData(projectId: String?,
                      createdAtClient: String,
                      campaignId: String,
                      pages: Array<Dictionary<String,Any>>?,
                      properties: Dictionary<String,Any>?,
                      idempotency: String,
                      completion: ((_ success: Bool, _ httpCode: Int, _ message: String?)->())?){
        
        let responseHandler = {(status: APIClientResponseResult, httpCode: Int, message: String?, result: Any?) in
            DDLogDebug(String(describing: result))
            completion?(status == .success, httpCode, message)
        }
        
        let systemInfo = StatisticManager.getDeviceInfo()
        
        
        _ = self.performRequest(route: APIWebRouter.saveFormData(projectId: projectId,
                                                                 createdAtClient: createdAtClient,
                                                                 uid: uid,
                                                                 campaignId: campaignId,
                                                                 pages: pages ?? [], info: systemInfo,
                                                                 properties: properties ?? [:],
                                                                 idempotency: idempotency),
                                completion: responseHandler)
    }
    
    func showForm(campaingId: String,
                  completion: ((_ success: Bool, _ httpCode: Int)->())?){
        
        let responseHandler = {(status: APIClientResponseResult, httpCode: Int, message: String?, result: Any?) in
            DDLogDebug(String(describing: result))
            completion?(status == .success, httpCode)
        }
        
        _ = performRequest(route: APIWebRouter.showForm(uid: uid,
                                                        campaingId: campaingId),
                           completion: responseHandler)
    }
    
    func saveScreenshotsData(_ screenshot: ScreenshotData,
                             completion: ((_ success: Bool, _ httpCode: Int)->())?){
        let responseHandler = {(status: APIClientResponseResult, httpCode: Int, message: String?, result: Any?) in
            DDLogDebug(String(describing: result))
            completion?(status == .success, httpCode)
        }
        
        _ = performRequest(route: APIWebRouter.saveScreenshot(screenshot: screenshot),
                           completion: responseHandler)
    }
    
    func checkAttribues(_ appId: String,
                        _ campaignId: String,
                        _ attributes: [Attribute],
                        _ debug: Bool,
                        completion: ((_ success: Bool)->())?){
        let responseHandler = {(status: APIClientResponseResult, httpCode: Int, message: String?, result: Any?) in
            if status == .success,
               let result = result as? Dictionary<String, Any>  {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                    let decoder = JSONDecoder()
                    let checkValue = try decoder.decode(CheckAttribute.self, from: jsonData)
                    completion?(checkValue.checkAttributes)
                } catch {
                    DDLogDebug("Check attributes failed")
                    completion?(false)
                }
            } else {
                DDLogDebug("Check attributes failed")
                completion?(false)
            }
        }
        
        _ = performRequest(route: APIWebRouter.checkAttribute(appID: appId,
                                                              campaignID: campaignId,
                                                              attributes: attributes,
                                                              debug: debug),
                           completion: responseHandler)
    }
    
    //MARK: internal request
    
    internal func performRequest(route: APIWebRouter, completion: @escaping (APIClientResponseResult, Int, String?, Any?)->()) -> URLSessionDataTask?{
        
        APIWebRouter.endpoint = "\(self._endpoint)/\(_version)"
        APIWebRouter.settings = _settings
        
        guard var urlRequest = try? route.asURLRequest() else{
            completion(.fail, 0, "Error url request", nil)
            return nil
        }
        
        urlRequest.timeoutInterval = TimeInterval(timeout)
        
#if DEBUG
        if let httpBodyData = urlRequest.httpBody {
            let str = String.init(data: httpBodyData, encoding: String.Encoding.utf8) as Any
            DDLogDebug(str)
        }
#endif
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            
            do {
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      error == nil else {
                    DDLogDebug("httpCode= \((response as? HTTPURLResponse)?.statusCode ?? 0), response=\(String(decoding: data ?? Data(), as: UTF8.self))")
                    throw error ?? ApiError.init(description: "Request error")
                }
                
                let httpCode = response.statusCode
                
                DDLogDebug("httpCode= \(response.statusCode)")
                
                if error != nil{
                    if error!.code == uxfErrorRequestCancelled{
                        completion(.cancelled, httpCode, nil, nil)
                    }
                    else {
                        completion(.fail, httpCode, "Error in request \(String(describing: error!))".localized(), nil)
                    }
                }
                else{
                    if let values =  try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? Dictionary<String,Any>{
                        if let result = values["data"] {
                            completion(.success, httpCode, nil, result)
                        } else if values["campaigns"] != nil {
                            completion(.success, httpCode, nil, values)
                        } else if values.count > 0 {
                            completion(.success, httpCode, nil, values)
                        } else {
                            completion(.fail, httpCode, "Response data is empty", nil)
                        }
                    }else{
                        completion(.fail, httpCode, "Response data error", nil)
                    }
                }
            } catch {
                DDLogDebug("Request failed with error: \(error.localizedDescription)")
                completion(.fail, 0, error.localizedDescription, nil)
            }
        }
        
        task.resume()
        return task
    }
}
