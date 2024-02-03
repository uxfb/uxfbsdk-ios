//
//  PrivacyView.swift
//  UX Feedback SDK Demo
//
//  Created by Alexander Potemka on 03.09.2023.
//  Copyright © 2023 UXF. All rights reserved.
//

import UIKit

protocol PrivacyDelegate {
    func checked(_ value: Bool?)
    func tapPrivacy()
}

class PrivacyView: UIView {
    private let privacyImageBgView = UIView()
    private let privacyImageView = UIImageView()
    private let privacyLabel = HtmlLabel()
    private let privacyWarningLabel = UILabel()
    private var delegate: PrivacyDelegate?
    private var theme: ThemeProtocol?
    
    init(frame: CGRect, theme: ThemeProtocol, delegate: PrivacyDelegate?) {
        super.init(frame: frame)
        self.delegate = delegate
        self.theme = theme
        self.backgroundColor = theme.inputBgColor
        privacyLabel.defaultColor = theme.text03Color
        privacyLabel.linkColor = theme.btnBgColor
        privacyLabel.textFont = theme.fontP2
        privacyLabel.numberOfLines = 0
        privacyWarningLabel.font = theme.fontP2
        privacyWarningLabel.textColor = theme.errorColorPrimary
        privacyWarningLabel.numberOfLines = 0
        privacyLabel.delegate = self
        privacyImageView.contentMode = .center
        self.isOpaque = false
        self.addSubview(privacyImageBgView)
        privacyImageBgView.addSubview(privacyImageView)
        self.addSubview(privacyLabel)
        self.addSubview(privacyWarningLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(checkboxTapped))
        privacyImageBgView.isUserInteractionEnabled = true
        privacyImageBgView.addGestureRecognizer(tapGesture)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func preparePrivacy(_ type: String) {
        privacyImageBgView.layer.cornerRadius = 2
        privacyImageBgView.layer.masksToBounds = true
        privacyImageView.layer.cornerRadius = 2
        privacyImageView.layer.borderColor = UIColor.clear.cgColor
        privacyImageView.layer.borderWidth = 2
        privacyImageView.layer.masksToBounds = true
        
        switch type {
        case "checkboxEnabled":
            delegate?.checked(true)
            
        case "checkboxDisabled":
            delegate?.checked(false)
            
        case "text":
            delegate?.checked(true)
            
        default:
            delegate?.checked(nil)

        }
    }
    
    func fillPrivacy(_ type: String, checked: Bool) {
        switch type {
        case "checkboxEnabled", "checkboxDisabled":
            if checked {
                privacyImageView.layer.borderColor = UIColor.clear.cgColor
                privacyImageView.image = UIImage(named: "check_symbol",
                                                 in: Consts.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                
                privacyImageView.tintColor = theme?.controlIconColor
                privacyImageView.backgroundColor = theme?.mainColor
                privacyImageBgView.backgroundColor = theme?.mainColor.withAlphaComponent(0.2)
            } else {
                privacyImageView.layer.borderColor = theme?.iconColor.cgColor ?? UIColor.clear.cgColor
                privacyImageView.image = nil
                privacyImageBgView.backgroundColor = .clear
                privacyImageView.backgroundColor = .clear
            }
            
        case "text":
            privacyImageView.layer.borderColor = UIColor.clear.cgColor
            privacyImageView.image = UIImage(named: "lock",
                                             in: Consts.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            privacyImageView.tintColor = theme?.iconColor
            privacyImageBgView.backgroundColor = .clear
            privacyImageView.backgroundColor = .clear
            
        default:
            break
        }
    }
    
    func fillTexts(_ text: String, warning: String) {
        privacyLabel.html = text
        privacyWarningLabel.text = warning
    }
    
    private func setupConstraints() {
        privacyImageBgView.translatesAutoresizingMaskIntoConstraints = false
        privacyImageView.translatesAutoresizingMaskIntoConstraints = false
        privacyLabel.translatesAutoresizingMaskIntoConstraints = false
        privacyWarningLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            privacyImageBgView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            privacyImageBgView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            privacyImageBgView.widthAnchor.constraint(equalToConstant: 24),
            privacyImageBgView.heightAnchor.constraint(equalToConstant: 24),
            
            privacyImageView.topAnchor.constraint(equalTo: privacyImageBgView.topAnchor, constant: 4),
            privacyImageView.leadingAnchor.constraint(equalTo: privacyImageBgView.leadingAnchor, constant: 4),
            privacyImageView.trailingAnchor.constraint(equalTo: privacyImageBgView.trailingAnchor, constant: -4),
            privacyImageView.bottomAnchor.constraint(equalTo: privacyImageBgView.bottomAnchor, constant: -4),
            
            privacyLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            privacyLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 48),
            privacyLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            privacyWarningLabel.topAnchor.constraint(equalTo: privacyLabel.bottomAnchor, constant: 0),
            privacyWarningLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 48),
            privacyWarningLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ])
    }
    
    @objc
    private func checkboxTapped() {
        delegate?.tapPrivacy()
    }
}


extension PrivacyView: HtmlLabelDelegate {
    func htmlLabelLinkDidPress(url: URL?) {
        if let url = url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
