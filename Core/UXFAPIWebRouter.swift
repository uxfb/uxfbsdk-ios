//
//  UFXAPIWebRouter.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 12.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Alamofire

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
    case token = "token"
    case appID = "appId"
    case uid = "uid"
    case campaignId = "campaignId"
    case fields = "fields"
    case answerId = "answerId"
    case projectId = "projectId"
    case info = "info"
}

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}

enum ContentType: String {
    case json = "application/json"
}


enum UXFAPIWebRouter {
    
    static var baseURL: String {
        
        if UXFAPIWebRouter.isStageAPI == true{
            return "https://public-api-stage.uxfeedback.ru/v1"
        }
        else{
            return "https://public-api.uxfeedback.ru/v1"
        }
    }
    
    static internal var isStageAPI: Bool{
        
        return false
        
        #if DEBUG
          return true
        #else
        #if ADHOC
          return true
        #else
          return false
        #endif
        #endif
    }
    
    case getCampaing(appID: String)
    case saveFirstFormData(projectId: String?, uid: String, campaignId: String, fields: Dictionary <String, Any>?, info: Dictionary<String, Any>)
    case saveOtherFormData(projectId: String?, answerId: String?, fields: Dictionary <String, Any>?)
    case showForm(uid: String, campaingId: String)
    
    var method: HTTPMethod {
        switch self {

        case .saveFirstFormData, .showForm:
            return .post
        case .saveOtherFormData:
            return .put
            
        default:
            return .get
        }
    }
    
    var path: String {
       switch self {
         case .getCampaing(let appId):
              return "/mobile/campaigns/\(appId)"
         case .saveFirstFormData(_, _, _, _, _):
              return "/mobile/answers"
         case .saveOtherFormData(_, _, _):
              return "/mobile/answers"
         case .showForm(_, _):
              return "/mobile/visits"
        }
    }
    
    var parameters: Parameters? {
        switch self {
            
          case .saveFirstFormData(_ , let uid, let campaignId, let fields, let info):
             var params = [HTTPHeaderField.uid.rawValue : uid,
                    HTTPHeaderField.campaignId.rawValue : campaignId,
                    HTTPHeaderField.info.rawValue : info] as [String : Any]
             if fields != nil {
                params[HTTPHeaderField.fields.rawValue] = fields!
             }
            return params
            
          case .saveOtherFormData(_ , let answerId, let fields):
            var params: [String : Any] =  [:]
            if answerId != nil {
               params[HTTPHeaderField.answerId.rawValue] = answerId!
            }
          
            if fields != nil {
                params[HTTPHeaderField.fields.rawValue] = fields!
            }
            return params
            
          case .showForm(let uid, let campaingId):
             return  [HTTPHeaderField.uid.rawValue : uid,
                    HTTPHeaderField.campaignId.rawValue : campaingId]
          default:
            return [:]
         }
    }
    
    var pathParameters: Parameters?{
        
        var parameters: [String: Any] = [:]
        switch self {
        case .saveFirstFormData(let projectId, _, _, _, _):
            if projectId != nil {
               parameters =  [HTTPHeaderField.projectId.rawValue : projectId!]
            }
            break
        case .saveOtherFormData(let projectId, _, _):
            if projectId != nil {
                parameters =  [HTTPHeaderField.projectId.rawValue : projectId!]
            }
            break
        default:
            break
        }
  
        return parameters
    }
}

extension UXFAPIWebRouter: URLRequestConvertible{
    
    func asURLRequest() throws -> URLRequest {
        
        let url = try self.asURL()
        DDLogDebug(url.absoluteString)
       
        var urlRequest = URLRequest(url: url)

        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        /*if self.token != nil {
            urlRequest.setValue( self.appID!, forHTTPHeaderField: HTTPHeaderField.appID.rawValue)
        }*/
        
        // Parameters
        if let bodyParameters = parameters, bodyParameters.count > 0 {
            do {
                let data = try JSONSerialization.data(withJSONObject: bodyParameters, options: [])
                urlRequest.httpBody = data
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        
        return urlRequest
    }
    
    func asURL() throws -> URL{
        let urlComponents = UXFURLComponents(baseUrl: UXFAPIWebRouter.baseURL,
                                             path: path,
                                             queryParameters: pathParameters)
        return urlComponents.url!
    }
}
