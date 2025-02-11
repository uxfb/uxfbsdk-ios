//
//  UXFHeaderCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class HeaderCell: BaseCell {
    
    private lazy var label: UILabel = {
        let label = UILabel()
        
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
        label.font = theme!.fontH1
        label.text = field?.value
        label.textColor = theme?.text01Color
        label.textAlignment = (field?.isLastPage ?? false) ? .center : .left
    }
}

