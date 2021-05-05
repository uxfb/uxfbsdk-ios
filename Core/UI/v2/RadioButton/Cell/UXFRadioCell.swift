//
//  UXFRadioCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 12.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class UXFRadioCell: UITableViewCell {

    @IBOutlet var radioImage: UIImageView!
    @IBOutlet var radioLabel: UILabel! {
        didSet {
//            radioLabel.font = .mediumFont
            
        }
    }
    @IBOutlet var radioView: UIView!
    
    private var theme: UXFBTheme?
    private var option: UXFOption?
    private var isError: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.updateUI()
    }
    
    func configure(option: UXFOption, theme: UXFBTheme, isError: Bool) {
        self.option = option
        self.theme = theme
        self.isError = isError
        self.radioLabel.font = theme.regularFont(size: .mediumFontSize)
        updateUI()
    }
    
    private func updateUI() {
        let bundle = Bundle(for: UXFeedback.self)
        
        
        radioView.layer.cornerRadius = theme?.btnBorderRadius ?? 4
        radioView.layer.masksToBounds = true
        
        radioView.borderWidth = 2
        radioView.borderColor = isError ? theme?.errorColorSecondary : UIColor.clear
        
        UIView.animate(withDuration: 0.2) {
            self.radioLabel.text = self.option?.value
            if self.isSelected {
                self.radioLabel.textColor = self.theme?.text01Color
                self.radioImage.image = UIImage(named: "radio_on", in: bundle, compatibleWith: nil)!.tint(with: self.theme?.mainColor ?? .blue)
                self.radioView.backgroundColor = self.theme?.controlBgColorActive
            }
            else {
                self.radioLabel.textColor = self.theme?.text02Color
                self.radioImage.image = UIImage(named: "radio_off", in: bundle, compatibleWith: nil)!.tint(with: self.theme?.iconColor ?? .gray)
                self.radioView.backgroundColor = self.theme?.controlBgColor
            }
        }
    }
    
}
