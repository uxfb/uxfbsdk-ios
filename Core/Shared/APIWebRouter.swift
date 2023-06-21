//
//  UFXAPIWebRouter.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 12.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation.NSURLRequest
import UniformTypeIdentifiers

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
    case uid = "uid"
    case appID = "appId"
    case campaignId = "campaignId"
    case fields = "fields"
    case pages = "pages"
    case answerId = "answerId"
    case projectId = "projectId"
    case info = "info"
    case properties = "properties"
    case screenshots = "screenshots"
    case sdkVersion = "X-SDK-Version"
}

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}

enum ContentType: String {
    case json = "application/json"
    case screenshot = "multipart/form-data; boundary=-----------------------------0123456789"
}

enum APIWebRouter {
    static let defaultEndpoint: String = Consts.defaultEndpoint
    
    static var endpoint: String = "\(defaultEndpoint)/\(Consts.apiVersion)"
    
    case getCampaing(appID: String)
    case showForm(uid: String, campaingId: String)
    case saveFormData(projectId: String?, uid: String, campaignId: String, pages: Array<Dictionary<String, Any>>, info: Dictionary<String, Any>, properties: Dictionary<String, Any>)
    case saveScreenshot(screenshot: ScreenshotData)
    
    var method: String {
        switch self {

        case .showForm, .saveFormData, .saveScreenshot:
            return "POST"
            
        default:
            return "GET"
        }
    }
    
    var path: String {
       switch self {
       case .getCampaing(let appId):
            return "/mobile/campaigns/\(appId)"
       case .saveFormData(_, _, _, _, _, _):
            return "/mobile/answers"
       case .showForm(_, _):
            return "/mobile/visits"
       case .saveScreenshot(_ ):
           return "/mobile/screenshots"
        }
    }
    
    var parameters: [String:Any]? {
        switch self {
            case .saveFormData(_, let uid, let campaignId, let pages, let info, let properties):
                var params = [HTTPHeaderField.uid.rawValue : uid,
                       HTTPHeaderField.campaignId.rawValue : campaignId,
                       HTTPHeaderField.info.rawValue : info] as [String : Any]

                params[HTTPHeaderField.pages.rawValue] = pages
                params[HTTPHeaderField.properties.rawValue] = properties
//                params[HTTPHeaderField.screenshots.rawValue] = screenshots

                return params

            case .showForm(let uid, let campaingId):
                return  [HTTPHeaderField.uid.rawValue : uid,
                    HTTPHeaderField.campaignId.rawValue : campaingId]
            
            default:
                return [:]
        }
    }
    
    var body: Data? {
        switch self {
        case .getCampaing, .showForm, .saveFormData:
            if let bodyParameters = parameters, bodyParameters.count > 0 {
                do {
                    let data = try JSONSerialization.data(withJSONObject: bodyParameters, options: [])
                    return data
                } catch {
                    return nil
                }
            }
            return nil
            
        case .saveScreenshot(let screenshot):
//            let boundary = "Boundary-\(NSUUID().uuidString)"
            let boundary = "-----------------------------0123456789"
            let lineBreak = "\r\n"
            let mimetype = "image/webp"

            var httpBody = Data()
            httpBody.append("--\(boundary)" + lineBreak)
            httpBody.append("Content-Disposition:form-data; name=\"screenshot\";filename=\"\(screenshot.id)\"" + lineBreak)
            httpBody.append("Content-Type: \(mimetype)" + lineBreak + lineBreak)
            
            if let imageData = Data(base64Encoded: screenshot.base64image, options: Data.Base64DecodingOptions(rawValue: 0)),
               let image = UIImage(data: imageData) {
                    let encoder = YYImageEncoder(type: .webP)
                    encoder?.quality = 1
                    encoder?.add(image, duration: 0)
                    if let data = encoder?.encode() {
                        httpBody.append(data)
                    }
            }

            httpBody.append(lineBreak)
            httpBody.append("--\(boundary)--" + lineBreak)
            
            return httpBody
        }
    }
    
    var pathParameters: [String:Any]? {
        var parameters: [String: Any] = [:]
        switch self {
        case .saveFormData(let projectId, _, _, _, _, _):
            if projectId != nil {
                parameters =  [HTTPHeaderField.projectId.rawValue : projectId!]
            }
            break
            
        case .getCampaing(_):
            parameters = [HTTPHeaderField.uid.rawValue: uid]
            break
            
        default:
            break
        }
  
        return parameters
    }
    
    var headers: [String: String]? {
        switch self {
        case .getCampaing, .showForm, .saveFormData:
            return [HTTPHeaderField.acceptType.rawValue: ContentType.json.rawValue,
                    HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
                    HTTPHeaderField.sdkVersion.rawValue: UXFeedback.sdk.version]
            
            
        case .saveScreenshot:
            return [HTTPHeaderField.contentType.rawValue: ContentType.screenshot.rawValue,
                    HTTPHeaderField.sdkVersion.rawValue: UXFeedback.sdk.version]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try self.asURL()
        DDLogDebug(url.absoluteString)
       
        var urlRequest = URLRequest(url: url)

        // HTTP Method
        urlRequest.httpMethod = method
        
        // Common Headers
        urlRequest.allHTTPHeaderFields = headers
        
        if let httpBody = body {
            urlRequest.httpBody = httpBody
        }
        
        return urlRequest
    }
    
    func asURL() throws -> URL{
        let urlComponents = URLComponents(baseUrl: APIWebRouter.endpoint,
                                             path: path,
                                             queryParameters: pathParameters)
        return urlComponents.url!
    }
}
