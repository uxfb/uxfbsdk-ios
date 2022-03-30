//
//  UXFBaseCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

open class UXFBaseCell: UITableViewCell {
    internal var delegate: UXFFieldDelegate?
    internal var field: UXFField?
    internal var theme: UXFBTheme?
    
    open override func awakeFromNib() {
        super.awakeFromNib()
    }

    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal func configureWith(_ value: UXFField, theme: UXFBTheme, delegate: UXFFieldDelegate, valueIndex: Int = 0) {
        self.field = value
        self.theme = theme
        self.delegate = delegate
        updateUI()
    }
    
    internal func updateUI() { }
}
