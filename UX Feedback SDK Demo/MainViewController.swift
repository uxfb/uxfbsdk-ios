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
    
    @IBOutlet var busyIndicator: UIActivityIndicatorView!
    @IBOutlet var buttonsStackView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.buttonsStackView.isUserInteractionEnabled = false
        self.buttonsStackView.alpha = 0.5
        
        UXFeedback.sharedInstance.delegate = self
        UXFeedback.sharedInstance.formDelegate = self
        UXFeedback.sharedInstance.sendEvent(event: "main")
        
        busyIndicator.startAnimating()
        UXFeedback.sharedInstance.onCampaignLoaded = { [weak self] (success: Bool) in
            self?.buttonsStackView.isUserInteractionEnabled = true
            self?.buttonsStackView.alpha = 1.0
            self?.busyIndicator.stopAnimating()
        }
    }

    
    @IBAction func eventTap(_ sender: UIButton){
        
        let eventNumber = sender.tag
        assert(eventNumber > 0, "Invalid eventNumber")
     
        UXFeedback.sharedInstance.sendEvent(event: "Event\(eventNumber)", fromController: self)
    }
}

extension MainViewController: UXFeedbackCampaignDelegate{
    func campaignDidClose(withFeedbackResult result: UXFeedbackResult, isRedirectToAppStoreEnabled: Bool) {
        DDLogDebug(#function)
    }
}

extension MainViewController: UXFeedbackFormDelegate{
    
    func formDidLoaded(form: UXFViewController) {
        DDLogDebug(#function)
        self.present(form, animated: true, completion: nil)
    }
    
    func formDidFailLoading(error: UXFError) {
        DDLogDebug(error.localizedDescription)
    }
    
    func formDidClose(formID: String?, withFeedbackResults results: [UXFeedbackResult], isRedirectToAppStoreEnabled: Bool) {
        DDLogDebug(#function)
    }
    
    func formWillClose(form: UXFViewController, formID: String?, withFeedbackResults results: [UXFeedbackResult], isRedirectToAppStoreEnabled: Bool) {
        DDLogDebug(#function)
    }
}
