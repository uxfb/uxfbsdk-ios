//
//  UXFTextField.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 31.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

class UXFTextField: UITextField {
    
    @IBInspectable var contentLeftPadding:CGFloat = 0
    @IBInspectable var contentRightPadding:CGFloat = 0
    @IBInspectable var contentTopPadding:CGFloat = 0
    @IBInspectable var contentBottomPadding:CGFloat = 0
    
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
}
