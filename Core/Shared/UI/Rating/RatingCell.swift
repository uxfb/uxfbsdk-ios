//
//  UXFRatingCell.swift
//  UX Feedback SDK Demo
//
//  Created by Alexander Potemka on 12.12.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit

class RatingCell: BaseCell {
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
    @IBOutlet var slider: UISlider! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(gestureRecognizer:)))
            self.slider.addGestureRecognizer(tapGestureRecognizer)
            
        }
    }
    
    private var sliderView = SliderView(frame: CGRect(origin: .zero,
                                                         size: CGSize(width: 48,
                                                                      height: 48)))
    
    private var currentValue: Int = 0
    private var defaultValue: Int = 0
    private var maxValue: Int = 0
    
    override func updateUI() {
        negativeLabel.font = theme?.fontP2
        positiveLabel.font = theme?.fontP2
        
        currentValue = Int(field?.answers.first ?? "") ?? 0
        maxValue = (field?.uiData["ratingCount"] as? Int) ?? 3
        let halfValue = (Double(maxValue)/2).rounded(.up)
        defaultValue = Int(halfValue)
        guard field != nil, theme != nil else {
            return
        }
        
        sliderView.frame.size.width = max(self.bounds.width / CGFloat(maxValue), 48)
        initLabels()
        
        slider.maximumValue = Float(maxValue)
        slider.setValue(Float(currentValue == 0 ? defaultValue : currentValue), animated: false)
        
        if field?.isError ?? false && currentValue == 0 {
            setErrorStyle()
        }
        else if currentValue == 0 {
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
        let calculatedValue = currentValue == 0 ? defaultValue : currentValue
        for i in 1...10 {
            if let label = contentView.viewWithTag(i) as? VerticalAlignedLabel {
                label.text = "\(i)"
                label.backgroundColor = .clear
                label.isHidden = false
                if i > maxValue {
                    label.isHidden = true
                }
                if i == calculatedValue {
                    label.textColor = currentValue == 0 ? theme?.text03Color : theme?.mainColor
                    label.font = theme?.fontH1
                } else if i == calculatedValue-1 || i == calculatedValue+1 {
                    label.textColor = currentValue == 0 ? theme?.text03Color : theme?.text02Color
                    label.font = theme?.fontP1
                    label.contentMode = .bottom
                }
                else {
                    label.textColor = theme?.text03Color
                    label.font = theme?.fontP2
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
        
        for i in 1...maxValue {
            if let label = contentView.viewWithTag(i) as? VerticalAlignedLabel {
                let diff = abs(Float(i) - slider.value)
                if diff == 0 {
                    label.textColor = theme?.mainColor
                    label.font = theme?.fontH1
                    label.contentMode = .center
                } else if diff <= 1 {
                    label.textColor = i == nearestValue ? theme?.mainColor : theme?.text02Color
                    let font = theme?.fontP1.withSize(.mediumFontSize + firstDiff * CGFloat(1-diff))
                    label.font = font
                    label.contentMode = .bottom
                } else if diff <= 2 {
                    label.textColor = (abs(nearestValue-i) == 1) ? theme?.text02Color : theme?.text03Color
                    let font = theme?.fontP2.withSize(.smallFontSize + secondDiff * CGFloat(2-diff))
                    label.font = font
                    label.contentMode = .bottom
                } else {
                    label.textColor = theme?.text03Color
                    label.font = theme?.fontP2
                    label.contentMode = .bottom
                }
            }
        }
    }
    
    
    //MARK :- Actions
    @objc
    private func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.contentView)

        let positionOfSlider: CGPoint = slider.frame.origin
        let widthOfSlider: CGFloat = slider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(slider.maximumValue) / widthOfSlider)

        slider.setValue(Float(newValue), animated: true)
        roundSlider()
    }
    
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
