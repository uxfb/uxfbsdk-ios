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
    func formSubmitted(formIndex: Int, info: Array<Dictionary<String, Any>>?, campaign: UXFCampaign)
}

class UXFCampaignPresentor: NSObject {

    weak var feedbackFormDelegate: UXFeedbackFormDelegate?
    weak var feedbackCampaignDelegate: UXFeedbackCampaignDelegate?
    weak var delegate: UXFCampaignFormPresentorProtocol?
    var isAnimationFormEnabled: Bool = true
    
    private(set) var currentFormIndex: Int = -1
    private var _campaign: UXFCampaign!
    private weak var _appWindow: UIWindow!
    internal weak var _currentForm: UXFCampaignViewController?

    init(window: UIWindow,
         campaign: UXFCampaign,
         animationEnabled: Bool = true) {
        
        super.init()
        
        _campaign = campaign
        _appWindow = window
        isAnimationFormEnabled = animationEnabled
    }
    
    func showCampaign(){
        let form = createCampaignForm(_campaign)
        switch _campaign.type {
        case .slidein:
            showCampaignController(controller: form, direction: .downToUp)
            break
        case .popup:
            showCampaignController(controller: form, direction: .alphaIn)
            break
        case .none:
            break
        }
    }
    
    open func createCampaignForm(_ campaign: UXFCampaign) -> UXFCampaignViewController {
        let controller = UXFCampaignViewController()
        controller.campaign = campaign
        
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .overFullScreen
//        controller.didCloseHandler = { [weak self]  (formIndex) in
            
//            if let formsCount = self?._campaign.formsCount {
//                let result = UXFeedbackResult.init(rating: self?._campaign.raiting,
//                                              abandonedPageIndex: formIndex,
//                                              sent: true)
//                if formIndex == (formsCount - 1) {
//                    DispatchQueue.main.async {
//                        self?.feedbackCampaignDelegate?.campaignDidClose(withFeedbackResult: result,
//                        isRedirectToAppStoreEnabled: false)
//                    }
//                }
//                else{
//
//                }
//            }
//        }
        
        controller.presentHandler = { [weak self] in
            if let _ = self?._campaign {
                self?.feedbackCampaignDelegate?.campaignDidShow()
            }
        }
        
        controller.completeHandler = { [weak self] (formIndex, info) in
            if let campaign = self?._campaign {
               self?.delegate?.formSubmitted(formIndex: formIndex, info: info, campaign: campaign)
            }
           
            if self?.feedbackFormDelegate != nil {
               controller.dismiss(animated: true, completion: nil)
            }
        }
        
        return controller
    }
    
    private func showCampaignController(controller: UXFCampaignViewController, direction: UXFViewPopupDirection){
        _ = self.dismissCurrentForm(){
            
            self._currentForm = controller
            controller.presentDirection = direction
            
            self._appWindow.makeKeyAndVisible()
            self._appWindow.becomeKey()
            let parentViewController = self._appWindow.rootViewController
            parentViewController?.present(controller, animated: self.isAnimationFormEnabled){
                controller.state = .presented
            }
            
            if self._campaign.autoclose > 0 && self._currentForm?.formIndex == (self._campaign.pages.count - 1) {
                DispatchQueue.main.asyncAfter(deadline: .now() + self._campaign.autoclose) { [ weak self] in
                    self?._currentForm?.dismiss(animated: self?._currentForm?.presentationAnimated ?? true)
                }
            }
        }
    }
    
    @objc func dismissCurrentForm(completion: (()->())?) ->(Bool){
        
        if let form = _currentForm {
            form.state = .dismissOnly
            form.dismiss(animated: true){ [weak self] in
                
                if self?._currentForm == form{
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
//        
//            toViewController.view.frame = CGRect.init(origin: CGPoint.init(x: finalFrameForVC.origin.x,
//                                                                           y: finalFrameForVC.origin.y + toViewController.contentView.frame.size.height),
//                                                      size: finalFrameForVC.size)
        }
        
        
        containerView.addSubview(toViewController.view)
    
        toViewController.contentView.alpha = startAlpha
        
        UIView.animate(withDuration: animationDuration,
                       delay: delay,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: 0,
                       options: animationOptions,
                       animations: {
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
                fromViewController.shadowView.alpha = endAlpha
               fromViewController.contentView.alpha = endAlpha
               fromViewController.view.frame.origin.y += endYOffset
               fromViewController.view.frame.origin.x += endXOffset
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
    }
}
