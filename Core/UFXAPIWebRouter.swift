//
//  UFXAPIWebRouter.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 12.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Alamofire
import CocoaLumberjack

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
    case token = "token"
    case appID = "appID"
}

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}

enum ContentType: String {
    case json = "application/json"
}

enum UFXAPIWebRouter {
    
    static var baseURL: String {
        #if DEBUG
         return "https://pub-api.uxfeedback.ru/v1"
        #else
         return "https://pub-api.uxfeedback.ru/v1"
        #endif
    }
    
    case getCampaing(appID: String, campaingID: String)
    
    var method: HTTPMethod {
        switch self {
        /*
        case .login, .logout, .register, .refreshToken, .updateCompanyPreferences,
             .uploadAvatarMultipart, .ask, .viewMessage, .toggleFavorite, .offer:
            return .post
        */
            
        default:
            return .get
        }
    }
    
    var path: String {
       switch self {
       case .getCampaing(let appID, let campaingID):
            return "/forms/" + appID + "/campaigns/\(campaingID)"
        }
    }
    
    var parameters: Parameters? {
        switch self {
            
          default:
            return [:]
        }
    }
    
    var pathParameters: Parameters?{
        
        var parameters: [String: Any] = [:]
        switch self {
           //case .setup(let appID):
           // break
        default:
            break
        }
  
        return parameters
    }
}

extension UFXAPIWebRouter: URLRequestConvertible{
    
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
        let urlComponents = UXFURLComponents(baseUrl: UFXAPIWebRouter.baseURL,
                                             path: path,
                                             queryParameters: pathParameters)
        return urlComponents.url!
    }
}
