//
//  UXFCampaignFormPresentor.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 31.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit

class UXFCampaignFormPresentor: NSObject{
    
    var progressString: String {
        return "\(self.currentFormIndex + 1)/\(formsCount)"
    }
    
    var formsCount: UInt{
        return UInt(_campaign?.formsCount ?? 0)
    }
    
    private(set) var currentFormIndex: Int = -1
    private var _campaign: UXFCampaign!
    private var _theme: UXFTheme?
    var isAnimationFormEnabled: Bool = true
    private weak var _appWindow: UIWindow!
    private weak var _currentForm: UXFViewController?
    private lazy var formCreator: UXFCampaignFormCreator = {
      return UXFCampaignFormCreator()
    }()
    
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
        if self.currentFormIndex <= _campaign.formsCount{
            self.currentFormIndex += 1
            showCurrentForm(direction: currentFormIndex == 0 ? .downToUp : .alphaIn)
        }
        else{
            showCongratulationForm(direction: currentFormIndex == 0 ? .downToUp : .alphaIn)
        }
    }
    
    private func prevForm(){
        if (self.currentFormIndex > 0){
            self.currentFormIndex -= 1
            showCurrentForm(direction: .alphaIn)
        }
    }
    
    private func showCurrentForm(direction: UXFViewPopupDirection){
        
        if self.currentFormIndex == 0{
            showRateForm(direction: direction)
        }
        /*
        else if self.currentFormIndex == 1{
            showCommentForm(direction: direction)
        }*/
        else{
            let controller = UXFViewController.init()
            
            controller.didLoadHandler = { [unowned self] in
                self.formCreator.createForm(controller: controller,
                                            page: self._campaign.pages[self.currentFormIndex-1])
            }
            controller.didCloseHandler = {
                
            }
            controller.backHandler = { [weak self] in
                self?.prevForm()
            }
            controller.nextHandler = { [weak self] in
                self?.nextForm()
            }
            showController(controller: controller, direction: direction)
        }
    }
    
    private func showRateForm(direction: UXFViewPopupDirection){
        let controller = UXFRateViewController.init()
        controller.didCloseHandler = {
            
        }
        controller.nextHandler = { [weak self] in
            self?.nextForm()
        }
        showController(controller: controller, direction:  direction)
    }
    
    private func showCommentForm(direction: UXFViewPopupDirection){
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
        showController(controller: controller, direction: direction)
    }
    
    private func showCongratulationForm(direction: UXFViewPopupDirection){
        let controller = UXFCongratulationViewController()
        controller.didCloseHandler = {
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            controller.close(animated:  true)
        }
        
        showController(controller: controller, direction:  direction)
    }
    
    private func showController(controller: UXFViewController, direction: UXFViewPopupDirection){
        
        _currentForm?.remove(animated: true, completion: nil)
        
        controller.modalPresentationStyle = .overCurrentContext
        controller.progressString = self.progressString
        controller.theme = _theme
        controller.presentDirection = direction
        let parentViewController = _appWindow.rootViewController
        controller.transitioningDelegate = self
        parentViewController?.present(controller, animated: isAnimationFormEnabled){
            controller.state = .presented
        }
        _currentForm = controller
    }
}


extension UXFCampaignFormPresentor: UIViewControllerTransitioningDelegate{
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return UXFFormPresenter()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return UXFFormDismisser()
    }
}

private class UXFFormPresenter: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        //let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! UXFViewController
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
        case .leftToRight:
            animationOptions = .curveEaseInOut
            toViewController.view.frame = CGRect.init(origin: CGPoint.init(x: finalFrameForVC.origin.x + bounds.size.width,
                                                                           y: finalFrameForVC.origin.y),
                                                      size: finalFrameForVC.size)
            break
        case .rightToLeft:
            animationOptions = .curveEaseInOut
            toViewController.view.frame = CGRect.init(origin: CGPoint.init(x: finalFrameForVC.origin.x - bounds.size.width,
                                                                           y: finalFrameForVC.origin.y),
                                                      size: finalFrameForVC.size)
            break
        case .upToDown:
            animationOptions = .curveEaseIn
            toViewController.view.frame = CGRect.init(origin: CGPoint.init(x: finalFrameForVC.origin.x,
                                                                           y: finalFrameForVC.origin.y - bounds.size.height),
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
        default:
            toViewController.view.frame = CGRect.init(origin: CGPoint.init(x: finalFrameForVC.origin.x,
                                                                           y: finalFrameForVC.origin.y + toViewController.contentView.frame.size.height),
                                                      size: finalFrameForVC.size)
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
        }){ (completed) in
            transitionContext.completeTransition(completed)
        }
    }
}

private class UXFFormDismisser: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
 
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! UXFViewController
        
        var animationOptions: UIView.AnimationOptions = .curveEaseOut
        var endAlpha: CGFloat = 1.0
        let animationDuration: TimeInterval = 0.3
        let damping: CGFloat = 1.0//0.8
        let delay: TimeInterval = 0.0
        var endYOfset: CGFloat = 0.0
        
        if fromViewController.state == .closeDismiss {
            animationOptions = .curveEaseIn
            endYOfset = (container.frame.height - fromViewController.contentView.frame.origin.y)
        }
        else {
            endAlpha = 0.0
        }
        
        UIView.animate(withDuration: animationDuration,
                       delay: delay,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: 0,
                       options: animationOptions,
                       animations:  {
               fromViewController.contentView.alpha = endAlpha
               fromViewController.view.frame.origin.y += endYOfset
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
    }
}
