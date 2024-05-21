//
//  ImageViewer.swift
//  StayClean
//
//  Created by Alexander Potemka on 19/10/2018.
//  Copyright © 2018 LLC Andalex. All rights reserved.
//

import UIKit
import Photos

typealias imagePickerAction = ([UIImage]) -> Void
typealias closeAction = () -> Void

class ImageManager: NSObject {
    
    static var currentOverlay: UIView?
    static var hideAction: closeAction?
    
    private static var direction: CGFloat = 0
    
    override init() { }
    
    //MARK: - Create Overlay
    
    private static func createOverlay(overlayTarget: UIView) -> UIView {
        let overlay = UIView(frame: overlayTarget.frame)
        overlay.center = overlayTarget.center
        overlay.alpha = 1
        overlay.backgroundColor = UIColor.clear
        return overlay
    }
    
    //MARK: - Gestures

    @objc private static func navViewAction() {
        if let navView = currentOverlay?.viewWithTag(1234) {
            UIView.animate(withDuration: 0.15) {
                navView.frame.origin.y = navView.frame.origin.y == 0 ? -navView.frame.size.height : 0
            }
        }
    }
    
    @objc private static func panAction(pan: UIPanGestureRecognizer) {
        let endPoint = pan.translation(in: pan.view?.superview)
        let view = currentOverlay?.viewWithTag(999)
        switch pan.state {
        case .began:
            break
            
        case .changed:
            let velocity = pan.velocity(in: pan.view?.superview)
            direction = velocity.y
            let newY = (currentOverlay?.center.y ?? 0) + endPoint.y
            view?.center.y = newY
            
        case .ended:
            let velocity = pan.velocity(in: pan.view?.superview)
            if abs(velocity.y) > 100 {
                hide(animated: true)
            } else {
                UIView.animate(withDuration: 0.15) {
                    view?.center.y = currentOverlay?.center.y ?? 0
                }
            }
            
        default:
            break
        }
    }
    
    //MARK: - Show
    
    public static func showImageFullScreen(images: [UIImage], tappedIndex: Int, startPoint: CGPoint, startSize: CGSize, action: @escaping closeAction, closeAction: @escaping closeAction) {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            return
        }
        var addTop: CGFloat = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            addTop = window?.safeAreaInsets.top ?? 0
        }
        
        let overlay = ImageManager.createOverlay(overlayTarget: currentMainWindow)
        currentMainWindow.addSubview(overlay)
        currentMainWindow.bringSubviewToFront(overlay)
        let titleLabel = UILabel(frame: CGRect(x: overlay.frame.size.width/2 - 60,
                                               y: overlay.frame.origin.y + addTop,
                                               width: 120,
                                               height: 48))
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.text = "\(tappedIndex + 1) \(Consts.Texts.of) \(images.count)"
        
        let imageCollection = Consts.bundle.loadNibNamed("ImageCollection", owner: self, options: nil)?.first as! ImageCollection
        imageCollection.configure(frame: CGRect(origin: startPoint, size: startSize), images: images, currentIndex: tappedIndex) { title in
            titleLabel.text = title
        }
        imageCollection.tag = 999
        
        overlay.addSubview(imageCollection)
        
        let navView = UIView(frame: CGRect(x: overlay.frame.origin.x,
                                           y: overlay.frame.origin.y,
                                           width: overlay.frame.size.width,
                                           height: addTop + 48))
        navView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        navView.tag = 1234
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ImageManager.navViewAction))
        tapGesture.cancelsTouchesInView = false
        tapGesture.numberOfTapsRequired = 1
        imageCollection.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ImageManager.panAction(pan:)))
        panGesture.cancelsTouchesInView = false
        imageCollection.addGestureRecognizer(panGesture)
        
        let cancelButton = UIButton(frame: CGRect(x: overlay.frame.size.width - 60,
                                                  y: overlay.frame.origin.y + addTop,
                                                  width: 44,
                                                  height: 44))
        cancelButton.setTitle("", for: .normal)
        cancelButton.setImage(UIImage(named: "close", in: Consts.bundle, compatibleWith: nil), for: .normal)
        cancelButton.addTargetClosure(closure: { (cancelUIButton) in
            hide(animated: true)
        })
        cancelButton.contentHorizontalAlignment = .right
        
        navView.addSubview(titleLabel)
        navView.addSubview(cancelButton)
        overlay.addSubview(navView)
        
        
        hideAction = closeAction
        currentOverlay = overlay
        UIView.animate(withDuration: 0.3, animations: {
            let imageSize = CGRect(x: overlay.frame.origin.x,
                                   y: overlay.frame.origin.y,
                                   width: overlay.frame.size.width,
                                   height: overlay.frame.size.height)
            imageCollection.updateFrame(frame: imageSize)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        }) { (finished) in
            imageCollection.hideFront()
        }
    }
    
    public static func showGallery(maxCount: Int,  action: @escaping imagePickerAction) {
        var passthroughWindow: UIWindow?
        for window in UIApplication.shared.windows {
            if window is PassthroughWindow {
                passthroughWindow = window
                break
            }
        }
        
        guard let currentMainWindow = passthroughWindow else {
            return
        }
        
        let overlay = ImageManager.createOverlay(overlayTarget: currentMainWindow)
        currentMainWindow.addSubview(overlay)
        currentMainWindow.bringSubviewToFront(overlay)
        
        let imageSelector = Consts.bundle.loadNibNamed("ImageSelector", owner: self, options: nil)?.first as! ImageSelector
        imageSelector.configure(frame: overlay.bounds, maxCount: maxCount, completion: action)
        imageSelector.center.y = imageSelector.center.y + imageSelector.frame.size.height
        overlay.addSubview(imageSelector)
        
        hideAction = nil
        currentOverlay = overlay
        UIView.animate(withDuration: 0.3, animations: {
            imageSelector.center.y = imageSelector.center.y - imageSelector.frame.size.height
        }) { (finished) in
            
        }
    }
    
    public static func showScreenshotTake(action: @escaping imagePickerAction, closeAction: @escaping closeAction) {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            return
        }
        
        let overlay = ImageManager.createOverlay(overlayTarget: currentMainWindow)
        currentMainWindow.addSubview(overlay)
        currentMainWindow.bringSubviewToFront(overlay)
        
        let imageCreator = Consts.bundle.loadNibNamed("ScreenshotCreator", owner: self, options: nil)?.first as! ScreenshotCreator
        imageCreator.alpha = 0
        imageCreator.configure(frame: overlay.bounds, completion: action)
        overlay.addSubview(imageCreator)
        
        hideAction = closeAction
        currentOverlay = overlay
        UIView.animate(withDuration: 0.3, animations: {
            imageCreator.alpha = 1
        }) { (finished) in
            imageCreator.showHandAnimation()
        }
    }
    
    //MARK: - Hide
    
    @objc private static func tapHide(_ gesture: UITapGestureRecognizer) {
        hide(animated: true)
    }
    
    public static func hide(animated: Bool, duration: TimeInterval = 0.2) {
        if currentOverlay != nil {
            if animated {
                UIView.animate(withDuration: duration, animations: {
                    currentOverlay?.alpha = (currentOverlay?.alpha)! > CGFloat(0) ? 0 : 1
                }) { (result) in
                    currentOverlay?.removeFromSuperview()
                    currentOverlay = nil
                }
            }
            else {
                currentOverlay?.removeFromSuperview()
                currentOverlay = nil
            }
            
            if hideAction != nil {
                hideAction!()
            }
        }
    }
    
    public static func dispose() {
        currentOverlay?.removeFromSuperview()
        currentOverlay = nil
        hideAction = nil
    }
}
