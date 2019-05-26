//
//  UXFeedback.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjackSwift

public struct UXFError : Error {
    
    public let description: String
}

open class UXFeedback{
    
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
    private  weak var _appWindow: UIWindow!
    private  var _apiClient: UXFAPIClient!
    private var _campaigns: Array<UXFCampaign> = []
    private  var _eventToSend: String?
    private  var _formPresentor: UXFCampaignFormPresentor?
    private var _parser: UXFParser!
    
    init() {
        self.setTheme(theme: UXFTheme.init(colorsDict: [:], smilesDict: [:]))
    }
    
    open func setTheme(theme: UXFTheme){
        _theme = theme
        _parser = UXFParser.init(theme: theme)
    }
    
    //Initialization SDK
    open func setup(appID: String,
                    applicationWindow: UIWindow,
                    theme: UXFTheme? = nil,
                    completion: ((_ success: Bool) -> Void)? = nil){
        
        print(UXFAPIWebRouter.baseURL)
        
        if theme != nil {
           self.setTheme(theme: theme!)
        }

        _apiClient = UXFAPIClient.init(appID: appID, parser: self._parser)
        _apiClient.getAllCampaings { [weak self] (success, message, campaigns) in

            self?._appWindow = applicationWindow
            self?._campaigns = campaigns
        
            if success == true, let event = self?._eventToSend {
                self?.sendEvent(event: event)
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
        
        if self.canDisplayCampaings == true{
            _campaigns.forEach { (campaign) in
                campaign.targeting.forEach({ (targeting) in
                    if targeting["type"] == event &&  campaign.show() == true{
                        
                        _eventToSend = nil
                        DispatchQueue.main.asyncAfter(deadline: (.now() + campaign.showDelay), execute: { [unowned self] in
                            self._formPresentor?.dismissCurrentForm()
                            self._formPresentor = UXFCampaignFormPresentor.init(window: self._appWindow,
                                                                                campaign: campaign,
                                                                                parser: self._parser,
                                                                                animationEnabled: true)
                            self._formPresentor?.isAnimationFormEnabled = self.animationEnabled
                            self._formPresentor?.delegate = self
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
                    
                    self._formPresentor?.dismissCurrentForm()
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
                    let controller = presentor.createForm(fromIndex: formIndex)
                    controller.presentDirection = .downToUp
                    self.formDelegate?.formDidLoaded(form: controller)
                    
                    return
                }
            })
        }
    }
    
    open func resetAllCampaignsData(completion: (()->())?){
        
        _campaigns.forEach { (campaign) in
            campaign.removeUserData()
        }
    }
    
    //MARK: support
    func showMessage(title: String? = nil, text: String, completion: ((UIAlertAction)->(Void))?){
        let alert = UIAlertController.init(title: title,
                                           message: text,
                                           preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Ок", style: .default, handler: completion))
        alert.show()
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
                                                   self.showMessage(text: message ?? "Неизвестная ошибка при отправке данных формы", completion: nil)
                                                }
            }
    }
}
