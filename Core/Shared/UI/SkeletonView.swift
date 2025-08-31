//
//  SkeletonView.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 27.07.2025.
//  Copyright © 2025 UXF. All rights reserved.
//

import UIKit

class SkeletonView: UIView {
    private var gradientLayer: CAGradientLayer!
    
    var colors: [CGColor] = [UIColor.init("#EDEDED").cgColor,
                                     UIColor.init("#F8F8FA").cgColor,
                                     UIColor.init("#EDEDED").cgColor]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSkeleton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSkeleton()
    }
    
    private func setupSkeleton() {
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmer")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 4
    }
}

extension UIImageView {
    func showSkeleton(baseColor: UIColor?, shineColor: UIColor?) {
        let skeletonView = SkeletonView(frame: bounds)
        if let baseColor = baseColor,
           let shineColor = shineColor {
            skeletonView.colors = [baseColor.cgColor, shineColor.cgColor, baseColor.cgColor]
        }
        
        skeletonView.layer.cornerRadius = layer.cornerRadius
        skeletonView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(skeletonView)
        skeletonView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            skeletonView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            skeletonView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            skeletonView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            skeletonView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
        ])
    }
    
    func hideSkeleton() {
        DispatchQueue.main.async {
            self.subviews.forEach { view in
                if view is SkeletonView {
                    view.removeFromSuperview()
                }
            }
        }
    }
}
