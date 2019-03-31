//
//  UXFViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 22.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import CocoaLumberjack

class UXFViewController: UIViewController{
    
    @IBOutlet var progressLabel: UILabel?
    
    internal var theme: UXFTheme?
    var presentationAnimated = true
    var didCloseHandler: (()->())?
    var nextHandler: (()->())?
    var backHandler: (()->())?
    
    @IBAction func backButtonTap(_ sender: UIButton){
        backHandler?()
    }
    
    @IBAction  func closeButtonDidTap(_ sender: UIButton){
        close(animated: presentationAnimated)
    }
    
    func close(animated: Bool = false){
        self.dismiss(animated: animated, completion: didCloseHandler)
        didCloseHandler = nil
    }
    
    deinit {
        DDLogDebug(#function)
    }
}
