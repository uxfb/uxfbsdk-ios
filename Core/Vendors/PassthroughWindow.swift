//
//  PassthroughWindow.swift
//  UXFeedbackSDK
//
//  Created by Dmitry on 12.02.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import Foundation

class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}

class PassthroughToWindowView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = super.hitTest(point, with: event)
        if view != self {
            return view
        }

        while !(view is PassthroughWindow) {
            view = view?.superview
        }
        return view
    }
}

class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
