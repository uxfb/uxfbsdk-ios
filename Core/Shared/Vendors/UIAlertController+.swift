//
//  UIAlertController+.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 12.10.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit

extension UIAlertController {
   
    private static var globalPresentationWindow: UIWindow?
   
    func presentGlobally(animated: Bool, completion: (() -> Void)?) {
        UIAlertController.globalPresentationWindow = UIWindow(frame: UIScreen.main.bounds)
        UIAlertController.globalPresentationWindow?.rootViewController = UIViewController()
        UIAlertController.globalPresentationWindow?.windowLevel = UIWindow.Level.alert + 12
        UIAlertController.globalPresentationWindow?.backgroundColor = .clear
        UIAlertController.globalPresentationWindow?.makeKeyAndVisible()
        UIAlertController.globalPresentationWindow?.rootViewController?.present(self, animated: animated, completion: completion)
    }
    
    func dismissGlobally(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.dismiss(animated: flag) {
            UIAlertController.globalPresentationWindow?.isHidden = true
            UIAlertController.globalPresentationWindow?.resignKey()
            UIAlertController.globalPresentationWindow = nil
        }
    }
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        for window in UIApplication.shared.windows {
            if window is PassthroughWindow {
//                window.makeKeyAndVisible()
                UIAlertController.globalPresentationWindow?.isHidden = true
                UIAlertController.globalPresentationWindow?.resignKey()
                UIAlertController.globalPresentationWindow = nil
                break
            }
        }
    }
}
