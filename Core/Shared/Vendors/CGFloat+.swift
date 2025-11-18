//
//  CGFloat+.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 15.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import Foundation
import UIKit

internal
extension CGFloat {
    static var leftArea: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                return window?.safeAreaInsets.left ?? 0
            }
            else {
                return 0
            }
        }
    }
    
    static var rightArea: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                return window?.safeAreaInsets.right ?? 0
            }
            else {
                return 0
            }
        }
    }
    
    static var topArea: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                return window?.safeAreaInsets.top ?? 0
            }
            else {
                return 0
            }
        }
    }
    
    static var bottomArea: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                return window?.safeAreaInsets.bottom ?? 0
            }
            else {
                return 0
            }
        }
    }
}
