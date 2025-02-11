//
//  UXFButtonCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class ButtonCell: BaseCell {
    private lazy var button: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    var buttonWidth: NSLayoutConstraint!
    
    override func setupSubviews() {
        contentView.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        buttonWidth = NSLayoutConstraint(item: button,
                                         attribute: .width,
                                         relatedBy: .equal, toItem: nil,
                                         attribute: .height,
                                         multiplier: 1, constant: 160)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 40),
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            buttonWidth
        ])
    }
    
    override func updateUI() {
        guard field != nil, theme != nil else {
            return
        }
        button.setTitle(field!.value, for: .normal)
        button.titleLabel?.font = theme?.fontBtn
        button.layer.cornerRadius = theme!.btnBorderRadius
        button.layer.masksToBounds = true
        button.setBackgroundImage(UIImage(color: theme!.btnBgColor), for: .normal)
        button.setBackgroundImage(UIImage(color: theme!.btnBgColorActive), for: .highlighted)
        
        button.isEnabled = !(field?.isError ?? false)
        
        button.setTitleColor(theme!.btnTextColor, for: .normal)
        var isLandscape = true
        if #available(iOS 13.0, *) {
            isLandscape = UIApplication.shared.keyWindow?.windowScene?.interfaceOrientation.isLandscape ?? true
        } else {
            isLandscape = UIApplication.shared.statusBarOrientation.isLandscape
        }
        if isLandscape {
            buttonWidth.constant = self.contentView.frame.width - 32
        } else {
            buttonWidth.constant = 160
        }
        
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var isLandscape = true
        if #available(iOS 13.0, *) {
            isLandscape = UIApplication.shared.keyWindow?.windowScene?.interfaceOrientation.isLandscape ?? true
        } else {
            isLandscape = UIApplication.shared.statusBarOrientation.isLandscape
        }
        if isLandscape {
            buttonWidth.constant = self.contentView.frame.width - 32
        } else {
            buttonWidth.constant = 160
        }
    }
    
    @objc
    private func buttonTapped() {
        if delegate != nil {
            delegate?.buttonTapped(field!, answer: [], refresh: true)
        }
    }
}
