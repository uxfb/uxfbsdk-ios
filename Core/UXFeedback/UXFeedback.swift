//
//  UXFeedback.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
//import UIKit

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
    open weak var campaignDelegate: FeedbackCampaignDelegate?
    
    /// Делегат, реализующий интерфейс обработки лога
    open weak var logDelegate: FeedbackLogDelegate?
    
    /// Объект настроек SDK
    open var settings: UXFBSettings = UXFBSettings()
    
    /// Объект темы SDK
    open var theme: UXFBTheme = UXFBTheme()
    
    /// Дополнительные параметры, которые будут переданы при завершении прохождения опроса
    open var properties: [String: Any] = [:]
    
    
    private var appId: String?
    
    //    private var _theme: UXFBTheme!
    private var _appWindow: UIWindow!
    
    private var _requestManager: DataRequestManager!
    
    private var _eventToSend: String?
    private var _resetAllCampaingHandler: (()->())?
    private var _resetAllCampaingNeeds: Bool = false
    private var _formPresentor: CampaignPresentor?
    private var _parser: Parser!
    
    internal var localProps: [Int: [String: Any]?] = [:]
    
    static private let _windowLevel = UIWindow.Level.alert + 10
    
    private var isInitTheme: Bool = false
    
    private var tasks: [String: DispatchWorkItem?] = [:]
    
    //    private var task: DispatchWorkItem?
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
    
    /// Метод инициализации и первичной настройки SDK
    /// - Parameters:
    ///   - appID: Идентификатор приложения
    ///   - settings: Объект настроек
    ///   - campaignDelegate: Делегат обработки событий SDK
    ///   - logDelegate: Делегат обработки логов SDK
    public static func setup(appID: String,
                             settings: UXFBSettings,
                             campaignDelegate: FeedbackCampaignDelegate? = nil,
                             logDelegate: FeedbackLogDelegate? = nil) {
        
        guard appID.count == 25 else {
            let appIdError = "AppId не задан. Укажите его корректное значение в методе UxFeedback.setup. Инициализация не выполнена"
            campaignDelegate?.campaignDidReceiveError(errorString: appIdError)
            return
        }
        
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
        
        sdk._appWindow = PassthroughWindow(frame: UIScreen.main.bounds)
        
        sdk._appWindow.rootViewController = UIViewController()
        sdk._appWindow?.windowLevel = UXFeedback._windowLevel
    }
    
    private func clearTask(eventName: String) {
        self.tasks[eventName]??.cancel()
        self.tasks[eventName] = nil
    }
    
    /// Метод показа кампании по указанному событию
    /// - Parameter eventName: Название события
    /// - Parameter attributes: Аттрибуты показа кампании
    @objc open func startCampaign(eventName: String, attributes: [Attribute]? = nil, localProps: [String: Any]? = nil) {
        guard (self._appWindow != nil) else {
            self.DDLog("Campaigns not loaded")
            return
        }
        
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
        
        //        guard task == nil else {
        //            DDLog("Same campaign already started")
        //            return
        //        }
        
        _eventToSend = eventName
        
        _requestManager.getCampaignCanditates(eventName: eventName) { candidates in
            self.DDLog("Find candidates: \(candidates?.count ?? 0)")
            guard let candidates = candidates, candidates.count > 0 else {
                self.campaignDelegate?.noCampaignToStart(eventName: eventName)
                self.DDLog("Event not found: \(eventName)")
                return
            }
            let sorted = candidates.sorted(by: { $0.priority < $1.priority })
            CampaignManager.findCampaignInCandidates(sorted,
                                                     appId: self.appId!,
                                                     requestManager: self._requestManager,
                                                     attributes: attributes) { campaign in
                if let campaign = campaign {
                    if self.tasks[eventName] != nil {
                        self.DDLog("Campaign already started")
                        return
                    }
                    
                    let isMultiVisited = campaign.targeting.isMultiVisited ?? false
                    
                    let counts = campaign.targeting.counts ?? 1
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
                    self.tasks[eventName] = DispatchWorkItem {
                        if !isMultiVisited {
                            guard self.checkGlobalDelay() else {
                                self.campaignDelegate?.campaignDidReceiveError(errorString: "Global timer")
                                self.clearTask(eventName: eventName)
                                return
                            }
                        }
                        
                        let formOnScreen = self._formPresentor?.isFormOnScreen ?? false
                        guard !formOnScreen else {
                            self.DDLog("Form already on screen")
                            self.campaignDelegate?.campaignDidReceiveError(errorString: "Form is on screen")
                            self.clearTask(eventName: eventName)
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
                        self.localProps[campaign.campaignId] = localProps
                        
                        
                        var properties = self.properties
                        
                        if let localProps = self.localProps[campaign.campaignId],
                           localProps != nil {
                            properties = properties.merging(localProps!) { current, _ in current }
                        }
                        
                        self._formPresentor?.showCampaign(uiBlocked: self.settings.slideInUiBlocked,
                                                          closeOnSwipe: self.settings.closeOnSwipe,
                                                          blackout: blackout,
                                                          rotateToggle: self.settings.rotateToggle,
                                                          properties: properties)
                        
                        if !isMultiVisited {
                            self.saveShowingTime()
                            self._requestManager.removeCampaign(campaignId: campaign.campaignId)
                        }
                        DispatchQueue.global(qos: .utility).async {
                            self._requestManager.sendShowForm(campaignId: campaign.campaignId)
                        }
                        
                        self.eventCounter[eventName] = 0
                        self.clearTask(eventName: eventName)
                    }
                    
                    guard self.tasks[eventName] != nil else {
                        return
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: (.now() + campaign.showDelay(eventName: eventName)), execute: self.tasks[eventName]!! )
                } else {
                    self.clearTask(eventName: eventName)
                    self.campaignDelegate?.campaignDidReceiveError(errorString: "Checking attributes failed")
                    self.DDLog("Checking attributes failed")
                }
            }
        }
    }
    
    /// Метод отмены показа кампании. Если кампания уже показана - она будет закрыта
    open func stopCampaign(eventForStop: String? = nil) {
        if let presentorEventName = self._formPresentor?._campaign.targeting.value,
           eventForStop == presentorEventName {
            self._formPresentor?.stopCampaign()
        }
        if let eventName = eventForStop,
           eventName.count > 0 {
            clearTask(eventName: eventName)
        } else {
            self.tasks.forEach { task in
                task.value?.cancel()
            }
            self.tasks = [:]
        }
    }
    
    /// Метод получения глобальных properties
    open func addGlobalProperty(key: String, value: Any) {
        properties[key] = value
    }
    
    /// Метод добавления глобального property
    open func removeGlobalProperty(key: String) {
        properties.removeValue(forKey: key)
    }
    /// Метод удаления глобального property
    open func clearGlobalProperties() {
        properties = [:]
    }
    /// Метод удаления всех глобальных properties
    open func getGlobalProperties() -> [String: Any] {
        return properties
    }
}

extension UXFeedback: RequestManagerDelegate {
    func campaingsLoaded(success: Bool, message: String?, delay: Int?, campaigns: Array<CampaignData>, state: String) {
        self._requestManager.setLastUpdate(state) { _ in }
        self._requestManager.setCampaigns(campaigns) { needsReload in
            if needsReload {
                self._requestManager.getAllCampaigns()
                return
            }
            
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
//                self._appWindow = PassthroughWindow(frame: UIScreen.main.bounds)
//                
//                self._appWindow.rootViewController = UIViewController()
//                self._appWindow?.windowLevel = UXFeedback._windowLevel
                self.campaignDelegate?.campaignDidLoad(success: success)
            }
        }
    }
    
    func formDataSaved(success: Bool, message: String?, campaignId: Int) {
        if success {
            self.campaignDelegate?.campaignDidSend(campaignId: campaignId)
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
        
        var props = properties
        if let localProps = self.localProps[campaign.campaignId],
           localProps != nil {
            props = props.merging(localProps!) { current, _ in current }
        }
        
        _requestManager.sendFormData(projectId: campaign.projectId,
                                     createdAtClient: StatisticManager.getTimeUTC(),
                                     campaignId: campaign.campaignId,
                                     pages: info,
                                     properties: props)
        
        _requestManager.sendScreenshotsData(screenshots: screenshots)
    }
}
