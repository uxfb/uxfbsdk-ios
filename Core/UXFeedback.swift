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
    static var theme: UXFTheme?
    static var _campaign: UXFCampaign?
    private static var _eventToSend: String?
    
    //Initialization SDK
    open class func setup(appID: String,
                          applicationWindow: UIWindow,
                          completion: ((_ success: Bool) -> Void)? = nil){
        
        _apiClient = UFXAPIClient.init(appID: appID)
        _apiClient.getAllCampaings { (success, message, aTheme, aCampaign) in
            theme = aTheme
            _campaign = aCampaign
            _appWindow = applicationWindow
        
            if _eventToSend != nil {
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
                showCampaingForm(campaignToShow: campaign)
            })
        }
    }
    
     private class func showCampaingForm(campaignToShow: UXFCampaign){
        let controller = UXFRateViewController.init()
        controller.modalPresentationStyle = .overCurrentContext
        controller._theme = theme
        controller.didCloseHandler = {
            
        }
        _appWindow.rootViewController?.present(controller, animated: animationEnabled, completion: nil)
    }
}
