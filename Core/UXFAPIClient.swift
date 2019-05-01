//
//  UXFAPIClient.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import Alamofire
import CodableAlamofire
import CocoaLumberjack

enum UFXAPIClientResponseResult{
    case success
    case fail
    case cancelled
}

let uxfErrorRequestCancelled = -999
let uxfTokenErrorMessage: String = "Invalid token".localized()

class UFXAPIClient{
    
    private var _appID: String!
    
    init(appID: String){
        DDLog.add(DDOSLogger.sharedInstance, with: DDLogLevel.debug)
        _appID = appID
  
        NotificationCenter.default.addObserver(self,selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func applicationDidBecomeActive(){
        self.getAllCampaings(completion: nil)
    }
    
    func getAllCampaings(completion: ((_ success: Bool, _ message: String?, _ theme: UXFTheme?, _ campaign: UXFCampaign?)->())?){
    
     DDLogDebug("Get all campaings:")
     //let systemInfo = UXFStatisticManager.getDeviceInfo()
     _ = self.performRequest(route: UXFAPIWebRouter.getCampaing(appID: _appID))
      {(status, message, result) in
        
        if status == .success {
            var theme: UXFTheme?
            var campaign: UXFCampaign?
            if let themeInfo =  result!["theme"] as? Dictionary<String, Any>{
                theme = UXFTheme.init(colorsDict: themeInfo["colors"] as! Dictionary<String, String>,
                                          smilesDict: themeInfo["smiles"] as! Dictionary<String, String>)
                

            }
            
            if let compaignInfo = result!["campaign"] as? Dictionary<String, Any>{
                
                var pages = Array<UXFPage>()
                if let pagesArrayOfDict = compaignInfo["pages"] as? Array<Dictionary<String, Any>> {
               
                    for pageDict in pagesArrayOfDict{
                        var fields: Array<UIView> = []
                        if let filedsInfoArr = pageDict["fields"] as? Array<Dictionary<String, Any>> {
                            for fieldInfo in  filedsInfoArr{
                                if let filed = UXFUIFabric.sharedInstance.parseUIElement(dictionary: fieldInfo){
                                   fields.append(filed)
                                }
                            }
                        }
                        var button: UXFButton?
                        if let buttonInfo = pageDict["button"] as? Dictionary<String, Any>{
                            button = UXFUIFabric.sharedInstance.parseUIElement(dictionary: buttonInfo) as? UXFButton
                        }
                        let page = UXFPage.init(_id: pageDict["_id"] as? String,
                                                button: button,
                                                fields: fields)
                        pages.append(page)
                    }
                }
                
                campaign = UXFCampaign.init(pages: pages,
                                            type: UXFCampaignType.init(rawValue:  compaignInfo["type"] as! String),
                                            showAttemptCount: 3,
                                            showDelay: 1.0)
            }
            
           DDLogDebug("Get all campaings successful")
           completion?(true, nil, theme, campaign)
        }
        else{
           DDLogDebug("Get all campaings failed")
           completion?(false, message, nil, nil)
        }
      }
        
        /*
        performObjectRequest(route: UXFAPIWebRouter.getCampaing(appID: _appID, campaingID: "5c908a553300006b006496d3"),
                             keyPath: "theme") { (theme: UXFTheme?) in
                                DDLogDebug(theme.debugDescription)
                                if let color = theme?.accentColor{
                                    DDLogDebug(color.hexString())
                                }
        }*/
    }
    
    //MARK: internal request
    
    internal func performRequest(route:UXFAPIWebRouter, completion:@escaping (UFXAPIClientResponseResult, String?, Dictionary<String, Any>?)->()) -> DataRequest?{
        
        /*let urlRequest = try? route.asURLRequest()
        if urlRequest != nil {
            if let httpBodyData = urlRequest!.httpBody {
                DDLogDebug(String.init(data: httpBodyData, encoding: String.Encoding.utf8) as Any)
            }
        }*/
        
        return Alamofire.request(route).responseJSON { response in
            
            //DDLogDebug("\(route.path) + \( response.value ?? "")")
            
            guard response.result.isSuccess else {
                if let error = response.result.error, error.code == uxfErrorRequestCancelled {
                    completion(.cancelled, nil, nil)
                }
                else {
                    completion(.fail, "Error in request \(String(describing: response.result.error))".localized(), nil)
                }
                return
            }
            
            guard let values = response.result.value as? [String: AnyObject] else {
                completion(.fail, "Error request result".localized(), nil)
                return
            }
            
            
           /* guard values["status"] as? String == "ok" else{
                
                
                if let code  = values["code"] as? String, let errorCode =  APIClientError(rawValue: code){
                    let message = (values["message"] as? String)!
                    if errorCode == APIClientError.refresh_token_expired || errorCode == APIClientError.unauthorized{
                        refreshToken(){ (success: Bool, message: String?) in
                            if success == true {
                                performRequest(route: route, completion: completion)
                            }
                            else{
                                completion(.success, message, nil)
                            }
                        }
                    }
                    else{
                        completion(.fail, message, nil)
                    }
                }
                else if let message = values["message"] as? String{
                    completion(.fail, message, nil)
                }
                else{
                    let message = values["error"] as? String
                    completion(.fail, message, nil)
                }
                return
            }*/
            
            if  let data = values["data"] as? [String: AnyObject], data.count > 0 {
                completion(.success, nil, data)
            }else{
                completion(.fail, "Response data is empty", nil)
            }
        }
    }
    
    internal func performObjectRequest<T:Decodable>(route: UXFAPIWebRouter,
                                                           keyPath: String? = nil,
                                                           decoder: JSONDecoder = JSONDecoder(),
                                                           completion:@escaping (T?)->Void) -> DataRequest?{
        /*let url = try? route.asURL()
         Alamofire.request(url!).responseDecodableObject(keyPath: keyPath, decoder: decoder) { (response: DataResponse<T>) in
         completion(response.result.value)
         }*/
        
        
        return performRequest(route: route){ (status: UFXAPIClientResponseResult, message: String?, result: Dictionary<String, Any>?) in
            
            if status == .success && result != nil {
                var dict: Dictionary = result!
                
                if keyPath != nil {
                    for subPath in keyPath!.components(separatedBy: ".") {
                        dict = dict[subPath] as! [String : Any]
                    }
                }
                
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                    let object = try? JSONDecoder().decode(T.self, from: jsonData)
                    completion(object)
                }catch{
                    completion(nil)
                }
            }
            else{
                completion(nil)
            }
        }
    }
    
    internal func performObjectArrayRequest<T:Decodable>(route: UXFAPIWebRouter,
                                                       keyPath: String? = nil,
                                                       decoder: JSONDecoder = JSONDecoder(),
                                                    completion: @escaping (Result<[T]>)->Void) -> DataRequest{
        let url = try? route.asURL()
        return Alamofire.request(url!).responseDecodableObject(keyPath: keyPath, decoder: decoder) { (response: DataResponse<[T]>) in
            completion(response.result)
        }
    }
    
    internal func downloadAttachment(url: URL, fileName: String, completion: ((_ destinationUrlPath: URL)->())?){
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent(fileName)
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(url, to: destination).responseData { response in
            if let destinationUrl = response.destinationURL {
                completion?(destinationUrl)
            }
        }
    }
}
