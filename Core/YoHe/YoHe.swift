//
//  YoHe.swift
//
//  Created by Alexander Potemka on 21.06.2023.
//  Copyright © 2023 UXF. All rights reserved.
//

import Foundation
import UIKit

/// Main SDK interface. To initialize a singleton, call the ``setup(appID:settings:campainDelegate:logDelegate:)`` method
@objcMembers
open class YoHe: NSObject {
    internal func DDLog(_ value: Any) {
        if settings.debugEnabled {
            print(value)
            if logDelegate != nil {
                logDelegate?.logDidReceive(message: value as! String)
            }
        }
    }
    
    /// Singleton for working with the SDK
    public static let sdk: YoHe = YoHe.init()
    
    private static var isInitialized = false
    
    /// Current SDK version
    public let version = Consts.version
    
    /// Delegate that implements the event handling interface
    open weak var campaignDelegate: YoHeCampaignDelegate?
    
    /// Delegate that implements the log processing interface
    open weak var logDelegate: YoHeLogDelegate?
    
    /// SDK settings object
    open var settings: YoHeSettings = YoHeSettings()
    
    /// SDK theme object
    open var theme: YoHeTheme = YoHeTheme()
    
    /// Additional parameters that will be passed when the poll is completed
    open var properties: [String: Any] = [:] {
        didSet { properties = properties.lowercasedKeys() }
    }
    
    private var appId: String?
    
    private var _appWindow: UIWindow!
    
    private var _requestManager: DataRequestManager!
    
    private var _campaignData: Array<CampaignData> = []
    private var _eventToSend: String?
    private var _attributes: [Attribute]?
    private var _resetAllCampaingHandler: (()->())?
    private var _resetAllCampaingNeeds: Bool = false
    private var _formPresentor: CampaignPresentor?
    private var _parser: Parser!
    
    static private let _windowLevel = UIWindow.Level.alert + 10
    
    private var isInitTheme: Bool = false
    
    private var task: DispatchWorkItem?
    private var eventCounter: [String: Int] = [:]
    
    private var currentForm: CampaignViewController?{
        return _formPresentor?._currentForm
    }
    
    private var isAppActive: Bool = true
    
    private override init() {
      super.init()
      self.applyTheme()
      NotificationCenter.default.addObserver(self,selector: #selector(applicationDidBecomeActive),
                                             name: UIApplication.didBecomeActiveNotification, object: nil)
      NotificationCenter.default.addObserver(self,selector: #selector(applicationDidEnterBackground),
                                             name: UIApplication.didEnterBackgroundNotification, object: nil)
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self,selector: #selector(applicationDidBecomeActive),
                                                   name: UIScene.didActivateNotification, object: nil)
            NotificationCenter.default.addObserver(self,selector: #selector(applicationDidEnterBackground),
                                                   name: UIScene.didEnterBackgroundNotification, object: nil)
        }
    }
    
    deinit {
      NotificationCenter.default.removeObserver(self,
                                                name: UIApplication.didBecomeActiveNotification,
                                                object: nil)
      NotificationCenter.default.removeObserver(self,
                                                name: UIApplication.didEnterBackgroundNotification,
                                                object: nil)
        if #available(iOS 13.0, *) {
            NotificationCenter.default.removeObserver(self,
                                                      name: UIScene.didActivateNotification,
                                                      object: nil)
            NotificationCenter.default.removeObserver(self,
                                                      name: UIScene.didEnterBackgroundNotification,
                                                      object: nil)
        }
    }
    
    @objc private func applicationDidBecomeActive(){
      isAppActive = true
    }
    
    @objc private func applicationDidEnterBackground(){
      isAppActive = false
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
                if interval >= self.settings.globalDelayTimer {
                    return true
                } else {
                    self.DDLog("Global timer error: delay=\(self.settings.globalDelayTimer ), current=\(interval)")
                    return false
                }
            }
        }
        return true
    }
    
    private func applyTheme() {
        _parser = Parser.init(theme: theme, isInitTheme: isInitTheme)
        _formPresentor?._currentForm?.tableView.reloadData()
    }
    
    private func applySettings() {
        
    }
    
    
    
    /// SDK initialization and initial setup method
    /// - Parameters:
    /// - appID: App ID
    /// - settings: Settings object
    /// - campaignDelegate: SDK event handling delegate
    /// - logDelegate: Delegate for handling SDK logs
    public static func setup(appID: String,
                             settings: YoHeSettings,
                             campaignDelegate: YoHeCampaignDelegate? = nil,
                             logDelegate: YoHeLogDelegate? = nil) {
        
        // Validate appID
        guard !appID.isEmpty, !appID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            campaignDelegate?.campaignDidReceiveError(errorString: "Invalid appID: appID cannot be empty")
            return
        }
        
        sdk.appId = appID
        sdk.settings = settings
        sdk.campaignDelegate = campaignDelegate
        sdk.logDelegate = logDelegate
        
        if YoHe.isInitialized {
            sdk.campaignDelegate?.campaignDidReceiveError(errorString: "SDK is already initialized")
        } else {
            sdk.DDLog("Init YoHeSDK: \(sdk.version)")
            YoHe.isInitialized = true
        }
        
        var domain: String?
        
        if let endpoint = settings.endpoint {
            let eDomain = Crypto().decrypt(endpoint)
            domain = eDomain
        }
        
        sdk._requestManager = DataRequestManager(endpoint: domain,
                                                 appID: appID,
                                                 parser: sdk._parser,
                                                 sdkSettings: settings,
                                                 delegate: sdk)
        
        sdk._requestManager.settings = NetworkSettings(requestTimeout: settings.socketTimeout,
                                                       retryCount: settings.retryCount,
                                                       retryTimeout: settings.retryTimeout)
        
        sdk._requestManager.checkToggles { toggleStatus in
          if toggleStatus {
            self.sdk.campaignDelegate?.campaignDidReceiveError(errorString: "Toggle status = true")
          } else {
            self.sdk._requestManager.getAllCampaigns()
          }
        }
    }
    
    private func clearTask() {
      self.task?.cancel()
      self.task = nil
    }
    
    /// Campaign display method for the specified event
    /// - Parameter eventName: Event name
    open func startCampaign(eventName: String, attributes: [Attribute]? = nil) {
        var attributesString: [String] = []
        
        if let attributes = attributes {
            for attribute in attributes {
                let name = attribute.attributeName
                var value = attribute.attributeValue
                if let date = value as? Date {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
                    value = formatter.string(from: date)
                }
                
                attributesString.append("name: \(name), value: \(value ?? "")")
            }
        }
        DDLog("Attempt starting: \(eventName)\nAttributes: \(attributesString)")
      
      guard task == nil else {
        DDLog("Some campaign already started")
        return
      }
      
      _eventToSend = eventName
      _attributes = attributes
      
      var targeting: Targeting? = nil
      
      if let campaignData = _campaignData.first(where: { campaignData in
          if let campaign = campaignData.campaign, campaign.targeting.value == eventName {
              targeting = campaign.targeting
              return true
          }
          return false
      }), let targeting = targeting, let campaign = campaignData.campaign {
          AttributeManager.checkAttributes(appId: self.appId!,
                                           requestManager: self._requestManager,
                                           campaignCandidate: campaignData,
                                           targeting: targeting,
                                           attributes: attributes ?? []) { result in
          if result {
            let isMultiVisited = targeting.isMultiVisited ?? false
            
            let counts = targeting.counts ?? 1
            let newCount = (self.eventCounter[eventName] ?? 0) + 1
            if newCount <= counts {
              self.eventCounter[eventName] = newCount
            }
            if (self.eventCounter[eventName] ?? 1) != counts {
              self.DDLog("Event count to show: \(counts - newCount)")
              return
            }
            
            if isMultiVisited {
              self.eventCounter[eventName] = 0
            }
            self._eventToSend = nil
            self.task = DispatchWorkItem {
              if !isMultiVisited {
                guard self.checkGlobalDelay() else {
                  self.campaignDelegate?.campaignDidReceiveError(errorString: "Global timer")
                  self.clearTask()
                  return
                }
              }
              
              let formOnScreen = self._formPresentor?.isFormOnScreen ?? false
              guard !formOnScreen else {
                self.DDLog("Form already on screen")
                self.campaignDelegate?.campaignDidReceiveError(errorString: "Form is on screen")
                self.clearTask()
                return
              }
              
              _ = self._formPresentor?.dismissCurrentForm(completion:  nil)
              
              var mCampaign = campaign
              mCampaign.updateTheme(theme: self.theme)
              self._formPresentor = CampaignPresentor(window: self._appWindow,
                                                      campaign: mCampaign,
                                                      animationEnabled: true)
              
              self._formPresentor?.isAnimationFormEnabled = true
              self._formPresentor?.delegate = self
              self._formPresentor?.feedbackCampaignDelegate = self.campaignDelegate
              let blackout = Blackout()
              //
              switch campaign.type {
                case .slidein:
                  
                  if let color = self.settings.slideInUiBlackoutColor {
                    if color.count == 6 {
                      blackout.color = UIColor.init("#\(color)")
                    } else if color.count == 7 {
                      blackout.color = UIColor.init(color)
                    }
                  }
                  
                  blackout.blur = self.settings.slideInUiBlackoutBlur
                  blackout.opacity = self.settings.slideInUiBlackoutOpacity
                  
                case .popup:
                  if let color = self.settings.popupUiBlackoutColor {
                    if color.count == 6 {
                      blackout.color = UIColor.init("#\(color)")
                    } else if color.count == 7 {
                      blackout.color = UIColor.init(color)
                    }
                  }
                  blackout.blur = self.settings.popupUiBlackoutBlur
                  blackout.opacity = self.settings.popupUiBlackoutOpacity
                  
                case .none:
                  break
              }
              
              guard self.isAppActive else {
                self.stopCampaign()
                self.DDLog("App hasn't active state")
                return
              }
              
              self.DDLog("Show form for event: \(eventName)")
              self._formPresentor?.showCampaign(uiBlocked: self.settings.slideInUiBlocked,
                                                closeOnSwipe: self.settings.closeOnSwipe,
                                                blackout: blackout,
                                                rotateToggle: self.settings.rotateToggle,
                                                properties: self.properties,
                                                invocationId: "")
              
              if !isMultiVisited {
                self.saveShowingTime()
                self._campaignData.removeAll { campaignData in
                  campaignData.campaignId == campaign.campaignId
                }
              }
              DispatchQueue.global(qos: .utility).async {
                self._requestManager.sendShowForm(campaignId: campaign.campaignId)
              }
              
              self.eventCounter[eventName] = 0
              self.clearTask()
            }
            
            guard self.task != nil else {
              return
            }
            
            DispatchQueue.main.asyncAfter(deadline: (.now() + campaign.showDelay(eventName: eventName)), execute: self.task! )
          } else {
            self.clearTask()
            self.campaignDelegate?.campaignDidReceiveError(errorString: "Attributes checking failed")
          }
        }
      } else {
        self.clearTask()
        DDLog("Event not found: \(eventName)")
      }
    }
    
    /// Campaign cancellation method. If the campaign is already shown, it will be closed
    open func stopCampaign() {
        self._formPresentor?.stopCampaign()
        if self.task != nil {
            self.task?.cancel()
            self.task = nil
        }
    }
}

extension YoHe: RequestManagerDelegate {
    func campaingsLoaded(success: Bool, message: String?, delay: Int?, campaigns: Array<CampaignData>, state: String) {
        self._campaignData = campaigns
        self.settings.globalDelayTimer = delay ?? self.settings.globalDelayTimer
        if success == true {
            self.DDLog("Campaigns loaded: \(campaigns.count)")
            if let event = self._eventToSend {
                self.startCampaign(eventName: event)
            }
        } else {
            self.DDLog("\(message ?? "Unresolved message")")
            self.DDLog("Campaigns NOT loaded, server error")
        }
        
        DispatchQueue.main.async {
            self._appWindow = PassthroughWindow(frame: UIScreen.main.bounds)
            self._appWindow.rootViewController = UIViewController()
            self._appWindow?.windowLevel = YoHe._windowLevel
            //            completion?(success)
            self.campaignDelegate?.campaignDidLoad(success: success)
        }
    }
    
    func formDataSaved(success: Bool, message: String?, campaignId: Int, invocationId: String) {
        if success {
            self.campaignDelegate?.campaignDidSend(campaignId: campaignId, invocationId: invocationId)
        }
    }
}

extension YoHe: CampaignFormPresentorProtocol {
    func formSubmitted(info: Array<Dictionary<String, Any>>?, screenshots: [Screenshot], campaign: Campaign, invocationId: String) {
        self.DDLog("Campaign finished")
        
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
        }
        
        self.campaignDelegate?.campaignDidAnswered(campaignId: campaign.campaignId,
                                                   answers: answers,
                                                   invocationId: invocationId)
        
        _requestManager.sendFormData(projectId: campaign.projectId,
                                     createdAtClient: StatisticManager.getTimeUTC(),
                                     campaignId: campaign.campaignId,
                                     invocationId: invocationId,
                                     pages: info,
                                     properties: properties)
        
        _requestManager.sendScreenshotsData(screenshots: screenshots)
    }
}
