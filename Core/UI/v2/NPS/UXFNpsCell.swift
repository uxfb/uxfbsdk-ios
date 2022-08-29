//
//  UXFNpsCell.swift
//  UX Feedback SDK Demo
//
//  Created by Alexander Potemka on 25.05.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit

class UXFSliderView: UIView {
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
        
        let bundle = Bundle(for: UXFeedback.self)
        
        leftArrowView.image = UIImage(named: "slider_left",
                                      in: bundle,
                                      compatibleWith: nil)
        rightArrowView.image = UIImage(named: "slider_right",
                                       in: bundle, compatibleWith: nil)
            
        
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
    
    func setStyle(_ sliderStyle: SliderStyle, theme: UXFBTheme) {
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

class UXFNpsCell: UXFBaseCell {

    @IBOutlet var negativeLabel: UILabel! {
        didSet {
            negativeLabel.numberOfLines = 2
        }
    }
    @IBOutlet var positiveLabel: UILabel!{
        didSet {
            positiveLabel.numberOfLines = 2
        }
    }
    @IBOutlet var slider: UISlider!
    
    private var sliderView = UXFSliderView(frame: CGRect(origin: .zero,
                                                         size: CGSize(width: 48,
                                                                      height: 48)))
    
    private let bundle = Bundle(for: UXFeedback.self)
    
    private var currentValue: Int = -1
    
    override func updateUI() {
        
        currentValue = Int(field?.answers.first ?? "") ?? -1
        
        guard field != nil, theme != nil else {
            return
        }
        
        initLabels()
        
        sliderView.frame.size.width = max(self.bounds.width / CGFloat(11), 48)
        
        slider.setValue(Float(currentValue == -1 ? 5 : currentValue), animated: false)
        
        
        if field?.isError ?? false && currentValue == -1 {
            setErrorStyle()
        } else if currentValue == -1 {
            setInactiveStyle()
        } else {
            setActiveStyle()
        }
        
        negativeLabel.textColor = theme?.text03Color
        positiveLabel.textColor = theme?.text03Color
        
        if let messages = field?.uiData["messages"] as? [String: String] {
            negativeLabel.text = messages["negative"]
            positiveLabel.text = messages["positive"]
        }
    }
    
    //MARK :- Styles
    
    private func setInactiveStyle() {
        slider.minimumTrackTintColor = theme?.iconColor.withAlphaComponent(0.3)
        slider.maximumTrackTintColor = theme?.iconColor.withAlphaComponent(0.3)
        
        sliderView.setStyle(.inactive, theme: theme!)
        slider.setThumbImage(sliderView.asImage(), for: .normal)
    }
    
    private func setActiveStyle() {
        slider.minimumTrackTintColor = theme?.mainColor.withAlphaComponent(0.3)
        slider.maximumTrackTintColor = theme?.mainColor.withAlphaComponent(0.3)
        
        sliderView.setStyle(.active, theme: theme!)
        slider.setThumbImage(sliderView.asImage(), for: .normal)
    }
    
    private func setErrorStyle() {
        slider.minimumTrackTintColor = theme?.errorColorPrimary.withAlphaComponent(0.3)
        slider.maximumTrackTintColor = theme?.errorColorPrimary.withAlphaComponent(0.3)
        
        sliderView.setStyle(.error, theme: theme!)
        slider.setThumbImage(sliderView.asImage(), for: .normal)
    }
    
    private func initLabels() {
        let calculatedValue = currentValue == -1 ? 5 : currentValue
        for i in 0...10 {
            if let label = contentView.viewWithTag(i+1) as? VerticalAlignedLabel {
                if i == calculatedValue {
                    label.textColor = currentValue == -1 ? theme?.text03Color : theme?.mainColor
                    label.font = theme?.mediumFont(size: .bigFontSize)
                } else if i == calculatedValue-1 || i == calculatedValue+1 {
                    label.textColor = currentValue == -1 ? theme?.text03Color : theme?.text02Color
                    label.font = theme?.regularFont(size: .mediumFontSize)
                    label.contentMode = .bottom
                }
                else {
                    label.textColor = theme?.text03Color
                    label.font = theme?.regularFont(size: .smallFontSize)
                    label.contentMode = .bottom
                }
            }
            
        }
    }
    
    private func updateLabels() {
        setActiveStyle()
        let nearestValue = Int(round(slider.value))
        let firstDiff: CGFloat = .bigFontSize - .mediumFontSize
        let secondDiff: CGFloat = .mediumFontSize - .smallFontSize
        
        for i in 0...10 {
            if let label = contentView.viewWithTag(i+1) as? VerticalAlignedLabel {
                let diff = abs(Float(i) - slider.value)
                if diff == 0 {
                    label.textColor = theme?.mainColor
                    label.font = theme?.mediumFont(size: .bigFontSize)
                    label.contentMode = .center
                } else if diff <= 1 {
                    label.textColor = i == nearestValue ? theme?.mainColor : theme?.text02Color
                    label.font = theme?.regularFont(size: .mediumFontSize + firstDiff * CGFloat(1-diff))
                    label.contentMode = .bottom
                } else if diff <= 2 {
                    label.textColor = (abs(nearestValue-i) == 1) ? theme?.text02Color : theme?.text03Color
                    label.font = theme?.regularFont(size: .smallFontSize + secondDiff * CGFloat(2-diff))
                    label.contentMode = .bottom
                } else {
                    label.textColor = theme?.text03Color
                    label.font = theme?.regularFont(size: .smallFontSize)
                    label.contentMode = .bottom
                }
            }
            
        }
    }
    
    
    //MARK :- Actions
    
    @IBAction func valueChanged(_ sender: Any) {
        updateLabels()
    }
    
    @IBAction func touchUpInside(_ sender: Any) {
        roundSlider()
    }
    
    @IBAction func touchUpOutside(_ sender: Any) {
        roundSlider()
    }
    
    private func roundSlider() {
        let newValue = round(slider.value)
        slider.setValue(newValue, animated: true)
        currentValue = Int(newValue)
        updateLabels()
        
        if self.delegate != nil {
            self.delegate?.fieldChanged(self.field!, answer: [String(self.currentValue)], refresh: true)
        }
        
    }
}
