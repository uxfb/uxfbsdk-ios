//
//  UXFRadioCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 12.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class RadioCell: UITableViewCell {

    @IBOutlet var symbolExtView: UIView! {
        didSet {
            symbolExtView.layer.cornerRadius = 12
        }
    }
    @IBOutlet var symbolMidView: UIView! {
        didSet {
            symbolMidView.layer.cornerRadius = 8
        }
    }
    @IBOutlet var symbolIntView: UIView! {
        didSet {
            symbolIntView.layer.cornerRadius = 6
        }
    }
    
    @IBOutlet var radioLabel: UILabel!
    @IBOutlet var radioView: UIView!
    
    private var theme: Theme?
    private var option: Option?
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
    
    func configure(option: Option, theme: Theme, isError: Bool) {
        self.option = option
        self.theme = theme
        self.isError = isError
        self.radioLabel.font = theme.fontP1
        updateUI()
    }
    
    private func updateUI() {        
        radioView.layer.cornerRadius = theme?.btnBorderRadius ?? 4
        radioView.layer.masksToBounds = true
        
        radioView.borderWidth = 2
        radioView.borderColor = isError ? theme?.errorColorSecondary : UIColor.clear
        
        UIView.animate(withDuration: 0.2) {
            self.radioLabel.text = self.option?.value
            if self.isSelected {
                self.radioLabel.textColor = self.theme?.text01Color
                
                self.symbolExtView.backgroundColor = self.theme?.mainColor.withAlphaComponent(0.2)
                self.symbolMidView.backgroundColor = self.theme?.mainColor
                self.symbolIntView.backgroundColor = self.theme?.controlIconColor
                
                self.radioView.backgroundColor = self.theme?.controlBgColorActive
            }
            else {
                self.radioLabel.textColor = self.theme?.text02Color
                self.symbolExtView.backgroundColor = .clear
                self.symbolMidView.backgroundColor = self.theme?.iconColor
                self.symbolIntView.backgroundColor = self.theme?.controlBgColor
                self.radioView.backgroundColor = self.theme?.controlBgColor
            }
        }
    }
    
}
