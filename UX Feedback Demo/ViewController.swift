//
//  ViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let theme = UXFeedback.theme {
           let controller = UXFRateViewController.init()
           controller._theme = theme
           self.present(controller, animated: true, completion: nil)
        }
    }


}

