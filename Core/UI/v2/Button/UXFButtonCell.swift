//
//  UXFButtonCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class UXFButtonCell: UXFBaseCell {
    @IBOutlet var button: UIButton!
    @IBOutlet var buttonWidth: NSLayoutConstraint!
    
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
        let isLandscape = UIApplication.shared.keyWindow?.windowScene?.interfaceOrientation.isLandscape ?? true
        if isLandscape {
            buttonWidth.constant = self.contentView.frame.width
        } else {
            buttonWidth.constant = 160
        }
        
        self.layoutIfNeeded()
    }
    
    @IBAction  func buttonTapped(_ sender: UIButton){
        if delegate != nil {
            delegate?.buttonTapped(field!, answer: [], refresh: true)
        }
    }
}
