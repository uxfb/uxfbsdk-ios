//
//  UFXURLComponents.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.

import Foundation

class URLComponents: NSObject{
    
    private var _baseUrl: String = ""
    private var _path: String = ""
    
    public var baseUrl: String{
        get{
            return _baseUrl
        }
    }
    
    public var path: String{
        get{
            return _path
        }
    }
    
    public var queryItems: [String: Any]? = [:]
    
    public var query: String{
        var result = ""
        if self.queryItems != nil {
            for option in  self.queryItems!{
                
                if let values = option.value as? Array<Any>{
                    if values.count > 0 {
                        for value in values {
                            if let valueInt = value as? Int {
                                result += (result.count > 0 ? "&" : "?") + option.key + "[]=\(valueInt)"
                            }
                            else if let valueString = getStringParam(text: (value as? String)), valueString.count > 0 {
                                result += (result.count > 0 ? "&" : "?") + option.key + "[]=\(valueString)"
                            }
                        }
                    }
                    else{
                        result += (result.count > 0 ? "&" : "?") + option.key + "[]=nil"
                    }
                   
                }
                else{
                  /*  if let valueInt = option.value as? Int {
                        result += (result.count > 0 ? "&" : "?") + option.key + "=\(valueInt)"
                    }*/
                    if let valueString = getStringParam(text: (option.value as? String)), valueString.count > 0 {
                      result += (result.count > 0 ? "&" : "?") + option.key + "=\(valueString)"
                    }
                    else{
                        result += (result.count > 0 ? "&" : "?") + option.key + "=\(option.value)"
                    }
                }
            }
        }
        return result
    }
    
    private func getStringParam(text: String?) -> String?{
        if text == nil{
            return nil
        }
        
        let words = text!.components(separatedBy: " ")
        if words.count == 1 {
            var result = ""
            for word in words{
                if result.count > 0 {
                    result += "+"
                }
                result.append(word.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
            }
            return result
        }
        else{
            return text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        }
    }
    
    public var url: URL?{
        get{
            let url = URL.init(string: self.baseUrl + self.path + self.query)
            return url
        }
    }
    
    init(baseUrl: String, path: String, queryParameters: [String: Any]? = nil) {
        super.init()
        
        _baseUrl = baseUrl
        _path = path
        self.queryItems = queryParameters
    }
    
}
