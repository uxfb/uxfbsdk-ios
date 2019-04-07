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
            showCurrentForm(direction: currentFormIndex == 0 ? .downToUp : .leftToRight)
        }
        else{
            showCongratulationForm(direction: currentFormIndex == 0 ? .downToUp : .leftToRight)
        }
    }
    
    private func prevForm(){
        if (self.currentFormIndex > 0){
            self.currentFormIndex -= 1
            showCurrentForm(direction: .rightToLeft)
        }
    }
    
    private func showCurrentForm(direction: UXFViewPopupDirection){
        
        if self.currentFormIndex == 0{
            showRateForm(direction: direction)
        }
        else if self.currentFormIndex == 1{
            showCommentForm(direction: direction)
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
        showController(controller: controller, direction:  direction)
    }
    
    private func showController(controller: UXFViewController, direction: UXFViewPopupDirection){
        
        _currentForm?.remove(animated: false, completion: nil)
        
        controller.modalPresentationStyle = .overCurrentContext
        controller.progressLabel?.text = self.progressString
        controller.theme = _theme
        controller.presentDirection = direction
        let parentViewController = _appWindow.rootViewController
        controller.transitioningDelegate = self
        parentViewController?.present(controller, animated: isAnimationFormEnabled, completion: nil)
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
        let bounds = UIScreen.main.bounds
        
        switch toViewController.presentDirection {
        case .leftToRight:
            toViewController.view.frame = CGRect.init(origin: CGPoint.init(x: finalFrameForVC.origin.x + bounds.size.width,
                                                                           y: finalFrameForVC.origin.y),
                                                      size: finalFrameForVC.size)
            break
        case .rightToLeft:
            toViewController.view.frame = CGRect.init(origin: CGPoint.init(x: finalFrameForVC.origin.x - bounds.size.width,
                                                                           y: finalFrameForVC.origin.y),
                                                      size: finalFrameForVC.size)
            break
        case .upToDown:
            toViewController.view.frame = CGRect.init(origin: CGPoint.init(x: finalFrameForVC.origin.x,
                                                                           y: finalFrameForVC.origin.y - bounds.size.height),
                                                      size: finalFrameForVC.size)
            break
        default:
            toViewController.view.frame = CGRect.init(origin: CGPoint.init(x: finalFrameForVC.origin.x,
                                                                           y: finalFrameForVC.origin.y + toViewController.contentView.frame.size.height),
                                                      size: finalFrameForVC.size)
        }
        
        
        containerView.addSubview(toViewController.view)
    
       
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveLinear,
                       animations: {
            toViewController.view.frame = finalFrameForVC
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
        let fromView = transitionContext.view(forKey: .from)!
        UIView.animate(withDuration: 0.5, animations: {
            fromView.frame.origin.y += (container.frame.height - fromView.frame.minY)
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
    }
}
