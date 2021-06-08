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
        UXFeedback.sharedSDK.closeOnSwipe = true
        UXFeedback.sharedSDK.uiBlocked = true
        
        let eventNumber = sender.tag
        assert(eventNumber > 0, "Invalid eventNumber")
        switch eventNumber {
        case 1:
            UXFeedback.sharedSDK.sendEvent(event: "slidein", fromController: self)
            break
        case 2:
            UXFeedback.sharedSDK.sendEvent(event: "2222", fromController: self)
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
    func campaignDidShow(eventName: String) {
        print("CAMPAIGN SHOWED")
    }
    
    func campaignDidClose(withFeedbackResult result: UXFeedbackResult, isRedirectToAppStoreEnabled: Bool) {
        DDLogDebug(#function)
    }
    
    func campaignDidLoad(success: Bool){
        self.buttonsStackView.isUserInteractionEnabled = true
        self.buttonsStackView.alpha = 1.0
        self.busyIndicator.stopAnimating()
        DDLogDebug(#function)
    }
    
    func campaignDidReceiveError(errorString: String){
        DDLogDebug(errorString)
    }
    
    func campaignDidClose(eventName: String) {
        
    }
}
