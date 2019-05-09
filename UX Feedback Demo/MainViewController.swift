//
//  ViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import CocoaLumberjack

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UXFeedback.sharedInstance.delegate = self
        UXFeedback.sharedInstance.sendEvent(event: UXFedbackCompanyEvents.mainScreen.rawValue)
    }

}

extension MainViewController: UXFeedbackCampaignDelegate{
    func campaignDidClose(withFeedbackResult result: UXFeedbackResult, isRedirectToAppStoreEnabled: Bool) {
        DDLogDebug(#function)
    }
}
