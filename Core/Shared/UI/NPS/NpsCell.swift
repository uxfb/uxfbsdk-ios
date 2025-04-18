//
//  UXFNpsCell.swift
//  UX Feedback SDK Demo
//
//  Created by Alexander Potemka on 25.05.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit

class NpsCell: BaseCell {

    private lazy var negativeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private lazy var positiveLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .right
        return label
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(gestureRecognizer:)))
        slider.addGestureRecognizer(tapGestureRecognizer)
        
        slider.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        
        slider.value = 5
        slider.minimumValue = 0
        slider.maximumValue = 10
        return slider
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        
        for i in 0...10 {
            let label = VerticalAlignedLabel()
            label.text = "\(i)"
            label.tag = i + 1
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
        }
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private var sliderView = SliderView(frame: CGRect(origin: .zero,
                                                         size: CGSize(width: 48,
                                                                      height: 48)))
    
    private var currentValue: Int = -1
    
    override func setupSubviews() {
        contentView.addSubview(stackView)
        contentView.addSubview(slider)
        contentView.addSubview(positiveLabel)
        contentView.addSubview(negativeLabel)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        positiveLabel.translatesAutoresizingMaskIntoConstraints = false
        negativeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalToConstant: 28),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            slider.heightAnchor.constraint(equalToConstant: 48),
            slider.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            slider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            slider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            
            negativeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            negativeLabel.topAnchor.constraint(equalTo: slider.bottomAnchor),
            negativeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            negativeLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5, constant: -20),
            
            positiveLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            positiveLabel.topAnchor.constraint(equalTo: slider.bottomAnchor),
            positiveLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            positiveLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5, constant: -20),
        ])
    }
    
    override func updateUI() {
        negativeLabel.font = theme?.fontP2
        positiveLabel.font = theme?.fontP2
        
        currentValue = Int(field?.answers.first ?? "") ?? -1
        
        guard field != nil, theme != nil else {
            return
        }
        
        initLabels()
        
        sliderView.frame.size.width = max(self.bounds.width / CGFloat(11), 48)
        
        slider.setValue(Float(currentValue == -1 ? 0 : currentValue), animated: false)
        
        
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
        let k = UIScreen.main.bounds.width > 375 ? 1 : 0.92
        
        let calculatedValue = currentValue == -1 ? 0 : currentValue
        for i in 0...10 {
            if let label = contentView.viewWithTag(i+1) as? VerticalAlignedLabel {
                if i == calculatedValue {
                    label.textColor = currentValue == -1 ? theme?.text03Color : theme?.mainColor
                    label.font = theme?.fontH1.withSize((theme?.fontH1.pointSize ?? .bigFontSize) * k)
                    label.contentMode = .bottom
                } else if i == calculatedValue-1 || i == calculatedValue+1 {
                    label.textColor = currentValue == -1 ? theme?.text03Color : theme?.text02Color
                    label.font = theme?.fontP1.withSize((theme?.fontP1.pointSize ?? .mediumFontSize) * k)
                    label.contentMode = .bottom
                }
                else {
                    label.textColor = theme?.text03Color
                    label.font = theme?.fontP2.withSize((theme?.fontP2.pointSize ?? .smallFontSize) * k)
                    label.contentMode = .bottom
                }
            }
        }
    }
    
    override func rotated() {
        slider.setNeedsLayout()
        slider.layoutIfNeeded()
    }
    
    private func updateLabels() {
        
        let k = UIScreen.main.bounds.width > 375 ? 1 : 0.92
        
        setActiveStyle()
        let nearestValue = Int(round(slider.value))
        let firstDiff: CGFloat = .bigFontSize * k - .mediumFontSize * k
        let secondDiff: CGFloat = .mediumFontSize * k - .smallFontSize * k
        
        for i in 0...10 {
            if let label = contentView.viewWithTag(i+1) as? VerticalAlignedLabel {
                let diff = abs(Float(i) - slider.value)
                if diff == 0 {
                    label.textColor = theme?.mainColor
                    label.font = theme?.fontH1.withSize((theme?.fontH1.pointSize ?? .bigFontSize) * k)
                    label.contentMode = .bottom
                } else if diff <= 1 {
                    label.textColor = i == nearestValue ? theme?.mainColor : theme?.text02Color
                    let font = theme?.fontP1.withSize((.mediumFontSize + firstDiff * CGFloat(1-diff)) * k)
                    label.font = font
                    label.contentMode = .bottom
                } else if diff <= 2 {
                    label.textColor = (abs(nearestValue-i) == 1) ? theme?.text02Color : theme?.text03Color
                    let font = theme?.fontP2.withSize((.smallFontSize + secondDiff * CGFloat(2-diff)) * k)
                    label.font = font
                    label.contentMode = .bottom
                } else {
                    label.textColor = theme?.text03Color
                    label.font = theme?.fontP2.withSize((theme?.fontP2.pointSize ?? .smallFontSize) * k)
                    label.contentMode = .bottom
                }
            }
            
        }
    }
    
    
    //MARK: - Actions
    
    @objc
    private func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.contentView)

        let positionOfSlider: CGPoint = slider.frame.origin
        let widthOfSlider: CGFloat = slider.frame.size.width
        let itemWidth = widthOfSlider / CGFloat(11)
        
        let modValue = Int(pointTapped.x - positionOfSlider.x) / Int(itemWidth)

        slider.setValue(Float(modValue), animated: true)
        roundSlider()
    }
    
    @objc
    private func valueChanged(_ sender: Any) {
        updateLabels()
    }
    
    @objc
    private func touchUpInside(_ sender: Any) {
        roundSlider()
    }
    
    @objc
    private func touchUpOutside(_ sender: Any) {
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
