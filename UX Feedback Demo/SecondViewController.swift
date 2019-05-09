//
//  SecondViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 30.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

class SecondViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UXFeedback.sharedInstance.formDelegate = self
        UXFeedback.sharedInstance.loadFeedbackForm(formID: UXFedbackCompanyEvents.mainScreen.rawValue)
    }
}


extension SecondViewController: UXFeedbackFormDelegate{
    
    func formDidLoaded(form: UXFViewController) {
        DDLogDebug(#function)
    }
    
    func formDidFailLoading(error: UXFError) {
        DDLogDebug(#function)
    }
    
    func formDidClose(formID: String, withFeedbackResults results: [UXFeedbackResult], isRedirectToAppStoreEnabled: Bool) {
        DDLogDebug(#function)
    }
    
    func formWillClose(form: UXFViewController, formID: String, withFeedbackResults results: [UXFeedbackResult], isRedirectToAppStoreEnabled: Bool) {
        DDLogDebug(#function)
    }
}
