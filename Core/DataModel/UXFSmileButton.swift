//
//  UXFSmileButton.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 02/05/2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

class UXFSmileButton: UXFButton {

    private(set) var index: Int = 0
    private(set) var isRequired = false
    private(set) var warning: String?
    private(set) var hint: String?
    
    convenience init(index: Int,
                     isRequired: Bool?,
                     warning: String?,
                     hint: String?) {
        self.init()
        
        self.index = index
        if isRequired != nil {
          self.isRequired = isRequired!
        }
        self.warning = warning
        self.hint = hint
    }

}
