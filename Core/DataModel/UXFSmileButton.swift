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
    
    convenience init(index: Int) {
        self.init()
        self.index = index
    }

}
