//
//  UXFCheckCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 12.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class UXFCheckCell: UITableViewCell {

    @IBOutlet var checkImage: UIImageView!
    @IBOutlet var checkSymbolImage: UIImageView!
    
    @IBOutlet var symbolExtView: UIView! {
        didSet {
            symbolExtView.layer.cornerRadius = 2
        }
    }
    @IBOutlet var symbolMidView: UIView! {
        didSet {
            symbolMidView.layer.cornerRadius = 2
        }
    }
    @IBOutlet var symbolIntView: UIImageView!
    
    @IBOutlet var checkLabel: UILabel!
    @IBOutlet var checkView: UIView!
    
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
        self.checkLabel.font = theme.fontP1
        updateUI()
    }
    
    private func updateUI() {
        let bundle = Bundle(for: UXFeedback.self)
        checkView.layer.cornerRadius = theme?.btnBorderRadius ?? 4
        checkView.layer.masksToBounds = true
        
        checkView.borderWidth = 2
        checkView.borderColor = isError ? theme?.errorColorSecondary : UIColor.clear
        
        UIView.animate(withDuration: 0.2) {
            self.checkLabel.text = self.option?.value
            if self.isSelected {
                self.checkLabel.textColor = self.theme?.text01Color
                
                self.symbolExtView.backgroundColor = self.theme?.mainColor.withAlphaComponent(0.2)
                self.symbolMidView.backgroundColor = self.theme?.mainColor
                self.symbolIntView.tintColor = self.theme?.controlIconColor
                let bundle = Bundle(for: UXFeedback.self)
                
                self.symbolIntView.image = UIImage(named: "check_symbol",
                                                   in: bundle,
                                                   compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                self.symbolIntView.backgroundColor = .clear
                
                self.checkView.backgroundColor = self.theme?.controlBgColorActive
            }
            else {
                self.checkLabel.textColor = self.theme?.text02Color
                self.symbolExtView.backgroundColor = .clear
                self.symbolMidView.backgroundColor = self.theme?.iconColor
                self.symbolIntView.image = nil
                self.symbolIntView.backgroundColor = self.theme?.controlBgColor
                self.checkView.backgroundColor = self.theme?.controlBgColor
            }
        }
        
    }
    
}
