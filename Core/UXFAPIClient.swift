//
//  UXFAPIClient.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import AVFoundation

enum UXFAPIClientResponseResult{
    case success
    case fail
    case cancelled
}



internal func DDLogDebug(_ value: Any){
    #if DEBUG
    print(value)
    #endif
}

let uxfErrorRequestCancelled = -999
let uxfTokenErrorMessage: String = "Invalid token".localized()

class UXFAPIClient{
    
    private(set) var appID: String!
    private var _parser: UXFParser!
    public var _endpoint: UXFEndpoint!
    
    init(endpoint: UXFEndpoint, appID: String, parser: UXFParser){
        _parser = parser
        self.appID = appID
        self._endpoint = endpoint
        
        NotificationCenter.default.addObserver(self,selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func applicationDidBecomeActive(){
        //self.getAllCampaings(completion: nil)
    }
    
    func getAllCampaings(completion: ((_ success: Bool, _ message: String?, _ intervalIos: Int?, _ campaigns: Array<UXFCampaign>)->())?){
    
     DDLogDebug("Get all campaings:")
     
     _ = self.performRequest(route: UXFAPIWebRouter.getCampaing(appID: self.appID))
      {[weak self] (status, message, result) in
        
        if status == .success {
            if let campaignsResults = result as? Array<Dictionary<String, Any>> {
                var campaigns: Array<UXFCampaign> = []
                for compaignInfo in campaignsResults{
                    if let campaign =  self?._parser.parseCampaign(campaignInfo: compaignInfo){
                       campaigns.append(campaign)
                    }
                }
                
                DDLogDebug("Get all campaings successful")
                completion?(true, nil, nil, campaigns)
            }
            else if let results = result as? Dictionary<String, Any> {
                if let campaignsResults = results["campaigns"] as? Array<Dictionary<String, Any>> {
                    var campaigns: Array<UXFCampaign> = []
                    for compaignInfo in campaignsResults{
                        if let campaign =  self?._parser.parseCampaign(campaignInfo: compaignInfo){
                           campaigns.append(campaign)
                        }
                    }
                    
                    let delay = results["showCampaignsIntervalIos"] as? Int
                    DDLogDebug("Get all campaings successful")
                    completion?(true, nil, delay, campaigns)
                } else {
                    DDLogDebug("No campaings detected")
                    completion?(false, "No campaings detected", nil, [])
                }
            }
            else {
                DDLogDebug("No campaings detected")
                completion?(false, "No campaings detected", nil, [])
            }
        }
        else{
           DDLogDebug("Get all campaings failed")
           completion?(false, message, nil, [])
        }
      }
    }
    
    func saveFormData(projectId: String?,
                      campaignId: String,
                      pages: Array<Dictionary<String,Any>>?,
                      properties: Dictionary<String,Any>?,
                      screenshots: [String],
                      completion: ((_ success: Bool, _ message: String?)->())?){
        
        let responseHandler = {(status: UXFAPIClientResponseResult, message: String?, result: Any?) in
            DDLogDebug(String(describing: result))
        }
        
        let systemInfo = UXFStatisticManager.getDeviceInfo()
        
        _ = self.performRequest(route: UXFAPIWebRouter.saveFormData(projectId: projectId,
                                                                    uid: UIDevice.current.identifierForVendor?.uuidString ?? "",
                                                                    campaignId: campaignId,
                                                                    pages: pages ?? [], info: systemInfo, properties: properties ?? [:], screenshots: screenshots), completion: responseHandler)
    }
    
    func  showForm(campaingId: String){
        _ = performRequest(route: UXFAPIWebRouter.showForm(uid: UIDevice.current.identifierForVendor?.uuidString ?? "",
                                                    campaingId: campaingId))
        {(status, message, result) in
            DDLogDebug(String(describing: result))
        }
    }
    
    func saveScreenshotsData(_ screenshots: [UXFScreenshot]) {
        for screenshot in screenshots {
            _ = performRequest(route: UXFAPIWebRouter.saveScreenshot(screenshot: screenshot), completion: { status, message, result in
                DDLogDebug(String(describing: result))
            })
        }
    }
    
    //MARK: internal request
    
    internal func performRequest(route: UXFAPIWebRouter, completion:@escaping (UXFAPIClientResponseResult, String?, Any?)->()) -> URLSessionDataTask?{
        
        UXFAPIWebRouter.endpoint = self._endpoint
        
        guard let urlRequest = try? route.asURLRequest() else{
             completion(.fail, "Error url request", nil)
             return nil
        }
        
        #if DEBUG
        if let httpBodyData = urlRequest.httpBody {
            DDLogDebug(String.init(data: httpBodyData, encoding: String.Encoding.utf8) as Any)
        }
        #endif
       
        let task = URLSession.shared.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
    
            do {
                guard let data = data,
                    let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode,
                    error == nil else {
                        DDLogDebug("httpCode= \((response as? HTTPURLResponse)?.statusCode ?? 0), response=\(String(decoding: data ?? Data(), as: UTF8.self))")
                        throw error ?? UXFError.init(description: "Request error")
                }
                
                DDLogDebug("httpCode= \(response.statusCode)")
                
                if error != nil{
                    if error!.code == uxfErrorRequestCancelled{
                        completion(.cancelled, nil, nil)
                    }
                    else {
                       completion(.fail, "Error in request \(String(describing: error!))".localized(), nil)
                    }
                }
                else{
                    if let values =  try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? Dictionary<String,Any>{
                        if  let result = values["data"] {
                            completion(.success, nil, result)
                        }else{
                            completion(.fail, "Response data is empty", nil)
                        }
                    }else{
                        completion(.fail, "Response data error", nil)
                    }
                }
            } catch {
                DDLogDebug("Request failed with error: \(error.localizedDescription)")
                completion(.fail,error.localizedDescription, nil)
            }
        }
        
        task.resume()
        return task
    }
}
