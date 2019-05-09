//
//  AboutViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 30.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit
import UXFeedbackSDK

class AboutViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UXFeedback.sharedInstance.sendEvent(event: UXFedbackCompanyEvents.aboutScreen.rawValue)
    }
    
    @IBAction func closeButtonTap(_ sender: Any){
      self.dismiss(animated: true, completion: nil)
    }
    
}
