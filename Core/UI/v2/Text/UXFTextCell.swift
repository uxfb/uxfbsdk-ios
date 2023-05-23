//
//  UXFTextCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class UXFTextCell: UXFBaseCell {
    @IBOutlet var label: UILabel!
    
    override func updateUI() {
        guard field != nil, theme != nil else {
            return
        }
        label.font = theme?.fontP1
        label.text = field?.value
        label.textColor = theme?.text02Color
    }
}
