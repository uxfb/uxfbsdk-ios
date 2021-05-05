//
//  ViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import UXFeedbackSDK

class MainViewController_swift: UIViewController {
    
    @IBOutlet var busyIndicator: UIActivityIndicatorView!
    @IBOutlet var buttonsStackView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = .white
        UXFeedback.sharedSDK.delegate = self
//        UXFeedback.sharedInstance.formDelegate = self
        
        if UXFeedback.sharedSDK.isCampaignsLoaded == false {
            self.buttonsStackView.isUserInteractionEnabled = false
            self.buttonsStackView.alpha = 0.5
            busyIndicator.startAnimating()
        }
    }

    @IBAction func stopCampaign(_ sender: UIButton){
        UXFeedback.sharedSDK.stopCampaign()
    }
    
    @IBAction func eventTap(_ sender: UIButton){
        
        let eventNumber = sender.tag
        assert(eventNumber > 0, "Invalid eventNumber")
        switch eventNumber {
        case 1:
            UXFeedback.sharedSDK.sendEvent(event: "UXFeedbackIOSTestCampaign", fromController: self)
            break
        case 2:
            UXFeedback.sharedSDK.sendEvent(event: "eee", fromController: self)
            break
        default:
            break
        }
    }
    
    @IBAction func closeButtonTap(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}

extension MainViewController_swift: UXFeedbackCampaignDelegate{
    func campaignDidShow() {
        print("CAMPAIGN SHOWED")
    }
    
    func campaignDidClose(withFeedbackResult result: UXFeedbackResult, isRedirectToAppStoreEnabled: Bool) {
        DDLogDebug(#function)
    }
    
    func campaignLoaded(success: Bool){
        self.buttonsStackView.isUserInteractionEnabled = true
        self.buttonsStackView.alpha = 1.0
        self.busyIndicator.stopAnimating()
        DDLogDebug(#function)
    }
    
    func campaignErrorReceived(errorString: String){
        DDLogDebug(errorString)
    }
}

extension MainViewController_swift: UXFeedbackFormDelegate{
    
    func formDidLoaded(form: UXFCampaignViewController) {
        DDLogDebug(#function)
        self.present(form, animated: true, completion: nil)
    }
    
    func formDidFailLoading(error: UXFError) {
        DDLogDebug(error.localizedDescription)
    }
    
    func formDidClose(formID: String?, withFeedbackResults results: [UXFeedbackResult], isRedirectToAppStoreEnabled: Bool) {
        DDLogDebug(#function)
    }
    
    func formWillClose(form: UXFCampaignViewController, formID: String?, withFeedbackResults results: [UXFeedbackResult], isRedirectToAppStoreEnabled: Bool) {
        DDLogDebug(#function)
    }
}
