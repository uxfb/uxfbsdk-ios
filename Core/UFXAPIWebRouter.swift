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
    case appID = "appID"
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
    
    private var  appID: String?{
        return ""
    }
    
    case getCampaing(campaingID: String)
    
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
       case .getCampaing(let campaingID):
            if let appIdentificator = self.appID {
               return "/forms/" + appIdentificator + "/campaings/\(campaingID)"
           }
            else{
                return ""
            }
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
        /*
        if self.appID != nil {
          parameters["appID"] = self.appID
        }*/
  
        return parameters
    }
}

extension UFXAPIWebRouter: URLRequestConvertible{
    
    func asURLRequest() throws -> URLRequest {
        
        let url = try self.asURL()
        #if DEBUG
        print(url)
        #endif
        var urlRequest = URLRequest(url: url)

        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        if self.appID != nil {
            urlRequest.setValue( self.appID!, forHTTPHeaderField: HTTPHeaderField.appID.rawValue)
        }
        
        // Parameters
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
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
