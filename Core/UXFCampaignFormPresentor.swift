//
//  UXFCampaignFormPresentor.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 31.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit

let IS_IPAD = (UIDevice.current.userInterfaceIdiom == .pad)

protocol UXFCampaignFormPresentorProtocol: class {
    func formSubmitted(formIndex: Int, info: Dictionary<String, Any>?, campaign: UXFCampaign)
}

class UXFCampaignFormPresentor: NSObject{
    
    var progressString: String {
        if self.currentFormIndex < 0 || self.currentFormIndex >= (_campaign.pages.count  -  1) {
            return ""
        }else {
            return "\(self.currentFormIndex + 1)/\(formsCount - 1)"
        }
    }
    
    var formsCount: UInt{
        return UInt(_campaign?.formsCount ?? 0)
    }
    
    weak var feedbackFormDelegate: UXFeedbackFormDelegate?
    weak var feedbackCampaignDelegate: UXFeedbackCampaignDelegate?
    weak var delegate: UXFCampaignFormPresentorProtocol?
    var isAnimationFormEnabled: Bool = true
    
    private(set) var currentFormIndex: Int = -1
    private var _campaign: UXFCampaign!
    private weak var _appWindow: UIWindow!
    internal weak var _currentForm: UXFViewController?
    private var _parser: UXFParser!

    init(window: UIWindow,
         campaign: UXFCampaign,
         parser: UXFParser,
         animationEnabled: Bool = true) {
        
        super.init()
        
        _campaign = campaign
        _appWindow = window
        _parser = parser
        isAnimationFormEnabled = animationEnabled
        
        self.preloadImages()
    }
    
    private func preloadImages(){
        _campaign.pages.forEach { (page) in
            
            if let filedsInfoArr = page.uiData["fields"] as? Array<Dictionary<String, Any>> {
                  for fieldInfo in  filedsInfoArr{
                    _parser.preloadImages(dictionary: fieldInfo)
                }
            }
        }
    }
    
    func showCampaign(){
        nextForm()
    }
    
    @objc func dismissCurrentForm(completion: (()->())?) ->(Bool){
        
        if let form = _currentForm {
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
    
    //MARK: - Form navigation presentation
    
    private func nextForm(){
        if (self.currentFormIndex + 1) < _campaign.formsCount{
            self.currentFormIndex += 1
            let form  = createForm(formIndex: self.currentFormIndex, title: self.progressString)
            showCampaignController(controller: form, direction: (currentFormIndex == 0 ? .downToUp : .alphaIn))
        }
    }
    
    private func prevForm(){
        if (self.currentFormIndex > 0){
            self.currentFormIndex -= 1
            let form =  createForm(formIndex: self.currentFormIndex, title: self.progressString)
            showCampaignController(controller: form, direction: .alphaIn)
        }
    }
    
    //MARK: - Form controller
    
    open func createForm(formIndex: Int, title: String? = nil) -> (UXFViewController){
        
        let page = self._campaign.pages[formIndex]
        let controller = UXFViewController.init(index: formIndex, formID: page.id )
        controller.modalPresentationStyle = .overCurrentContext
        controller.progressString = (title == nil ? "" : title!)
        controller.theme = self._campaign.theme
        controller.transitioningDelegate = self
        if formIndex == _campaign.formsCount - 1 {
            controller.dismissDirection = .upToDown
        }
        
        controller.didCloseHandler = { [weak self]  (formIndex) in
            
            if let formsCount = self?._campaign.formsCount {
                let result = UXFeedbackResult(rating: self?._campaign.raiting,
                                              abandonedPageIndex: formIndex,
                                              sent: true)
                if formIndex == (formsCount - 1) {
                    self?.feedbackCampaignDelegate?.campaignDidClose(withFeedbackResult: result,
                                                                     isRedirectToAppStoreEnabled: false)
                }
                else{
                    self?.feedbackFormDelegate?.formDidClose(formID: controller.formID,
                                                             withFeedbackResults: [result],
                                                             isRedirectToAppStoreEnabled: false)
                }
            }
            
        }
        controller.willCloseHandler = { [weak self] (formIndex) in
            self?.feedbackFormDelegate?.formWillClose(form: controller,
                                              formID: controller.formID,
                                              withFeedbackResults: [],
                                              isRedirectToAppStoreEnabled: false)
        }
        
        controller.backHandler = { [weak self]  (formIndex) in
            self?.prevForm()
        }
        controller.nextHandler = { [weak self] (formIndex, info) in
            if let campaign = self?._campaign {
               self?.delegate?.formSubmitted(formIndex: formIndex, info: info, campaign: campaign)
            }
           
            if self?.feedbackFormDelegate != nil {
               controller.dismiss(animated: true, completion: nil)
            }
            else{
                 self?.nextForm()
            }
        }
        controller.didLoadHandler = { [weak self]  (formIndex) in
            self?.prepareUIForm(controller: controller, page: page)
        }
        return controller
    }
    
    func prepareUIForm(controller: UXFViewController, page: UXFPage) {
        
        controller.contentView.backgroundColor = _campaign.theme.backgroundColor
        
        var allConstraints: [NSLayoutConstraint] = []
        var viewIndex = 0
        var contentHeight: CGFloat = (controller.progressLabel?.frame.size.height ?? 0.0) + (controller.progressLabel?.frame.origin.y ?? 0.0)
        if let filedsInfoArr = page.uiData["fields"] as? Array<Dictionary<String, Any>> {
            
            var allviews: Dictionary <String, UIView> = [:]
            if controller.progressLabel?.text?.count ?? 0 > 0 {
               allviews["topView"] = controller.progressLabel!
            }
            var fieldViews: Dictionary <String, UIView> = [:]
            for fieldInfo in  filedsInfoArr{
                
                if let filedView = _parser.parseUIElement(dictionary: fieldInfo,
                                                          theme: _campaign.theme,
                                                          campaign: _campaign,
                                                         submitHandler: {(info) in
                                                        controller.nextHandler?(controller.formIndex, info)
                }){
                    controller.contentView.addSubview(filedView)
                    filedView.translatesAutoresizingMaskIntoConstraints = false
                    allviews["view\(viewIndex)"] = filedView
                    fieldViews["view\(viewIndex)"] = filedView
                    allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view\(viewIndex)]-|",
                        metrics: nil,
                        views: ["view\(viewIndex)": filedView])
                    viewIndex += 1
                    contentHeight += filedView.frame.size.height + 8.0
                }
            }
            var layoutFormat = "V:|-"
            if allviews["topView"] != nil {
              layoutFormat += "[topView]-"
            }
            else{
                layoutFormat += "27.0-"
            }
            
            for viewName in fieldViews.keys.sorted(){
                layoutFormat += "[" + viewName + "]-"
            }
            layoutFormat += "(15)-|"
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: layoutFormat,
                                                             metrics: nil,
                                                             views: allviews as [String : Any])
        }
        controller.heightConstraint?.constant = contentHeight
        controller.contentView.addConstraints(allConstraints)
        
        /*
         controller.contentView.addSubview(page.button)
         page.button.translatesAutoresizingMaskIntoConstraints = false
         let views = ["topView" : topView, "button": page.button, "superview": controller.contentView]
         
         let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[superview]-15-[button(44)]-15-[superview]",
         options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
         metrics: nil,
         views: views as [String : Any])
         let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[topView]-15-[button(120)]-15-[superview]",
         options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
         metrics: nil,
         views: views as [String : Any])
         controller.contentView.addConstraints(horizontalConstraints)
         controller.contentView.addConstraints(verticalConstraints)
         */
    }
    
    /*
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
        controller.didCloseHandler = {  (formIndex) in
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            controller.close(animated:  true)
        }
        
        showController(controller: controller, direction:  direction)
    }*/
    
    private func showCampaignController(controller: UXFViewController, direction: UXFViewPopupDirection){
        
        _ = self.dismissCurrentForm(){
            
            self._currentForm = controller
            self._campaign.сurrentFormID = controller.formID //save current campaign formID
            
            controller.presentDirection = direction
            
            self._appWindow.makeKeyAndVisible()
            self._appWindow.becomeKey()
            let parentViewController = self._appWindow.rootViewController
            parentViewController?.present(controller, animated: self.isAnimationFormEnabled){
                //controller.state = .presented
            }
            
            if self._campaign.autoclose > 0 && self._currentForm?.formIndex == (self._campaign.pages.count - 1) {
                DispatchQueue.main.asyncAfter(deadline: .now() + self._campaign.autoclose) { [ weak self] in
                    self?._currentForm?.closeForm(animated: self?._currentForm?.presentationAnimated ?? true)
                }
            }
        }
        
       
    }
}


extension UXFCampaignFormPresentor: UIViewControllerTransitioningDelegate{
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return UXFFormPresenter()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let dismisser = UXFFormDismisser()
        return dismisser
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
        var endYOffset: CGFloat = 0.0
        var endXOffset: CGFloat = 0.0
        
        var direction: UXFViewPopupDirection = fromViewController.dismissDirection
        if fromViewController.state == .backDismiss{
            direction =  fromViewController.backDirection
        }
        
        switch direction {
           case .alphaOut:
              endAlpha = 0.0
              break
           case .upToDown:
              animationOptions = .curveEaseIn
              endYOffset = (container.frame.height - fromViewController.contentView.frame.origin.y)
              break
          case .leftToRight:
              endXOffset = container.frame.width
              break
          case .rightToLeft:
              endXOffset = -container.frame.width
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
               fromViewController.contentView.alpha = endAlpha
               fromViewController.view.frame.origin.y += endYOffset
               fromViewController.view.frame.origin.x += endXOffset
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
    }
}
