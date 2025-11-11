//
//  UXFInputCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class InputCell: BaseCell {
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .clear
        view.delegate = self
        view.textContainerInset = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 6)
        return view
    }()
    
    private var comment = ""
    
    override func setupSubviews() {
        contentView.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func updateUI() {
        let answer = field?.answers.first
        comment = answer ?? ""
        
        textView.textColor = comment.isEmpty ? theme?.text03Color : theme?.text01Color
        textView.layer.cornerRadius = theme?.btnBorderRadius ?? 4
        textView.layer.masksToBounds = true
        textView.backgroundColor = theme?.inputBgColor ?? .white
        
        textView.font = theme?.fontP1
        
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

extension InputCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if delegate != nil {
            delegate?.textChanged(field!, answer: [newText])
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.didBeginEditing(field!)
        textView.borderColor = theme?.mainColor
        
        if comment == "" {
            textView.text = nil
            textView.textColor = theme?.text01Color
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.didEndEditing(field!)
        textView.borderColor = theme?.inputBorderColor
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
