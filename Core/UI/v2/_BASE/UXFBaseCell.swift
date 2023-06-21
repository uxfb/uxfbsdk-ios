//
//  UXFBaseCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

internal class UXFBaseCell: UITableViewCell {
    internal var delegate: FieldDelegate?
    internal var field: Field?
    internal var theme: Theme?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal func configureWith(_ value: Field, theme: Theme, delegate: FieldDelegate, valueIndex: Int = 0) {
        self.field = value
        self.theme = theme
        self.delegate = delegate
        updateUI()
    }
    
    internal func updateUI() { }
}
