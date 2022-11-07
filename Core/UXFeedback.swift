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
    internal func DDLog(_ value: Any) {
        if _debugEnabled {
            print(value)
            
            if delegate != nil {
                delegate?.logDidReceive(message: value as! String)
            }
        }
    }

    public static let sharedSDK = UXFeedback.init()
    
    
    private static var isInitialized = false
    public let sdkVersion = "v1.5.0"
    
    open weak var delegate: UXFeedbackCampaignDelegate?
    open var animationEnabled: Bool = true
    open var isCampaignsLoaded: Bool {
        return _campaigns.count > 0
    }
    
    open var uiBlocked: Bool = false
    open var closeOnSwipe: Bool = false
    
    open var globalDelayTimer : Int?
    
    open var canDisplayCampaings: Bool = true
    
    private var _debugEnabled: Bool = false
    
    private var appId: String?
    
    private var _theme: UXFBTheme!
    private  weak var _activeEventController: UIViewController?
    private var _appWindow: UIWindow!
    private  var _apiClient: UXFAPIClient!
    private var _campaigns: Array<UXFCampaign> = []
    private var _eventToSend: String?
    private var _resetAllCampaingHandler: (()->())?
    private var _resetAllCampaingNeeds: Bool = false
    private var _formPresentor: UXFCampaignPresentor?
    private var _parser: UXFParser!
    
    static private let _windowLevel = UIWindow.Level.alert + 10
    
    private var isInitTheme: Bool = false
    
    private var slideinBlackout: UXFBBlackout?
    private var fullscreenBlackout: UXFBBlackout?
    
    private var task: DispatchWorkItem?
    private var eventCounter: [String: Int] = [:]
    
    private var _properties: [String: Any] = [:]
    
    open var currentForm: UXFCampaignViewController?{
        return _formPresentor?._currentForm
    }
    
    private override init() {
        super.init()
        self.setTheme(theme: UXFBTheme.init())
    }
    
    private func saveShowingTime() {
        if let appId = self.appId {
            UserDefaults.standard.set(Date(), forKey: appId)
        }
    }
    
    private func checkGlobalDelay() -> Bool {
        if let appId = self.appId {
            if let date = UserDefaults.standard.object(forKey: appId) as? Date {
                let interval = Int(Date().timeIntervalSince(date))
                if interval >= self.globalDelayTimer ?? 1800 {
                    return true
                } else {
                    self.DDLog("Global timer error: delay=\(self.globalDelayTimer ?? 1800), current=\(interval)")
                    return false
                }
            }
        }
        return true
    }
    
    open func setDebugEnabled(_ enabled: Bool) {
        _debugEnabled = enabled
    }
    
    open func setProperties(_ properties: [String: Any]) {
        _properties = properties
    }
    
    open func setTheme(theme: UXFBTheme) {
        _theme = theme
        _parser = UXFParser.init(theme: _theme, isInitTheme: isInitTheme)
        _formPresentor?._currentForm?.tableView.reloadData()
    }
    
//    private func setEndpoint(endpoint: String) {
//        self.endpoint = endpoint
//        self._apiClient._endpoint = endpoint
//    }
    
    open func setSlideinBlackout(color: String, opactity: Int, blur: Int) {
        if uiBlocked {
            setBlackout(type: .slidein, color: color, opactity: opactity, blur: blur)
        }
    }
    
    open func setFullscreenBlackout(color: String, opactity: Int, blur: Int) {
        setBlackout(type: .popup,color: color, opactity: opactity, blur: blur)
    }
    
    private func setBlackout(type: UXFCampaignType, color: String, opactity: Int, blur: Int) {
        var blackoutColor: UIColor = .clear
        if color.count == 6 {
            blackoutColor = UIColor.init("#\(color)")
        } else if color.count == 7 {
            blackoutColor = UIColor.init(color)
        }
        switch type {
        case .slidein:
            self.slideinBlackout = UXFBBlackout(color: blackoutColor, opacity: opactity, blur: blur)
            break
        case .popup:
            self.fullscreenBlackout = UXFBBlackout(color: blackoutColor, opacity: opactity, blur: blur)
            break
        }
        
    }
    
    //Initialization SDK
    @available(iOS 13.0, *)
    open func setup(endpoint: String? = nil,
                    appID: String,
                    windowScene: UIWindowScene,
                    theme: UXFBTheme? = nil,
                    completion: ((_ success: Bool) -> Void)? = nil){
        
        //let window = windowScene.windows.first
        DispatchQueue.main.async { [weak self] in
            let window = PassthroughWindow(windowScene: windowScene)
            window.rootViewController = UIViewController()
            window.windowLevel = UXFeedback._windowLevel
            self?.setup(endpoint: endpoint,
                        appID: appID,
                       window: window,
                        theme: theme,
                   completion: completion)
        }
        
    }
    
    open func setup(endpoint: String? = nil,
                    appID: String,
                    theme: UXFBTheme? = nil,
                    completion: ((_ success: Bool) -> Void)? = nil) {
        
        setup(endpoint: endpoint,
              appID: appID,
              window: nil,
              theme: theme,
              completion: completion)
    }
        
    open func setup(endpoint: String? = nil,
                    appID: String,
                    window: UIWindow?,
                    theme: UXFBTheme? = nil,
                    completion: ((_ success: Bool) -> Void)? = nil) {
        
        if UXFeedback.isInitialized {
            self.delegate?.campaignDidReceiveError(errorString: "SDK is already initialized")
        } else {
            DDLog("Init UXFeedbackSDK: \(sdkVersion)")
            UXFeedback.isInitialized = true
        }
        self.appId = appID
        
        if theme != nil {
            self.isInitTheme = true
            self.setTheme(theme: theme!)
        }
        
        var domain: String?
        
        if let endpoint = endpoint {
            let eDomain = UXFCrypto().decrypt(endpoint)
            domain = eDomain
        }
        
        _apiClient = UXFAPIClient.init(endpoint: domain, appID: appID, parser: self._parser)
        _apiClient.getAllCampaings { [weak self] (success, message, delay, campaigns)  in
            self?._campaigns = campaigns.sorted(by: { cam1, cam2 in
                Int(cam1.campaignId) ?? 0 < Int(cam2.campaignId) ?? 0
            })
            self?.globalDelayTimer = delay
            if success == true {
                self?.DDLog("Campaigns loaded: \(campaigns.count)")
                self?.resetAllCampaigns()
                if let event = self?._eventToSend {
                   self?.sendEvent(event: event)
                 }
            } else {
                self?.DDLog("\(message ?? "Unresolved message")")
                self?.DDLog("Campaigns NOT loaded, server error")
            }
            
            DispatchQueue.main.async {
                self?._appWindow = PassthroughWindow(frame: UIScreen.main.bounds)
                self?._appWindow.rootViewController = UIViewController()
                self?._appWindow?.windowLevel = UXFeedback._windowLevel
                completion?(success)
                self?.delegate?.campaignDidLoad(success: success)
            }
        }
    }
    
    //Request event to show campaing form with specific name
    
    open func sendEvent(event: String, fromController: UIViewController? = nil) {
        DDLog("Attempt starting: \(event)")
        _eventToSend = event
        var eventFounded = false
        if self.canDisplayCampaings == true {
            _campaigns.forEach { (campaign) in
                campaign.targetings.forEach({ (targeting) in
                    if let type = targeting["type"] as? String, type == "trigger",
                       let name = targeting["value"] as? String, name == event {
                        eventFounded = true
                        let isMultiVisited = targeting["isMultiVisited"] as? Bool ?? false
                        
                        let counts = (targeting["counts"] as? Int) ?? 1
                        let newCount = (self.eventCounter[event] ?? 0) + 1
                        if newCount <= counts {
                            self.eventCounter[event] = newCount
                        }
                        if (self.eventCounter[event] ?? 1) != counts {
                            self.DDLog("Event count to show: \(counts)")
                            return
                        }
                        
                        if isMultiVisited {
                            self.eventCounter[event] = 0
                        }
                        _eventToSend = nil
                        self.task = DispatchWorkItem {
                            if !isMultiVisited {
                                guard self.checkGlobalDelay() else {
                                    self.delegate?.campaignDidReceiveError(errorString: "Global timer")
                                    return
                                }
                            }
                            
                            let formOnScreen = self._formPresentor?.isFormOnScreen ?? false
//                            self.delegate?.campaignDidReceiveError(errorString: "\(formOnScreen)")
                            guard !formOnScreen else {
                                self.DDLog("Form already on screen")
                                self.delegate?.campaignDidReceiveError(errorString: "Form is on screen")
                                return
                            }
                            
                            _ = self._formPresentor?.dismissCurrentForm(completion:  nil)

                            
                            var mCampaign = campaign
                            mCampaign.updateTheme(theme: self._theme)
                            self._formPresentor = UXFCampaignPresentor(window: self._appWindow,
                                                                       campaign: mCampaign,
                                                                       animationEnabled: true)
                         
                            self._formPresentor?.isAnimationFormEnabled = self.animationEnabled
                            self._formPresentor?.delegate = self
                            self._formPresentor?.feedbackCampaignDelegate = self.delegate
                            var blackout: UXFBBlackout?
                            switch campaign.type {
                            case .slidein:
                                blackout = self.slideinBlackout
                                
                            case .popup:
                                blackout = self.fullscreenBlackout
                                
                            case .none:
                                break
                            }
                            if self.canDisplayCampaings {
                                self.DDLog("Show form for event: \(event)")
                                self._formPresentor?.showCampaign(uiBlocked: self.uiBlocked, closeOnSwipe: self.closeOnSwipe, blackout: blackout)
                                
                                if !isMultiVisited {
                                    self.saveShowingTime()
                                }
                                
                                self._apiClient.showForm(campaingId: campaign.campaignId)
                                self.eventCounter[event] = 0
                            } else {
                                self.DDLog("canDisplayCampaigns: \(self.canDisplayCampaings)")
                            }
                        }
                        
                        guard self.task != nil else {
                            return
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: (.now() + campaign.showDelay(eventName: event)), execute: self.task! )
                    }
                })
            }
            if !eventFounded {
                DDLog("Event not found: \(event)")
            }
        } else {
            DDLog("canDisplayCampaigns: \(canDisplayCampaings)")
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
        self._formPresentor?.stopCampaign()
        if self.task != nil {
            self.task?.cancel()
            self.task = nil
        }
    }
}

extension UXFeedback: UXFCampaignFormPresentorProtocol {
    func formSubmitted(info: Array<Dictionary<String, Any>>?, screenshots: [UXFScreenshot], campaign: UXFCampaign) {
        
        self.DDLog("Campaign finished")
        _apiClient.saveFormData(projectId: campaign.projectId,
                                campaignId: campaign.campaignId,
                                pages: info,
                                properties: _properties) { (success, message) in
        }
        
        var answers: [String: Any] = [:]
        if let info = info {
            for item in info {
                if let fields = item["fields"] as? [[String: Any]] {
                    for field in fields {
                        if let fieldId = field["fieldId"] as? String, let value = field["value"] {
                            answers[fieldId] = value
                        }
                    }
                }
            }
            
            self.delegate?.campaignDidSend(campaignId: campaign.campaignId,
                                           answers: answers)
        }
        
        _apiClient.saveScreenshotsData(screenshots)
    }
}
