//
//  SecondViewController.swift
//  UX Feedback SDK Demo
//
//  Created by Dmitry Kudryavtsev on 13/06/2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import UXFeedbackSDK

class SecondViewController: UIViewController {

    @IBOutlet var busyIndicator: UIActivityIndicatorView!
    @IBOutlet var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if UXFeedback.sharedInstance.isCampaignsLoaded == false {
          button.isEnabled = false
          busyIndicator.startAnimating()
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func buttonTap(_ sender: Any){
       let alertController = UIAlertController.init(title: "", message: "Какое событие вызвать?", preferredStyle: .alert)
        alertController.addAction( UIAlertAction.init(title: "event1", style: .default, handler: { (action) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                 UXFeedback.sharedInstance.sendEvent(event: "event1", fromController: self)
            })
           
        }))
        alertController.addAction( UIAlertAction.init(title: "event2", style: .default, handler: { (action) in
            UXFeedback.sharedInstance.sendEvent(event: "event2", fromController: self)
        }))
        alertController.addAction(UIAlertAction.init(title: "Отмена", style: .cancel, handler: { (action) in
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }

}

extension SecondViewController: UXFeedbackCampaignDelegate{
    func campaignDidClose(withFeedbackResult result: UXFeedbackResult, isRedirectToAppStoreEnabled: Bool) {
        DDLogDebug(#function)
    }
    
    func campaignLoaded(success: Bool){
        self.busyIndicator.stopAnimating()
        button.isEnabled = true
        DDLogDebug(#function)
    }
    
    func campaignErrorReceived(errorString: String){
        DDLogDebug(errorString)
    }
}
