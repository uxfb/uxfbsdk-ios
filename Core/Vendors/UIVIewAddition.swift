//
//  UIVIewAddition.swift
//  Portal DA mobile
//
//  Created by Dmitry Kudryavtsev on 31/08/2018.
//  Copyright © 2018 ABK. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }
        
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        
        return nil
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension UIView {
    func addShadowAndRoundCorner(cornerRadius : CGFloat) {
        self.layer.shadowOffset = CGSize(width: 1.0, height: 4.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 6.0
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        self.layer.masksToBounds = false
        self.layer.cornerRadius = cornerRadius
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}


class AnimatingShadowView: UIView {

    struct DropShadowParameters {
        var shadowOpacity: Float = 0
        var shadowColor: UIColor? = .black
        var shadowRadius: CGFloat = 0
        var shadowOffset: CGSize = .zero

        static let defaultParameters = DropShadowParameters(shadowOpacity: 0.15,
                                                            shadowColor: .black,
                                                            shadowRadius: 5,
                                                            shadowOffset: CGSize(width: 0, height: 1))
    }

    @IBOutlet weak var contentView: UIView!  // no sense in have a shadowView without content!

    var shadowParameters: DropShadowParameters = DropShadowParameters.defaultParameters

    private func apply(dropShadow: DropShadowParameters) {
        let layer = self.layer
        layer.shadowColor = dropShadow.shadowColor?.cgColor
        layer.shadowOffset = dropShadow.shadowOffset
        layer.shadowOpacity = dropShadow.shadowOpacity
        layer.shadowRadius = dropShadow.shadowRadius
        layer.masksToBounds = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let layer = self.layer
        layer.backgroundColor = nil

        let contentLayer = self.contentView.layer
        assert(contentLayer.superlayer == layer, "contentView must be a direct subview of AnimatingShadowView!")

        self.apply(dropShadow: self.shadowParameters)

        let radius = contentLayer.cornerRadius
        layer.shadowPath = UIBezierPath(roundedRect: contentLayer.frame, cornerRadius: radius).cgPath
    }

    override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        guard event == "shadowPath" else {
            return super.action(for: layer, forKey: event)
        }

        guard let priorPath = layer.shadowPath else {
            return super.action(for: layer, forKey: event)
        }

        guard let sizeAnimation = layer.animation(forKey: "bounds.size") as? CABasicAnimation else {
            return super.action(for: layer, forKey: event)
        }

        let animation = sizeAnimation.copy() as! CABasicAnimation
        animation.keyPath = "shadowPath"
        let action = ShadowingViewAction()
        action.priorPath = priorPath
        action.pendingAnimation = animation
        return action
    }
}


private class ShadowingViewAction: NSObject, CAAction {
    var pendingAnimation: CABasicAnimation? = nil
    var priorPath: CGPath? = nil

    // CAAction Protocol
    func run(forKey event: String, object anObject: Any, arguments dict: [AnyHashable : Any]?) {
        guard let layer = anObject as? CALayer, let animation = self.pendingAnimation else {
            return
        }

        animation.fromValue = self.priorPath
        animation.toValue = layer.shadowPath
        layer.add(animation, forKey: "shadowPath")
    }
} 
