//
//  UXFInputCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class UXFInputCell: UXFBaseCell {
    @IBOutlet var textView: UITextView! {
        didSet {
            textView.backgroundColor = .clear
            textView.delegate = self
            textView.textContainerInset = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 6)
        }
    }
    
    private var comment = ""
    
    override func updateUI() {
        let answer = field?.answers.first
        comment = answer ?? ""
        
        textView.textColor = comment.isEmpty ? theme?.text03Color : theme?.text01Color
        textView.layer.cornerRadius = theme?.btnBorderRadius ?? 4
        textView.layer.masksToBounds = true
        textView.backgroundColor = theme?.inputBgColor ?? .white
        
        textView.font = theme?.regularFont(size: .mediumFontSize)
        
        textView.text = comment.isEmpty ? field?.uiData["placeholder"] as? String : comment
        
        let required = field?.uiData["required"] as? Bool ?? false
        if required && field!.isError && comment.isEmpty {
            textView.borderColor = theme?.errorColorSecondary
            textView.borderWidth = 2
        }
        else {
            textView.borderColor = theme?.inputBorderColor
            textView.borderWidth = 1
        }
    }
}

extension UXFInputCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if delegate != nil {
            delegate?.textChanged(field!, answer: [newText], refresh: false)
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.borderColor = theme?.inputBorderColor
        
        if comment == "" {
            textView.text = nil
            textView.textColor = theme?.text01Color
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            comment = ""
            textView.text = field?.uiData["placeholder"] as? String
            textView.textColor = theme?.text03Color
        }
        else {
            comment = textView.text
            textView.textColor = theme?.text01Color
        }
        
        if delegate != nil {
            delegate?.fieldChanged(field!, answer: comment != "" ? [comment] : [], refresh: true)
        }
    }
}
