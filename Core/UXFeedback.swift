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

open class UXFeedback: NSObject{
    
    public static var delegate: UXFeedbackDelegate?
    public static var debugEnabled: Bool = false
    public static var animationEnabled: Bool = true
    
    private static weak var _activeEventController: UIViewController?
    private static weak var _appWindow: UIWindow!
    private static var _apiClient: UFXAPIClient!
    private static var _theme: UXFTheme?
    private static var _campaign: UXFCampaign?
    private static var _eventToSend: String?
    private static var _formPresentor: UXFCampaignFormPresentor?
    
    //Initialization SDK
    open class func setup(appID: String,
                          applicationWindow: UIWindow,
                          completion: ((_ success: Bool) -> Void)? = nil){
        
        _apiClient = UFXAPIClient.init(appID: appID)
        _apiClient.getAllCampaings { (success, message, aTheme, aCampaign) in
            _theme = aTheme
            _campaign = aCampaign
            _appWindow = applicationWindow
        
            if success == true, _eventToSend != nil {
                sendEvent(event: _eventToSend!)
            }
            
             completion?(success)
        }
    }
    
    //Requrst event to show campaing form with specific name
    open class func sendEvent(event: String, fromController: UIViewController? = nil){
        
        _eventToSend = event

        #warning("implement API call here")
        if let campaign = _campaign, campaign.show() == true{
            _eventToSend = nil
            DispatchQueue.main.asyncAfter(deadline: (.now() + campaign.showDelay), execute: {
                _formPresentor?.dismissForm()
                _formPresentor = UXFCampaignFormPresentor.init(window: self._appWindow, campaign:  campaign, theme: _theme)
                _formPresentor?.isAnimationFormEnabled = animationEnabled
                _formPresentor?.showForm()
            })
        }
    }
}
