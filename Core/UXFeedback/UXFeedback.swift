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
internal class UXFError : NSError {
    
    private var desc: String? = nil
    
    init(description: String?){
        super.init(domain: "uxfeedback", code: 0, userInfo: ["description": description ?? ""])
        self.desc = description
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

/// Основной интерфейс SDK. Для инициализации синглтона необходимо вызвать метод ``setup(appID:settings:campainDelegate:logDelegate:)``
@objcMembers
open class UXFeedback: NSObject {
    internal func DDLog(_ value: Any) {
        if settings.debugEnabled {
            print(value)
            if logDelegate != nil {
                logDelegate?.logDidReceive(message: value as! String)
            }
        }
    }
    
    /// Синглтон для работы с SDK
    public static let sdk: UXFeedback = UXFeedback.init()
    
    private static var isInitialized = false
    
    /// Текущая версия SDK
    public let version = Consts.version
    
    /// Делегат, реализующий интерфейс обработки событий
    open weak var campaignDelegate: UXFeedbackCampaignDelegate?
    
    /// Делегат, реализующий интерфейс обработки лога
    open weak var logDelegate: UXFeedbackLogDelegate?
    
    /// Объект настроек SDK
    open var settings: Settings = Settings()
    
    /// Объект темы SDK
    open var theme: Theme = Theme()
    
    /// Дополнительные параметры, которые будут переданы при завершении прохождения опроса
    open var properties: [String: Any] = [:]
    
    private var appId: String?
    
//    private var _theme: UXFBTheme!
    private var _appWindow: UIWindow!

    private var _requestManager: DataRequestManager!
    
    private var _campaigns: Array<Campaign> = []
    private var _eventToSend: String?
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
    
    private override init() {
        super.init()
        self.applyTheme()
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

    
    
    /// Метод инициализации и первичной настройки SDK
    /// - Parameters:
    ///   - appID: Идентификатор приложения
    ///   - settings: Объект настроек
    ///   - campaignDelegate: Делегат обработки событий SDK
    ///   - logDelegate: Делегат обработки логов SDK
    public static func setup(appID: String,
                             settings: Settings,
                             campaignDelegate: UXFeedbackCampaignDelegate? = nil,
                             logDelegate: UXFeedbackLogDelegate? = nil) {
        
        sdk.appId = appID
        sdk.settings = settings
        sdk.campaignDelegate = campaignDelegate
        sdk.logDelegate = logDelegate
        
        if UXFeedback.isInitialized {
            sdk.campaignDelegate?.campaignDidReceiveError(errorString: "SDK is already initialized")
        } else {
            sdk.DDLog("Init UXFeedbackSDK: \(sdk.version)")
            UXFeedback.isInitialized = true
        }
        
        var domain: String?
        
        if let endpoint = settings.endpoint {
            let eDomain = Crypto().decrypt(endpoint)
            domain = eDomain
        }
        
        sdk._requestManager = DataRequestManager(endpoint: domain,
                                            appID: appID,
                                            parser: sdk._parser,
                                            delegate: sdk)
        
        sdk._requestManager.settings = NetworkSettings(requestTimeout: settings.socketTimeout,
                                                          retryCount: settings.retryCount,
                                                          retryTimeout: settings.retryTimeout)
        
        sdk._requestManager.getAllCampaigns()
        
    }
        
    /// Метод показа кампании по указанному событию
    /// - Parameter eventName: Название события
    open func startCampaign(eventName: String) {
        DDLog("Attempt starting: \(eventName)")
        _eventToSend = eventName
        var eventFounded = false

        _campaigns.forEach { (campaign) in
            campaign.targetings.forEach({ (targeting) in
                if let type = targeting["type"] as? String, type == "trigger",
                   let name = targeting["value"] as? String, name == eventName {
                    eventFounded = true
                    let isMultiVisited = targeting["isMultiVisited"] as? Bool ?? false
                    
                    let counts = (targeting["counts"] as? Int) ?? 1
                    let newCount = (self.eventCounter[eventName] ?? 0) + 1
                    if newCount <= counts {
                        self.eventCounter[eventName] = newCount
                    }
                    if (self.eventCounter[eventName] ?? 1) != counts {
                        self.DDLog("Event count to show: \(counts)")
                        return
                    }
                    
                    if isMultiVisited {
                        self.eventCounter[eventName] = 0
                    }
                    _eventToSend = nil
                    self.task = DispatchWorkItem {
                        if !isMultiVisited {
                            guard self.checkGlobalDelay() else {
                                self.campaignDelegate?.campaignDidReceiveError(errorString: "Global timer")
                                return
                            }
                        }
                        
                        let formOnScreen = self._formPresentor?.isFormOnScreen ?? false
//                            self.delegate?.campaignDidReceiveError(errorString: "\(formOnScreen)")
                        guard !formOnScreen else {
                            self.DDLog("Form already on screen")
                            self.campaignDelegate?.campaignDidReceiveError(errorString: "Form is on screen")
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
                            if let color = self.settings.slideInUiBlackoutColor,
                                color.count == 6 {
                                blackout.color = UIColor.init("#\(color)")
                            }
                            
                            blackout.blur = self.settings.slideInUiBlackoutBlur ?? 0
                            blackout.opacity = self.settings.slideInUiBlackoutOpacity ?? 0
                            
                        case .popup:
                            if let color = self.settings.popupUiBlackoutColor,
                                color.count == 6 {
                                blackout.color = UIColor.init("#\(color)")
                            }
                            blackout.blur = self.settings.popupUiBlackoutBlur ?? 0
                            blackout.opacity = self.settings.popupUiBlackoutOpacity ?? 0
                            
                        case .none:
                            break
                        }
                        
                        self.DDLog("Show form for event: \(eventName)")
                        self._formPresentor?.showCampaign(uiBlocked: self.settings.slideInUiBlocked,
                                                          closeOnSwipe: self.settings.closeOnSwipe,
                                                          blackout: blackout)
                        
                        if !isMultiVisited {
                            self.saveShowingTime()
                        }
                        
                        self._requestManager.sendShowForm(campaignId: campaign.campaignId)
                        
                        self.eventCounter[eventName] = 0
                    }
                    
                    guard self.task != nil else {
                        return
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: (.now() + campaign.showDelay(eventName: eventName)), execute: self.task! )
                }
            })
        }
        if !eventFounded {
            DDLog("Event not found: \(eventName)")
        }
    }
    
    /// Метод отмены показа кампании. Если кампания уже показана - она будет закрыта
    open func stopCampaign() {
        self._formPresentor?.stopCampaign()
        if self.task != nil {
            self.task?.cancel()
            self.task = nil
        }
    }
}

extension UXFeedback: RequestManagerDelegate {
    func campaingsLoaded(success: Bool, message: String?, delay: Int?, campaigns: Array<UXFCampaign>) {
        self._campaigns = campaigns
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
            self._appWindow?.windowLevel = UXFeedback._windowLevel
//            completion?(success) 
            self.campaignDelegate?.campaignDidLoad(success: success)
        }
    }
    
    func formDataSaved(success: Bool, message: String?, capmaignId: String) {
        if success {
            self.campaignDelegate?.campaignDidSend(campaignId: capmaignId)
        }
    }
}

extension UXFeedback: CampaignFormPresentorProtocol {
    func formSubmitted(info: Array<Dictionary<String, Any>>?, screenshots: [Screenshot], campaign: Campaign) {
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
                                           answers: answers)
        
        _requestManager.sendFormData(projectId: campaign.projectId,
                                     campaignId: campaign.campaignId,
                                     pages: info,
                                     properties: properties)
        
        _requestManager.sendScreenshotsData(screenshots: screenshots)
    }
}
