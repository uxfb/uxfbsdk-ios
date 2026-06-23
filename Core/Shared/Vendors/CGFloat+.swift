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
    private static var activeWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    static var leftArea: CGFloat {
        return activeWindow?.safeAreaInsets.left ?? 0
    }
    
    static var rightArea: CGFloat {
        return activeWindow?.safeAreaInsets.right ?? 0
    }
    
    static var topArea: CGFloat {
        return activeWindow?.safeAreaInsets.top ?? 0
    }
    
    static var bottomArea: CGFloat {
        return activeWindow?.safeAreaInsets.bottom ?? 0
    }
}
