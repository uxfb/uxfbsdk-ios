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
        super.init(domain: "uxfeedback", code: 0, userInfo: ["description": description])
        self.desc = description
    }


    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


@objcMembers
open class UXFeedback : NSObject{
    
    public static let sharedInstance = UXFeedback.init()
    
    open  var delegate: UXFeedbackCampaignDelegate?
    open  var formDelegate: UXFeedbackFormDelegate?
    open  var debugEnabled: Bool = false
    open  var animationEnabled: Bool = true
    open var canDisplayCampaings: Bool = true
    open var isCampaignsLoaded: Bool {
        return _campaigns.count > 0
    }
    public static var isStage: Bool {
        return UXFAPIWebRouter.isStageAPI
    }
    
    private var _theme: UXFTheme!
    private  weak var _activeEventController: UIViewController?
    private  var _appWindow: UIWindow!
    private  var _apiClient: UXFAPIClient!
    private var _campaigns: Array<UXFCampaign> = []
    private  var _eventToSend: String?
    private var _resetAllCampaingHandler: (()->())?
    private var _resetAllCampaingNeeds: Bool = false
    private  var _formPresentor: UXFCampaignFormPresentor?
    private var _parser: UXFParser!
    
    open var currentForm: UXFViewController?{
        return _formPresentor?._currentForm
    }
    
    override init() {
        super.init()
        self.setTheme(theme: UXFTheme.init())
    }
    
    open func setTheme(theme: UXFTheme){
        _theme = theme
        _parser = UXFParser.init(theme: theme)
    }
    
    //Initialization SDK
    @available(iOS 13.0, *)
    open func setup(appID: String,
                    windowScene: UIWindowScene,
                    theme: UXFTheme? = nil,
                    completion: ((_ success: Bool) -> Void)? = nil){
        
        //let window = windowScene.windows.first
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIViewController()
        window.windowLevel = UIWindow.Level.alert + 10
        self.setup(appID: appID,
                   window: window != nil ? window : UIWindow(windowScene: windowScene),
                   theme: theme,
                   completion: completion)
    }
    
    open func setup(appID: String,
                    theme: UXFTheme? = nil,
                    completion: ((_ success: Bool) -> Void)? = nil){
        
        setup(appID: appID,
              window: nil,
              theme: theme,
              completion: completion)
    }
        
    private func setup(appID: String,
                    window: UIWindow?,
                    theme: UXFTheme? = nil,
                    completion: ((_ success: Bool) -> Void)? = nil){
        
        DDLogDebug(UXFAPIWebRouter.baseURL)
        
        if theme != nil {
           self.setTheme(theme: theme!)
        }

        _apiClient = UXFAPIClient.init(appID: appID, parser: self._parser)
        _apiClient.getAllCampaings { [weak self] (success, message, campaigns) in

        if window == nil {
           self?._appWindow = UIWindow(frame: UIScreen.main.bounds)
           self?._appWindow.rootViewController = UIViewController()
           self?._appWindow.windowLevel = UIWindow.Level.alert + 10
        }
        else{
            self?._appWindow = window
        }
            self?._campaigns = campaigns
        
            if success == true{
             
                if self?._resetAllCampaingNeeds == true {
                    self?.resetAllCampaigns()
                }
                if let event = self?._eventToSend {
                   self?.sendEvent(event: event)
                 }
            }
            
            completion?(success)
            self?.delegate?.campaignLoaded(success: success)
        }
    }
    
    private func setupFont(){
        
    }
    
    //Requrst event to show campaing form with specific name
    open func sendEvent(event: String, fromController: UIViewController? = nil){
    
        _eventToSend = event
        var eventShowed = false
        if self.canDisplayCampaings == true{
            _campaigns.forEach { (campaign) in
                campaign.targetings.forEach({ (targeting) in
                    if let type = targeting["type"] as? String, type == "event",
                       let name = targeting["name"] as? String, name == event,
                        campaign.show() == true,
                        eventShowed == false{
                        
                        eventShowed = true
                        _eventToSend = nil
                        DispatchQueue.main.asyncAfter(deadline: (.now() + campaign.showDelay(eventName: name)), execute: { [unowned self] in
                            
                            _ = self._formPresentor?.dismissCurrentForm(completion:  nil)
                            self._formPresentor = UXFCampaignFormPresentor.init(window: self._appWindow,
                                                                                campaign: campaign,
                                                                                parser: self._parser,
                                                                                animationEnabled: true)
                            self._formPresentor?.isAnimationFormEnabled = self.animationEnabled
                            self._formPresentor?.delegate = self
                            //Только для случая когда вызываем одну форму в loadFeedbackForm()
                            //self._formPresentor?.feedbackFormDelegate = self.formDelegate
                            self._formPresentor?.feedbackCampaignDelegate = self.delegate
                            self._formPresentor?.showCampaign()
                            self._apiClient.showForm(campaingId: campaign.campaignId)
                        })
                        
                    }
                })
            }
        }
    }
    
    open func loadFeedbackForm(formID: String){
        
        _campaigns.forEach { (campaign) in
            campaign.pages.forEach({ (page) in
                if page.id == formID {
                    _ = self._formPresentor?.dismissCurrentForm(completion:  nil)
                         
                    let formIndex = 0
                    let presentor = UXFCampaignFormPresentor.init(window: self._appWindow,
                                                                  campaign:  campaign,
                                                                  parser: _parser,
                                                                  animationEnabled: true)
                    self._formPresentor  = presentor
                    presentor.isAnimationFormEnabled = self.animationEnabled
                    presentor.delegate = self
                    presentor.feedbackCampaignDelegate = self.delegate
                    presentor.feedbackFormDelegate = self.formDelegate
                    let controller = presentor.createForm(formIndex: formIndex)
                    controller.presentDirection = .downToUp
                    self.formDelegate?.formDidLoaded(form: controller)
                    
                    return
                }
            })
        }
        
        self.formDelegate?.formDidFailLoading(error: UXFError.init(description: "Form " + formID + " not found in any companies"))
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
}

extension UXFeedback: UXFCampaignFormPresentorProtocol {
    
    func formSubmitted(formIndex: Int, info: Dictionary<String, Any>?, campaign: UXFCampaign) {

            _apiClient.saveFormData(isFirstAnswer: (formIndex == 0),
                                    projectId: campaign.projectId,
                                    answerId: campaign.answerId,
                                        campaignId: campaign.campaignId,
                                            fields: info) { (success, message, answerId) in
                                                if answerId != nil {
                                                    campaign.setAnswerID(answerID: answerId)
                                                }
                                                if success == false {
                                                    self.delegate?.campaignErrorReceived(errorString: "Неизвестная ошибка при отправке данных формы")
                                                }
            }
    }
}
