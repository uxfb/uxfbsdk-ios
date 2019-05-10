//
//  ViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import CocoaLumberjackSwift
import UXFeedbackSDK

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UXFeedback.sharedInstance.delegate = self
        UXFeedback.sharedInstance.sendEvent(event: UXFedbackCompanyEvents.mainScreen.rawValue)
    }

    
    @IBAction func secondTap(_ sender: Any){
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") {
           self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func aboutTap(_ sender: Any){
         let controller = AboutViewController.init(nibName: "AboutViewController", bundle: nil)
         self.present(controller, animated: true, completion: nil)
    }
}

extension MainViewController: UXFeedbackCampaignDelegate{
    func campaignDidClose(withFeedbackResult result: UXFeedbackResult, isRedirectToAppStoreEnabled: Bool) {
        DDLogDebug(#function)
    }
}
