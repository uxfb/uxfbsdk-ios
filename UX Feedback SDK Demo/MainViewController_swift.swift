//
//  ViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
//import YoHeSDK
import UXFeedbackSDK

class MainViewController_swift: UIViewController {
    
    @IBOutlet var busyIndicator: UIActivityIndicatorView!
    @IBOutlet var buttonsStackView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = .white
//        UXFeedback.sdk.campaignDelegate = self

//        self.buttonsStackView.isUserInteractionEnabled = false
//        self.buttonsStackView.alpha = 0.5
//        busyIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let customTheme = UXFBTheme()
            customTheme.text03Color =  UIColor.init("#000000")
            customTheme.inputBorderColor =  UIColor.init("#D3D4D8")
            customTheme.iconColor =  UIColor.init("#B5B8C2")
            customTheme.btnBgColorActive =  UIColor.init("#1983C8")
            customTheme.btnBorderRadius = 4
            customTheme.errorColorSecondary =  UIColor.init("#F4A0A3")
            customTheme.errorColorPrimary =  UIColor.init("#E84047")
            customTheme.mainColor =  UIColor.init("#AFAFAF")
            customTheme.controlBgColorActive =  UIColor.init("#DBF1FF")
            customTheme.formBorderRadius = 20
            customTheme.inputBgColor =  UIColor.init("#F3F3F3")
            customTheme.text01Color =  UIColor.init("#232735")
            customTheme.controlBgColor =  UIColor.init("#ABABAB")
            customTheme.controlIconColor =  UIColor.init("#FFFFFF")
            customTheme.btnBgColor =  UIColor.init("#0076C2")
            customTheme.text02Color =  UIColor.init("#505565")
            customTheme.btnTextColor =  UIColor.init("#FFFFFF")
            customTheme.bgColor =  UIColor.init("#123456")
            
            customTheme.iconSmile1Color =  UIColor.init("#FFFFFF")
            customTheme.iconSmile2Color =  UIColor.init("#FB1A23")
            customTheme.iconSmile3Color =  UIColor.init("#000000")
            
//            UXFeedback.sdk.theme = customTheme
        }
    }

    @IBAction func stopCampaign(_ sender: UIButton){
//        UXFeedback.sdk.stopCampaign()
    }
    
    func configureSDK() {
//        UXFeedback.sdk.settings.slideInUiBlocked = false
//        UXFeedback.sdk.settings.closeOnSwipe = true
    }
    
    @IBAction func eventTap(_ sender: UIButton){
        
//        UXFeedback.sdk.settings.closeOnSwipe = true
//        UXFeedback.sdk.settings.slideInUiBlocked = true
//        UXFeedback.sdk.settings.slideInUiBlackoutBlur = 0
//        UXFeedback.sdk.settings.slideInUiBlackoutOpacity = 0
//        UXFeedback.sdk.settings.slideInUiBlackoutColor = "#00FFFF"
//        UXFeedback.sdk.settings.popupUiBlackoutBlur = 0
//        UXFeedback.sdk.settings.popupUiBlackoutOpacity = 0
//        UXFeedback.sdk.settings.popupUiBlackoutColor = nil
        
        let eventNumber = sender.tag
        assert(eventNumber > 0, "Invalid eventNumber")
        UXFeedback.sdk.settings.globalDelayTimer = 1
        switch eventNumber {
        case 1:
//            UXFeedback.sharedSDK.setProperties(["property_first": "non-value",
//                                                "property_second": 2])
            
//            UXFeedback.sdk.properties = ["ios": "ios-data"]

//                let atts = UXFBAttributesBuilder()
//                    .addValue("step", value: 2)
//                .build()
//
//                let attributes = UXFBAttributesBuilder()
//                    .addValue("hash_user_id", value: "aaca4f68bf5d7e61b2894cb70622d094                                ")
//                    .build()
//                for i in 0...10000 {
                
                let eventNames = [
                    "mos",
                    "ger_1",
                    "ger",
                    "seller",
                    "filter",
                    "mvideo",
                    "roundtrip",
                    "resume",
                    "pvz",
                    "image",
                    "person"
                ]
                
                    UXFeedback.sdk.startCampaign(eventName: eventNames[0])
                
                
//                }
                
            
        case 2:
//                UXFeedback.setup(appID: uxfAppID, settings: (UIApplication.shared.delegate as! AppDelegate).settings)
//                UXFeedback.sdk.stopCampaign(eventForStop: "")
            UXFeedback.sdk.startCampaign(eventName: "hardlogick", attributes: nil)
            
        default:
            break
        }
    }
    
    @IBAction func closeButtonTap(_ sender: UIButton){
//        showActivityOverlay()
        self.dismiss(animated: true, completion: nil)
    }
    
    var activityOverlay: UIAlertController?
    
    func showActivityOverlay() {
        let overlay = UIAlertController(title: nil, message: "", preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        if #available(iOS 13.0, *) {
            indicator.style = .large
        }
        indicator.startAnimating()
        overlay.view.addSubview(indicator)
        indicator.center = overlay.view.center
        present(overlay, animated: true, completion: nil)
        activityOverlay = overlay
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.hideActivityOverlay()
        }
    }
        
    func hideActivityOverlay() {
        activityOverlay?.dismiss(animated: true, completion: nil)
    }

}

extension MainViewController_swift: UXFeedbackLogDelegate {
    func logDidReceive(message: String) {
//        print(message)
    }
}

extension MainViewController_swift: UXFeedbackCampaignDelegate{
    func noCampaignToStart(eventName: String) {
        
    }
    
    func campaignDidShow(campaignId: Int, eventName: String) {
        
    }
    
    func campaignDidClose(campaignId: Int, eventName: String) {
        
    }
    
    func campaignDidTerminate(campaignId: Int, eventName: String, terminatedPage: Int, totalPages: Int) {
        
    }
    
    
    func campaignDidSend(campaignId: Int) {
        
    }
    
    func campaignDidAnswered(campaignId: Int, answers: [String : Any]) {
        
    }
    
    func campaignDidLoad(success: Bool){
        self.buttonsStackView.isUserInteractionEnabled = true
        self.buttonsStackView.alpha = 1.0
        self.busyIndicator.stopAnimating()
//        DDLogDebug(#function)
    }
    
    func campaignDidReceiveError(errorString: String){
//        DDLogDebug(errorString)
    }
}

