//
//  UXFCampaignPresentor.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 09.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit
import SwiftUI
import Foundation

protocol CampaignFormPresentorProtocol: AnyObject {
    func formSubmitted(info: Array<Dictionary<String, Any>>?, screenshots: [Screenshot], campaign: Campaign, invocationId: String)
}

internal class CampaignPresentor: NSObject {

    weak var feedbackCampaignDelegate: FeedbackCampaignDelegate?
    weak var delegate: CampaignFormPresentorProtocol?
    var isAnimationFormEnabled: Bool = true
    
    var _campaign: Campaign!
    private weak var _appWindow: UIWindow!
    internal weak var _currentForm: CampaignViewController?
    
    internal var isFormOnScreen = false
    
    init(window: UIWindow,
         campaign: Campaign,
         animationEnabled: Bool = true) {
        
        super.init()
        
        _campaign = campaign
        _appWindow = window
        isAnimationFormEnabled = animationEnabled
    }
    
    func showCampaign(uiBlocked: Bool, closeOnSwipe: Bool, blackout: Blackout?, rotateToggle: Bool, properties: [String: Any], invocationId: String) {
        let form = createCampaignForm(_campaign, invocationId: invocationId)
        form.rotateToggle = rotateToggle
        switch _campaign.type {
        case .slidein:
            showCampaignController(controller: form, 
                                   direction: .downToUp, 
                                   uiBlocked: uiBlocked,
                                   closeOnSwipe: closeOnSwipe,
                                   blackout: blackout,
                                   properties: properties)
            break
        case .popup:
            showCampaignController(controller: form, 
                                   direction: .alphaIn,
                                   uiBlocked: true,
                                   blackout: blackout,
                                   properties: properties)
            break
        case .none:
            break
        }
    }
    
    open func createCampaignForm(_ campaign: Campaign, invocationId: String) -> CampaignViewController {
        let controller = CampaignViewController()
        controller.campaign = campaign
        var eventName: String = ""
        if let targeting = campaign.targeting {
            eventName = targeting.value ?? ""
        }
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .overFullScreen
        
        controller.presentHandler = { [weak self] in
            if let _ = self?._campaign {
                self?.isFormOnScreen = true
                self?.feedbackCampaignDelegate?.campaignDidShow(campaignId: campaign.campaignId, eventName: eventName, invocationId: invocationId)
            }
        }
        controller.didCloseHandler = { [weak self] in
            ImageManager.dispose()
            DispatchQueue.main.async {
                self?.isFormOnScreen = false
                self?.feedbackCampaignDelegate?.campaignDidClose(campaignId: campaign.campaignId, eventName: eventName, invocationId: invocationId)
            }
        }
        controller.completeHandler = { [weak self] (info, screenshots) in
            ImageManager.dispose()
            if let campaign = self?._campaign {
                self?.delegate?.formSubmitted(info: info, screenshots: screenshots, campaign: campaign, invocationId: invocationId)
            }
        }
        controller.didTerminateHandler = { [weak self] (info, screenshots, terminatedPage, totalPages) in
            ImageManager.dispose()
            if let campaign = self?._campaign {
                self?.delegate?.formSubmitted(info: info, screenshots: screenshots, campaign: campaign, invocationId: invocationId)
                self?.feedbackCampaignDelegate?.campaignDidTerminate(campaignId: campaign.campaignId, eventName: eventName, terminatedPage: terminatedPage, totalPages: totalPages, invocationId: invocationId)
                self?.isFormOnScreen = false
            }
        }
        
        return controller
    }
    
    private func showCampaignController(controller: CampaignViewController, direction: ViewPopupDirection, uiBlocked: Bool = false, closeOnSwipe: Bool = false, blackout: Blackout? = nil, properties: [String: Any]) {
        
        _ = self.dismissCurrentForm() {
            
            self._currentForm = controller
            
            let blackout = (uiBlocked && blackout?.color != .clear) ? blackout : nil
            
            controller.presentDirection = direction
            controller.closeOnSwipe = closeOnSwipe
            controller.blackout = blackout
            controller.properties = properties
            
            if let view = controller.view as? PassthroughToWindowView {
                view.touchCancel = uiBlocked
            }
            
            if #available(iOS 13.0, *) {
                if let wScene = UIApplication.shared.keyWindow?.windowScene {
                    self._appWindow.windowScene = wScene
                }
            }
            
            self._appWindow.makeKeyAndVisible()
            self._appWindow.becomeKey()
            
            let parentViewController = self._appWindow.rootViewController
            parentViewController?.present(controller, animated: self.isAnimationFormEnabled) {
                controller.state = .presented
            }
        }
    }
    
    @objc func dismissCurrentForm(completion: (()->())?) ->(Bool){
        if let form = _currentForm {
            isFormOnScreen = false
            form.state = .dismissOnly
            form.dismiss(animated: true) { [weak self] in
                if self?._currentForm == form {
                   self?._currentForm?.removeFromParent()
                   self?._currentForm = nil
                }
                completion?()
            }
            return true
        }
        else{
             completion?()
             return false
        }
    }
    
    func stopCampaign() {
        if let form = _currentForm {
            ImageManager.dispose()
            isFormOnScreen = false
            form.dismiss(animated: true)
        } else {
            isFormOnScreen = false
        }
    }
}

extension CampaignPresentor: UIViewControllerTransitioningDelegate{
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return UXFCampaignAnimatorPresenter()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let dismisser = UXFCampaignAnimatorDismisser()
        return dismisser
    }
}

private class UXFCampaignAnimatorPresenter: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        //let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! CampaignViewController
        let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
        let containerView = transitionContext.containerView
        
        //animation params
        let bounds = UIScreen.main.bounds
        var animationOptions: UIView.AnimationOptions = .curveEaseOut
        var startAlpha: CGFloat = 1.0
        var endAlpha: CGFloat = 1.0
        let animationDuration: TimeInterval = 0.3
        let damping: CGFloat = 1.0//0.8
        let delay: TimeInterval = 0.0
        
        switch toViewController.presentDirection {

        case .upToDown:
            animationOptions = .curveEaseIn
            toViewController.view.frame = CGRect.init(origin: CGPoint.init(x: finalFrameForVC.origin.x,
                                                                           y: finalFrameForVC.origin.y - bounds.size.height),
                                                      size: finalFrameForVC.size)
            break
        case .downToUp:
            animationOptions = .curveEaseIn
            toViewController.view.frame = CGRect.init(origin: CGPoint.init(x: finalFrameForVC.origin.x,
                                                                           y: bounds.size.height),
                                                      size: finalFrameForVC.size)
            break
        case .alphaIn:
            startAlpha = 0.0
            endAlpha = 1.0
            break
        case .alphaOut:
            startAlpha = 1.0
            endAlpha = 0.0
            break
        }
        
        containerView.addSubview(toViewController.view)
    
        toViewController.contentView.alpha = startAlpha
        
        if toViewController.blackout != nil {
            let effectView = VisualEffectView(frame: finalFrameForVC)
            
            if toViewController.presentDirection == .downToUp || toViewController.presentDirection == .upToDown {
                effectView.frame.origin.y = -effectView.frame.size.height
                effectView.frame.size.height = effectView.frame.size.height*2
            }
            
            effectView.tag = visualEffectViewTag
            
            if #available(iOS 14, *) {
                effectView.ios14_blurRadius = CGFloat(toViewController.blackout?.blur ?? 0)
            } else {
                effectView.blurRadius = CGFloat(toViewController.blackout?.blur ?? 0)
            }
            
            effectView.backgroundColor = toViewController.blackout?.color.withAlphaComponent(CGFloat(toViewController.blackout?.opacity ?? 0)/100)
            
            toViewController.view.insertSubview(effectView, at: 0)
        }
        
        UIView.animate(withDuration: animationDuration,
                       delay: delay,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: 0,
                       options: animationOptions,
                       animations: {
                        
            toViewController.view.viewWithTag(visualEffectViewTag)?.alpha = 1
            toViewController.view.frame = finalFrameForVC
            toViewController.contentView.alpha = endAlpha
            toViewController.shadowView.alpha = endAlpha
                        
        }){ (completed) in
            transitionContext.completeTransition(completed)
        }
    }
}

private class UXFCampaignAnimatorDismisser: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
 
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! CampaignViewController
        
        var animationOptions: UIView.AnimationOptions = .curveEaseOut
        var endAlpha: CGFloat = 1.0
        let animationDuration: TimeInterval = 0.3
        let damping: CGFloat = 1.0//0.8
        let delay: TimeInterval = 0.0
        var endYOffset: CGFloat = 0.0
        let endXOffset: CGFloat = 0.0
        
        let direction: ViewPopupDirection = fromViewController.dismissDirection
        
        switch direction {
           case .alphaOut:
              endAlpha = 0.0
              break
           case .upToDown:
              animationOptions = .curveEaseIn
              endYOffset = (container.frame.height - fromViewController.contentView.frame.origin.y)
              break
            
           default:
                break
        }
        
        

        UIView.animate(withDuration: animationDuration,
                       delay: delay,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: 0,
                       options: animationOptions,
                       animations:  {
                        
                        fromViewController.view.viewWithTag(visualEffectViewTag)?.alpha = 0
                        fromViewController.shadowView.alpha = endAlpha
                        fromViewController.contentView.alpha = endAlpha
                        fromViewController.view.frame.origin.y += endYOffset
                        fromViewController.view.frame.origin.x += endXOffset
                        
                
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
    }
}
