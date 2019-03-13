//
//  UXFeedback.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation

public struct UXFError : Error {
    
    public let description: String
}

open class UXFeedback{
    
    public static var delegate: UXFeedbackDelegate?
    public static var debugEnabled: Bool = false
    
    open class func setup(appID: String?, completion: (() -> Void)? = nil){
        
    }
    
    open class func sendEvent(event: String){
        
    }
}
