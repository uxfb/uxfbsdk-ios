//
//  UXFeedback.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit

@objcMembers
public class UXFError : NSError {
    
    private var desc: String? = nil
    
    init(description: String?){
        super.init(domain: "uxfeedback", code: 0, userInfo: ["description": description ?? ""])
        self.desc = description
    }


    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


@objcMembers
open class UXFeedback : NSObject{
    
    public static let sharedSDK = UXFeedback.init()
    
    open  var delegate: UXFeedbackCampaignDelegate?
    open  var debugEnabled: Bool = false
    open  var animationEnabled: Bool = true
    open var canDisplayCampaings: Bool = true
    open var isCampaignsLoaded: Bool {
        return _campaigns.count > 0
    }
    public static var isStage: Bool {
        return UXFAPIWebRouter.isStageAPI
    }
    
    open var uiBlocked: Bool = false
    open var closeOnSwipe: Bool = false
    
    private var _theme: UXFBTheme!
    private  weak var _activeEventController: UIViewController?
    private  var _appWindow: UIWindow!
    private  var _apiClient: UXFAPIClient!
    private var _campaigns: Array<UXFCampaign> = []
    private var _eventToSend: String?
    private var _resetAllCampaingHandler: (()->())?
    private var _resetAllCampaingNeeds: Bool = false
    private var _formPresentor: UXFCampaignPresentor?
    private var _parser: UXFParser!
    
    private var _campaignCancelled: Bool = false
    
    static private let _windowLevel = UIWindow.Level.alert + 10
    
    private var isInitTheme: Bool = false
    
    open var currentForm: UXFCampaignViewController?{
        return _formPresentor?._currentForm
    }
    
    override init() {
        super.init()
        self.setTheme(theme: UXFBTheme.init())
    }
    
    open func setTheme(theme: UXFBTheme){
        _theme = theme
        _parser = UXFParser.init(theme: theme, isInitTheme: isInitTheme)
    }
    
    //Initialization SDK
    @available(iOS 13.0, *)
    open func setup(appID: String,
                    windowScene: UIWindowScene,
                    theme: UXFBTheme? = nil,
                    completion: ((_ success: Bool) -> Void)? = nil){
        
        //let window = windowScene.windows.first
        DispatchQueue.main.async { [weak self] in
            let window = PassthroughWindow(windowScene: windowScene)
            window.rootViewController = UIViewController()
            window.windowLevel = UXFeedback._windowLevel
            self?.setup(appID: appID,
                       window: window,
                        theme: theme,
                   completion: completion)
        }
        
    }
    
    open func setup(appID: String,
                    theme: UXFBTheme? = nil,
                    completion: ((_ success: Bool) -> Void)? = nil){
        
        setup(appID: appID,
              window: nil,
              theme: theme,
              completion: completion)
    }
        
    open func setup(appID: String,
                    window: UIWindow?,
                    theme: UXFBTheme? = nil,
                    completion: ((_ success: Bool) -> Void)? = nil){
        
//        DDLogDebug(UXFAPIWebRouter.baseURL)
        
        if theme != nil {
            self.isInitTheme = true
            self.setTheme(theme: theme!)
        }

        _apiClient = UXFAPIClient.init(appID: appID, parser: self._parser)
        _apiClient.getAllCampaings { [weak self] (success, message, campaigns) in
            
            self?._campaigns = campaigns
            
            if success == true{
                self?.resetAllCampaigns()
//                if self?._resetAllCampaingNeeds == true {
//                    self?.resetAllCampaigns()
//                }
                if let event = self?._eventToSend {
                   self?.sendEvent(event: event)
                 }
            }
            
            if window == nil {
                DispatchQueue.main.async {
                    self?._appWindow = PassthroughWindow(frame: UIScreen.main.bounds)
                    self?._appWindow.rootViewController = UIViewController()
                    self?._appWindow?.windowLevel = UXFeedback._windowLevel
                    completion?(success)
                    self?.delegate?.campaignDidLoad(success: success)
                }
            }
            else{
                self?._appWindow = window
                completion?(success)
                DispatchQueue.main.async {
                   self?.delegate?.campaignDidLoad(success: success)
                }
            }
        }
    }
    
    //Request event to show campaing form with specific name
    
    open func sendEvent(event: String, fromController: UIViewController? = nil) {
        _eventToSend = event
        _campaignCancelled = false
        if self.canDisplayCampaings == true {
            _campaigns.forEach { (campaign) in
                campaign.targetings.forEach({ (targeting) in
                    if let type = targeting["type"] as? String, type == "trigger",
                       let name = targeting["value"] as? String, name == event {
                        let isMultiVisited = targeting["isMultiVisited"] as? Bool ?? false
                        if !campaign.show() && !isMultiVisited {
                            return
                        }
                        
                        _eventToSend = nil
                        
                        DispatchQueue.main.asyncAfter(deadline: (.now() + campaign.showDelay(eventName: event)), execute: { [unowned self] in
                            if self._campaignCancelled {
                                return
                            }
                            _ = self._formPresentor?.dismissCurrentForm(completion:  nil)
                            self._formPresentor = UXFCampaignPresentor(window: self._appWindow,
                                                                       campaign: campaign,
                                                                       animationEnabled: true)
                         
                            self._formPresentor?.isAnimationFormEnabled = self.animationEnabled
                            self._formPresentor?.delegate = self
                            self._formPresentor?.feedbackCampaignDelegate = self.delegate
                            self._formPresentor?.showCampaign(uiBlocked: uiBlocked, closeOnSwipe: closeOnSwipe)
                            self._apiClient.showForm(campaingId: campaign.campaignId)
                        })
                    }
                })
            }
        }
    }
    
    open func resetAllCampaignsData(completion: (()->())?){
        
        if _campaigns.count > 0 {
            self.resetAllCampaigns()
            completion?()
        }
        else{
            _resetAllCampaingNeeds = true
            _resetAllCampaingHandler = completion
        }
    }
    
    private func resetAllCampaigns(){
        _campaigns.forEach { (campaign) in
            var aCampaign = campaign
            aCampaign.removeUserData()
        }
        _resetAllCampaingNeeds = false
        _resetAllCampaingHandler?()
    }
    
    open func stopCampaign() {
        self._campaignCancelled = true
        self._formPresentor?.stopCampaign()
    }
}

extension UXFeedback: UXFCampaignFormPresentorProtocol {
    func formSubmitted(formIndex: Int, info: Array<Dictionary<String, Any>>?, campaign: UXFCampaign) {
        
        _apiClient.saveFormData(projectId: campaign.projectId,
                                campaignId: campaign.campaignId,
                                pages: info) { (success, message) in
            if success == false {
                DispatchQueue.main.async {
                    self.delegate?.campaignDidReceiveError(errorString: "Неизвестная ошибка при отправке данных формы")
                }
                
            }
        }
    }
}
