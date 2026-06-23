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
    
    private var buttonContainers: [UIView] = []
    private var buttonLabels: [UILabel] = []
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        
        for i in 0...10 {
            let (container, label) = createButton(value: i)
            stackView.addArrangedSubview(container)
            buttonContainers.append(container)
            buttonLabels.append(label)
        }
        
        return stackView
    }()
    
    private var currentValue: Int = -1
    
    private func createButton(value: Int) -> (UIView, UILabel) {
        let container = UIView()
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.masksToBounds = true
        container.tag = value
        
        let label = UILabel()
        label.text = "\(value)"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        
        return (container, label)
    }
    
    override func setupSubviews() {
        contentView.addSubview(buttonsStackView)
        contentView.addSubview(positiveLabel)
        contentView.addSubview(negativeLabel)
        
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        positiveLabel.translatesAutoresizingMaskIntoConstraints = false
        negativeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 40),
            
            negativeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            negativeLabel.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor, constant: 8),
            negativeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            negativeLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5, constant: -20),
            
            positiveLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            positiveLabel.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor, constant: 8),
            positiveLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            positiveLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5, constant: -20),
        ])
    }
    
    override func updateUI() {
        negativeLabel.font = theme?.fontP2
        positiveLabel.font = theme?.fontP2
        
        currentValue = Int(field?.answers.first ?? "") ?? -1
        
        guard field != nil, theme != nil else { return }
        
        updateButtonStyles()
        
        negativeLabel.textColor = theme?.text03Color
        positiveLabel.textColor = theme?.text03Color
        
        if let messages = field?.messages {
            negativeLabel.text = messages.negative
            positiveLabel.text = messages.positive
        }
    }
    
    private func updateButtonStyles() {
        let isError = field?.isError ?? false
        
        for i in 0...10 {
            let container = buttonContainers[i]
            let label = buttonLabels[i]
            
            if i == currentValue {
                container.backgroundColor = theme?.mainColor
                container.layer.borderColor = theme?.mainColor.cgColor
                label.textColor = .white
                label.font = theme?.fontP2
            } else if isError && currentValue == -1 {
                container.backgroundColor = .clear
                container.layer.borderColor = theme?.errorColorPrimary.cgColor
                label.textColor = theme?.text02Color
                label.font = theme?.fontP2
            } else {
                container.backgroundColor = .clear
                container.layer.borderColor = theme?.inputBorderColor.cgColor
                label.textColor = theme?.text02Color
                label.font = theme?.fontP2
            }
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func buttonTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        currentValue = view.tag
        updateButtonStyles()
        delegate?.fieldChanged(field!, answer: [String(currentValue)], refresh: true)
    }
}
