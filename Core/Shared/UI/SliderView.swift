//
//  Untitled.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 12.02.2025.
//  Copyright © 2025 UXF. All rights reserved.
//
import UIKit

class SliderView: UIView {
    private var bigBorderView: UIView = UIView()
    private var smallBorderView: UIView = UIView()
    private var imageContentView: UIView = UIView()
    
    private let leftArrowView = UIImageView(frame: CGRect(origin: .zero,
                                                  size: CGSize(width: 5,
                                                               height: 10)))
    private let rightArrowView = UIImageView(frame: CGRect(origin: .zero,
                                                   size: CGSize(width: 5,
                                                                height: 10)))
    
    private let sliderWidth: CGFloat = 48
    private let sliderHeight: CGFloat = 48
    
    enum SliderStyle: Int {
        case inactive = 0
        case active = 1
        case error = 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let baseRadius = sliderWidth / 2
        self.clipsToBounds = false
        
        bigBorderView.frame.size = CGSize(width: sliderWidth,
                                            height: sliderHeight)
        bigBorderView.center = self.center
        bigBorderView.layer.cornerRadius = baseRadius
        smallBorderView.frame.size = CGSize(width: sliderWidth - 8,
                                            height: sliderHeight - 8)
        smallBorderView.layer.cornerRadius = baseRadius - 4
        smallBorderView.center = bigBorderView.center
        imageContentView.frame.size = CGSize(width: sliderWidth - 14,
                                            height: sliderHeight - 14)
        imageContentView.center = bigBorderView.center
        imageContentView.layer.cornerRadius = baseRadius - 7
        imageContentView.backgroundColor = .white
        
        leftArrowView.image = UIImage(named: "slider_left",
                                      in: Consts.bundle,
                                      compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        rightArrowView.image = UIImage(named: "slider_right",
                                       in: Consts.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            
        
        leftArrowView.center = CGPoint(x: (sliderWidth - 14) / 2 - 3.5,
                                       y: (sliderHeight - 14) / 2)
        rightArrowView.center = CGPoint(x: (sliderWidth - 14) / 2 + 3.5,
                                       y: (sliderHeight - 14) / 2)
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.addSubview(bigBorderView)
        self.addSubview(smallBorderView)
        imageContentView.addSubview(leftArrowView)
        imageContentView.addSubview(rightArrowView)
        self.addSubview(imageContentView)
    }
    
    func setStyle(_ sliderStyle: SliderStyle, theme: ThemeProtocol) {
        imageContentView.backgroundColor = theme.controlIconColor
        leftArrowView.tintColor = theme.iconColor
        rightArrowView.tintColor = theme.iconColor
        switch sliderStyle {
        case .inactive:
            bigBorderView.backgroundColor = theme.iconColor.withAlphaComponent(0.3)
            smallBorderView.backgroundColor = theme.iconColor
            
        case .active:
            bigBorderView.backgroundColor = theme.mainColor.withAlphaComponent(0.3)
            smallBorderView.backgroundColor = theme.mainColor
        case .error:
            bigBorderView.backgroundColor = theme.errorColorPrimary.withAlphaComponent(0.3)
            smallBorderView.backgroundColor = theme.errorColorPrimary
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        bigBorderView.center = center
        smallBorderView.center = center
        imageContentView.center = center
    }
}
