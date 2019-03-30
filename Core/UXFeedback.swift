//
//  UXFeedback.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit

public struct UXFError : Error {
    
    public let description: String
}

open class UXFeedback{
    
    public static var delegate: UXFeedbackDelegate?
    public static var debugEnabled: Bool = false
    public static var animationEnabled: Bool = true
    
    private static weak var _appWindow: UIWindow?
    private static var _apiClient: UFXAPIClient!
    static var theme: UXFTheme?
    static var campaign: UXFCampaign?
    
    //Initialization SDK
    open class func setup(appID: String,
                          applicationWindow: UIWindow?,
                          completion: ((_ success: Bool) -> Void)? = nil){
        
        _apiClient = UFXAPIClient.init(appID: appID)
        _apiClient.getAllCampaings { (success, message, aTheme, aCampaign) in
            theme = aTheme
            campaign = aCampaign
            _appWindow = applicationWindow
            completion?(success)
        }
    }
    
    //Requrst event to show campaing form with specific name
    open class func sendEvent(event: String){
        
        if let theme = UXFeedback.theme {
            let controller = UXFRateViewController.init()
            controller._theme = theme
            _appWindow?.rootViewController?.present(controller, animated: animationEnabled, completion: nil)
        }
    }
}
