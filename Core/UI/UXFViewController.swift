//
//  UXFViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 22.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

class UXFViewController: UIViewController{
    
    internal var _theme: UXFTheme?
    var presentationAnimated = true
    var didCloseHandler: (()->())?
    
    @IBAction  func closeButtonDidTap(_ sender: UIButton){
        self.dismiss(animated: presentationAnimated, completion: didCloseHandler)
        didCloseHandler = nil
    }
}
