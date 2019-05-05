//
//  UXFTextField.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 31.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

enum UXFTextFieldState{
    case normal
    case alert
    case input
}

class UXFTextField: UITextField {
    
    @IBInspectable var contentLeftPadding:CGFloat = 0
    @IBInspectable var contentRightPadding:CGFloat = 0
    @IBInspectable var contentTopPadding:CGFloat = 0
    @IBInspectable var contentBottomPadding:CGFloat = 0
    
    var didChange: ((UXFTextField, String?) -> Void)!
    
    var inputState: UXFTextFieldState = UXFTextFieldState.normal {
        didSet{
            switch inputState {
            case .normal:
                layer.borderColor = UIColor.clear.cgColor
                break
            case .alert:
                layer.borderColor = UIColor("#E91436").cgColor
                break
            case .input:
                layer.borderColor = UIColor("#1F45EB").cgColor
                break
            }
            layer.masksToBounds = true
            layer.borderWidth = 0.5
        }
    }
    
    var contentPadding: UIEdgeInsets{
        return  UIEdgeInsets(top: contentTopPadding,
                             left: contentLeftPadding,
                             bottom: contentBottomPadding,
                             right: contentRightPadding)
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: contentPadding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: contentPadding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: contentPadding)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
    }
    
    @objc func didChangeText(_ sender: UITextField) {
        weak var textField = sender as? UXFTextField
        didChange(textField!, textField!.text)
    }
}
