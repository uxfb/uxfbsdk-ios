//
//  UILabel+Align.swift
//  UX Feedback SDK Demo
//
//  Created by Alexander Potemka on 25.05.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit

class VerticalAlignedLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        var newRect = rect
        switch contentMode {
        case .top:
            newRect.size.height = sizeThatFits(rect.size).height
        case .bottom:
            let height = sizeThatFits(rect.size).height
            newRect.origin.y += rect.size.height - height
            newRect.size.height = height
        default:
            ()
        }
        
        super.drawText(in: newRect)
    }
}
