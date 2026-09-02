//
//  UXFRatingCell.swift
//  UX Feedback SDK Demo
//
//  Created by Alexander Potemka on 12.12.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit

class RatingCell: BaseCell {
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
        
        for i in 1...10 {
            let (container, label) = createButton(value: i)
            stackView.addArrangedSubview(container)
            buttonContainers.append(container)
            buttonLabels.append(label)
        }
        
        return stackView
    }()
    
    private lazy var noAnswerView: NoAnswerView = {
        let view = NoAnswerView()
        view.isHidden = true
        view.onToggle = { [weak self] isOn in
            self?.noAnswerToggled(isOn)
        }
        return view
    }()

    private var currentValue: Int = 0
    private var maxValue: Int = 10

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
        contentView.addSubview(noAnswerView)

        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        positiveLabel.translatesAutoresizingMaskIntoConstraints = false
        negativeLabel.translatesAutoresizingMaskIntoConstraints = false
        noAnswerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 40),

            negativeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            negativeLabel.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor, constant: 8),
            negativeLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5, constant: -20),

            positiveLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            positiveLabel.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor, constant: 8),
            positiveLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5, constant: -20),

            noAnswerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            noAnswerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            noAnswerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            noAnswerView.heightAnchor.constraint(equalToConstant: NoAnswerView.height),
        ])
    }

    override func updateUI() {
        negativeLabel.font = theme?.fontP2
        positiveLabel.font = theme?.fontP2

        let noAnswer = isNoAnswerSelected
        currentValue = noAnswer ? 0 : Int(field?.answers.first ?? "") ?? 0
        maxValue = field?.ratingCount ?? 3

        guard field != nil, theme != nil else { return }

        noAnswerView.isHidden = noAnswerName == nil
        if let name = noAnswerName {
            noAnswerView.configure(title: name, theme: theme, isOn: noAnswer)
        }
        buttonsStackView.isUserInteractionEnabled = !noAnswer
        buttonsStackView.alpha = noAnswer ? 0.4 : 1

        for i in 0..<buttonContainers.count {
            let value = i + 1
            buttonContainers[i].isHidden = value > maxValue
        }

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
        
        for i in 0..<buttonContainers.count {
            let value = i + 1
            let container = buttonContainers[i]
            let label = buttonLabels[i]
            
            guard !container.isHidden else { continue }
            
            if value == currentValue {
                container.backgroundColor = theme?.mainColor
                container.layer.borderColor = theme?.mainColor.cgColor
                label.textColor = .white
                label.font = theme?.fontP2
            } else if isError && currentValue == 0 && !isNoAnswerSelected {
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
