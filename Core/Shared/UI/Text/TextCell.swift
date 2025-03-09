//
//  UXFTextCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class TextCell: BaseCell {
    private lazy var label: LinkLabel = {
        let label = LinkLabel()
        label.numberOfLines = 0
        return label
    }()
    
    override func setupSubviews() {
        contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func updateUI() {
        guard field != nil, theme != nil else {
            return
        }

        label.textColor = theme?.text02Color
        let value = field?.value ?? ""
        label.attributedText = TextPropertyManager.convert(value,
                                                           theme: theme!,
                                                           defaultFont: theme!.fontP1,
                                                           textProperties: nil, withRequired: false)
    }
}
