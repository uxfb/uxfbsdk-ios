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
  open var properties: [String: Any] = [:] {
    didSet {
      
    }
  }
  
  private var appId: String?
  
  //    private var _theme: UXFBTheme!
  private var _appWindow: UIWindow!
  
  private var _requestManager: DataRequestManager!
  
  private var _campaigns: Array<Campaign> = []
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
    NotificationCenter.default.addObserver(self,selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self,selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
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
      sdk.DDLog(appIdError)
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
  }
  
  private func checkAttibutes(campaignId: String, targeting: Targeting, attributes: [Attribute], completion: @escaping (Bool) -> Void) {
    guard let campaignAttributes = targeting.attributes, campaignAttributes.count > 0  else {
      completion(true)
      return
    }
    
    var checkAttributes: [Attribute] = []
    for campaignAttribute in campaignAttributes {
      if let attribute = attributes.first(where: { att in
        att.attributeName == campaignAttribute.attributeName
      }) {
        switch campaignAttribute.rule {
          case "equal":
            if let string = campaignAttribute.value?.getString(),
               let appAttribute = attribute.attributeValue as? String{
              if appAttribute != string {
                completion(false)
                return
              }
            } else {
              completion(false)
              return
            }
            
          case "contain":
            if let string = campaignAttribute.value?.getString(),
               let appAttribute = attribute.attributeValue as? String{
              if !appAttribute.contains(string) {
                completion(false)
                return
              }
            } else {
              completion(false)
              return
            }
            
          case "dateRange":
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            var minDate = dateFormatter.date(from: "1900-01-01")
            var maxDate = dateFormatter.date(from: "2099-01-01")
            
            let valueDate = attribute.attributeValue as? Date
            let minString = campaignAttribute.valueFrom?.getString()
            let maxString = campaignAttribute.valueTo?.getString()
            
            if (minString != nil || maxString != nil) && valueDate != nil {
              minDate = dateFormatter.date(from: minString ?? "1900-01-01")!
              maxDate = dateFormatter.date(from: maxString ?? "2099-01-01")!
              
              if (valueDate!.compare(maxDate!) == .orderedAscending || valueDate!.compare(maxDate!) == .orderedSame),
                 (valueDate!.compare(minDate!) == .orderedDescending ||
                  valueDate!.compare(minDate!) == .orderedSame) {
                break
              } else {
                completion(false)
                return
              }
            } else {
              completion(false)
              return
            }
            
          case "numberRange":
            if let valueNumber = attribute.attributeValue as? NSNumber {
              let minValue = campaignAttribute.valueFrom?.getNumber() ?? NSNumber(integerLiteral: .min)
              let maxValue = campaignAttribute.valueTo?.getNumber()  ?? NSNumber(integerLiteral: .max)
              
              if (valueNumber.compare(maxValue) == .orderedAscending ||
                  valueNumber.compare(maxValue) == .orderedSame) &&
                  (valueNumber.compare(minValue) == .orderedDescending ||
                   valueNumber.compare(minValue) == .orderedSame) {
                break
              } else {
                completion(false)
                return
              }
            } else {
              completion(false)
              return
            }
          case "list":
            checkAttributes.append(attribute)
            
          default:
            completion(false)
            return
        }
      } else {
        completion(false)
        return
      }
    }
    
    if checkAttributes.count > 0 {
      DispatchQueue.global(qos: .utility).async {
        self._requestManager.sendAttributes(appId: self.appId!,
                                            campaignId: campaignId,
                                            attributes: checkAttributes) { result in
          completion(result)
        }
      }
    } else {
      completion(true)
    }
  }
  
  private func clearTask() {
    self.task?.cancel()
    self.task = nil
  }
  
  /// Метод показа кампании по указанному событию
  /// - Parameter eventName: Название события
  open func startCampaign(eventName: String, attributes: [Attribute]? = nil) {
    DDLog("Attempt starting: \(eventName)")
    
    guard task == nil else {
      DDLog("Some campaign already started")
      return
    }
    
    _eventToSend = eventName
    _attributes = attributes
    
    var targeting: Targeting? = nil
    
    if let campaign = _campaigns.first(where: { campaign in
      targeting = campaign.targeting.first(where: { targeting in
        targeting.type == "trigger" && targeting.value == eventName
      })
      return targeting != nil
    }), let targeting = targeting {
      self.checkAttibutes(campaignId: campaign.campaignId,
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
                                              properties: self.properties)
            
            if !isMultiVisited {
              self.saveShowingTime()
              self._campaigns.removeAll { camp in
                camp.campaignId == campaign.campaignId
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
  
  /// Метод отмены показа кампании. Если кампания уже показана - она будет закрыта
  open func stopCampaign() {
    self._formPresentor?.stopCampaign()
    self.clearTask()
  }
}

extension UXFeedback: RequestManagerDelegate {
  func campaingsLoaded(success: Bool, message: String?, delay: Int?, campaigns: Array<Campaign>) {
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
                                 createdAtClient: StatisticManager.getTimeUTC(),
                                 campaignId: campaign.campaignId,
                                 pages: info,
                                 properties: properties)
    
    _requestManager.sendScreenshotsData(screenshots: screenshots)
  }
}
