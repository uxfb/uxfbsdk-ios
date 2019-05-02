//
//  SecondViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 30.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit

class SecondViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UXFeedback.sharedInstance.sendEvent(event: UXFedbackCompanyEvents.secondScreen.rawValue)
    }
    
}
