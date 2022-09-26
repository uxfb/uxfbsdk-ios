//
//  UXFCampaignPresentor.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 09.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit
import Foundation

protocol UXFCampaignFormPresentorProtocol: AnyObject {
    func formSubmitted(info: Array<Dictionary<String, Any>>?, screenshots: [UXFScreenshot], campaign: UXFCampaign)
}

class UXFCampaignPresentor: NSObject {

    weak var feedbackCampaignDelegate: UXFeedbackCampaignDelegate?
    weak var delegate: UXFCampaignFormPresentorProtocol?
    var isAnimationFormEnabled: Bool = true
    
    private var _campaign: UXFCampaign!
    private weak var _appWindow: UIWindow!
    internal weak var _currentForm: UXFCampaignViewController?
    
    internal var isFormOnScreen = false
    
    init(window: UIWindow,
         campaign: UXFCampaign,
         animationEnabled: Bool = true) {
        
        super.init()
        
        _campaign = campaign
        _appWindow = window
        isAnimationFormEnabled = animationEnabled
    }
    
    func showCampaign(uiBlocked: Bool, closeOnSwipe: Bool, blackout: UXFBBlackout?){
        let form = createCampaignForm(_campaign)
        switch _campaign.type {
        case .slidein:
            showCampaignController(controller: form, direction: .downToUp, uiBlocked: uiBlocked, closeOnSwipe: closeOnSwipe, blackout: blackout)
            break
        case .popup:
            showCampaignController(controller: form, direction: .alphaIn, uiBlocked: true, blackout: blackout)
            break
        case .none:
            break
        }
    }
    
    open func createCampaignForm(_ campaign: UXFCampaign) -> UXFCampaignViewController {
        let controller = UXFCampaignViewController()
        controller.campaign = campaign
        var eventName: String = ""
        if let targeting = campaign.targetings.first {
            eventName = targeting["value"] as? String ?? ""
        }
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .overFullScreen
        
        controller.presentHandler = { [weak self] in
            if let _ = self?._campaign {
                self?.isFormOnScreen = true
                self?.feedbackCampaignDelegate?.campaignDidShow(eventName: eventName)
            }
        }
        controller.didCloseHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.isFormOnScreen = false
                self?.feedbackCampaignDelegate?.campaignDidClose(eventName: eventName)
            }
        }
        controller.completeHandler = { [weak self] (info, screenshots) in
            if let campaign = self?._campaign {
                self?.feedbackCampaignDelegate?.campaignDidClose(eventName: eventName)
                self?.delegate?.formSubmitted(info: info, screenshots: screenshots, campaign: campaign)
            }
        }
        controller.didTerminateHandler = { [weak self] (info, screenshots, terminatedPage, totalPages) in
            if let campaign = self?._campaign {
                self?.delegate?.formSubmitted(info: info, screenshots: screenshots, campaign: campaign)
                self?.feedbackCampaignDelegate?.campaignDidTerminate(eventName: eventName, terminatedPage: terminatedPage, totalPages: totalPages)
                self?.isFormOnScreen = false
            }
        }
        
        return controller
    }
    
    private func showCampaignController(controller: UXFCampaignViewController, direction: UXFViewPopupDirection, uiBlocked: Bool = false, closeOnSwipe: Bool = false, blackout: UXFBBlackout? = nil) {
        
        _ = self.dismissCurrentForm() {
            
            self._currentForm = controller
            
            controller.presentDirection = direction
            controller.closeOnSwipe = closeOnSwipe
            controller.blackout = blackout
            
            if let view = controller.view as? PassthroughToWindowView {
                view.touchCancel = uiBlocked
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
            isFormOnScreen = false
            form.dismiss(animated: true)
        }
    }
}

extension UXFCampaignPresentor: UIViewControllerTransitioningDelegate{
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
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! UXFCampaignViewController
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
            effectView.colorTint = toViewController.blackout?.color
            effectView.colorTintAlpha = CGFloat(toViewController.blackout?.opacity ?? 0)/100
            effectView.blurRadius = CGFloat(toViewController.blackout?.blur ?? 0)
            effectView.scale = 1
            effectView.alpha = 0
            
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
 
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! UXFCampaignViewController
        
        var animationOptions: UIView.AnimationOptions = .curveEaseOut
        var endAlpha: CGFloat = 1.0
        let animationDuration: TimeInterval = 0.3
        let damping: CGFloat = 1.0//0.8
        let delay: TimeInterval = 0.0
        var endYOffset: CGFloat = 0.0
        let endXOffset: CGFloat = 0.0
        
        let direction: UXFViewPopupDirection = fromViewController.dismissDirection
        
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
