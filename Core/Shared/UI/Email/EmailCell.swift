//
//  UXFEmailCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class EmailCell: BaseCell, UITextFieldDelegate {
    private lazy var textField: UITextField = {
        let view = UITextField()
        view.delegate = self
        view.spellCheckingType = .no
        view.autocorrectionType = .no
        return view
    }()
    
    override func setupSubviews() {
        contentView.addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func updateUI() {
        guard field != nil, theme != nil else {
            return
        }
        let placeholder = field?.uiData["placeholder"] as? String
        textField.attributedPlaceholder = NSAttributedString(string: placeholder ?? "",
                                                             attributes: [NSAttributedString.Key.foregroundColor: theme?.text03Color ?? .lightGray])
        textField.textColor = theme?.text01Color
        textField.layer.cornerRadius = theme?.btnBorderRadius ?? 4
        textField.layer.masksToBounds = true
        textField.backgroundColor = theme?.inputBgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        textField.leftViewMode = .always
        textField.keyboardType = .emailAddress
        textField.font = theme?.fontP1
        let answer = field?.answers.first ?? ""
        textField.text = answer
        
        let required = field?.uiData["required"] as? Bool ?? false
        if required && field!.isError && answer.isEmpty {
            textField.borderColor = theme?.errorColorSecondary
            textField.layer.borderWidth = 2
        }
        else {
            textField.layer.borderWidth = 1
            textField.layer.borderColor = theme?.inputBorderColor.cgColor
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.didBeginEditing(field!)
//        textField.layer.borderColor = theme?.inputBorderColor.cgColor
        textField.borderColor = theme?.mainColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            if delegate != nil {
                delegate?.fieldChanged(field!, answer: [updatedText], refresh: false)
            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.borderColor = theme?.inputBorderColor
        if delegate != nil {
            let email = textField.text!
            delegate?.fieldChanged(field!, answer: email != "" ? [email] : [], refresh: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

