//
//  UXFViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 22.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

class UXFViewController: UIViewController{
    
    internal var _theme: UXFTheme!
    
    init(theme: UXFTheme) {
        _theme = theme
    }
    
    @IBAction  func closeButtonDidTap(_ sender: UIButton){
        
    }
}
