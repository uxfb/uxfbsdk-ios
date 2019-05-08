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

open class UXFeedback{
    
    public static let sharedInstance = UXFeedback.init()
    
    private var answerId: String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "answerId")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.object(forKey: "answerId") as? String
        }
    }
    public  var delegate: UXFeedbackDelegate?
    public  var debugEnabled: Bool = false
    public  var animationEnabled: Bool = true
    
    private  weak var _activeEventController: UIViewController?
    private  weak var _appWindow: UIWindow!
    private  var _apiClient: UXFAPIClient!
    private  var _theme: UXFTheme?
    private  var _campaign: UXFCampaign?
    private  var _eventToSend: String?
    private  var _formPresentor: UXFCampaignFormPresentor?
    
    //Initialization SDK
    open func setup(appID: String,
                          applicationWindow: UIWindow,
                          completion: ((_ success: Bool) -> Void)? = nil){
        
        _apiClient = UXFAPIClient.init(appID: appID)
        _apiClient.getAllCampaings { [weak self] (success, message, aTheme, aCampaign) in
            self?._theme = aTheme
            self?._campaign = aCampaign
            self?._appWindow = applicationWindow
        
            if success == true, let event = self?._eventToSend {
                self?.sendEvent(event: event)
            }
            
             completion?(success)
        }
    }
    
    //Requrst event to show campaing form with specific name
    open func sendEvent(event: String, fromController: UIViewController? = nil){
        
        _eventToSend = event

        #warning("implement API call here")
        if let campaign = _campaign, campaign.show() == true{
            _eventToSend = nil
            DispatchQueue.main.asyncAfter(deadline: (.now() + campaign.showDelay), execute: { [unowned self] in
                self._formPresentor?.dismissForm()
                self._formPresentor = UXFCampaignFormPresentor.init(window: self._appWindow,
                                                                    campaign:  campaign,
                                                                    theme: self._theme,
                                                                    animationEnabled: true)
                self._formPresentor?.isAnimationFormEnabled = self.animationEnabled
                self._formPresentor?.delegate = self
                self._formPresentor?.feedbackDelegate = self.delegate
                self._formPresentor?.showForm()
            })
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
    
    func formSubmitted(formIndex: Int, info: Dictionary<String, Any>?) {
     
            _apiClient.saveFormData(isFirstAnswer: (formIndex == 0),
                                    projectId: _campaign!.projectId,
                                    answerId: self.answerId,
                                        campaignId: _campaign!.campaignId,
                                            fields: info) { (success, message, answerId) in
                                                if answerId != nil {
                                                  self.answerId = answerId!
                                                }
                                                if success == false {
                                                   self.showMessage(text: message ?? "Неизвестная ошибка при отправке данных формы", completion: nil)
                                                }
            }

    }
}
