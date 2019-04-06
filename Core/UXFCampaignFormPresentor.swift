//
//  UXFCampaignFormPresentor.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 31.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit

class UXFCampaignFormPresentor{
    
    var progressString: String {
        return "\(currentFormIndex + 1)/\(formsCount)"
    }
    
    var formsCount: UInt{
        return 3
    }
    
    private(set) var currentFormIndex: Int = -1
    private var _campaign: UXFCampaign!
    private var _theme: UXFTheme?
    var isAnimationFormEnabled: Bool = true
    private weak var _appWindow: UIWindow!
    private weak var _currentForm: UXFViewController?
    
    init(window: UIWindow, campaign: UXFCampaign, theme: UXFTheme? = nil, animationEnabled: Bool = true) {
        _campaign = campaign
        _appWindow = window
        _theme = theme
        isAnimationFormEnabled = animationEnabled
    }
    
    func showForm(){
        nextForm()
    }
    
    func dismissForm(){
        _currentForm?.close()
    }
    
    //MARK: - Form navogation presentation
    
    private func nextForm(){
        if self.currentFormIndex < (_campaign.formsCount - 1){
           self.currentFormIndex += 1
           showCurrentForm()
        }
        else{
            showCongratulationForm()
        }
    }
    
    private func prevForm(){
        if (self.currentFormIndex > 0){
            self.currentFormIndex -= 1
            showCurrentForm()
        }
    }
    
    private func showCurrentForm(){
        
        if self.currentFormIndex == 0{
            showRateForm()
        }
        else if self.currentFormIndex == 1{
            showCommentForm()
        }
    }
    
    private func showRateForm(){
        let controller = UXFRateViewController.init()
        controller.didCloseHandler = {
            
        }
        controller.nextHandler = { [weak self] in
            self?.nextForm()
        }
        showController(controller: controller)
    }
    
    private func showCommentForm(){
        let controller = UXFCommentViewController.init()
        controller.didCloseHandler = {
            
        }
        controller.backHandler = { [weak self] in
            self?.prevForm()
        }
        controller.nextHandler = { [weak self] in
            self?.nextForm()
        }
        controller.isMandatoryField = false
        showController(controller: controller)
    }
    
    private func showCongratulationForm(){
        let controller = UXFCongratulationViewController()
        controller.didCloseHandler = {
            
        }
        showController(controller: controller)
    }
    
    private func showController(controller: UXFViewController){
        
        _currentForm?.remove(animated: false, completion: nil)
        
         controller.modalPresentationStyle = .overCurrentContext
         controller.progressLabel?.text = self.progressString
         controller.theme = _theme
        
        let parentViewController = _appWindow.rootViewController
        if self.currentFormIndex == 0 {
           parentViewController?.present(controller, animated: isAnimationFormEnabled, completion: nil)
        }
        else{
           parentViewController?.presentDetail(controller)
        }
        
        _currentForm = controller
    }
    
}
