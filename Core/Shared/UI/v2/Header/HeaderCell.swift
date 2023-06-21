//
//  UXFHeaderCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class HeaderCell: BaseCell {
    
    @IBOutlet var label: UILabel!  {
        didSet {
//            label.font = .bigSemiboldFont
        }
    }
    
    override func updateUI() {
        guard field != nil, theme != nil else {
            return
        }
        label.font = theme!.fontH1
        label.text = field?.value
        label.textColor = theme?.text01Color
    }
}

