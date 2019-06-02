//
//  UXFCampaign.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 21.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

enum UXFCampaignType: String{
    case popup = "popup"
    case slidein = "slidein"
}

enum UXFCampaignPosition: String{
    case upperRight = "upperRight"
}

struct UXFCampaign{

    private let attemptKey = "campaignAttempt"

    private(set) var campaignId: String!
    private(set) var pages: Array<UXFPage> = []
    private(set) var type: UXFCampaignType!
    private(set) var targetings: Array<Dictionary<String,Any>>!
    private(set) var isProgressEnabled: Bool!
    private(set) var projectId: String!
    private(set) var autoclose: Double!
    
    var currentFormID: String? {
      return UserDefaults.standard.object(forKey: self.campaignId + ".currentFormId") as? String
    }
    
    func setCurrentFormID(formID: String?){
        if formID != nil {
           UserDefaults.standard.set(formID!, forKey: self.campaignId + ".currentFormId")
        }
        else{
            UserDefaults.standard.removeObject(forKey: self.campaignId + ".currentFormId")
        }
        UserDefaults.standard.synchronize()
    }
    
    var answerId: String?{
        return UserDefaults.standard.object(forKey:self.campaignId + ".answerId") as? String
    }
    
    func setAnswerID(answerID: String?){
        if answerID != nil {
             UserDefaults.standard.set(answerID!, forKey: self.campaignId + ".answerId")
        }
        else{
            UserDefaults.standard.removeObject(forKey: self.campaignId + ".answerId")
        }
         UserDefaults.standard.synchronize()
    }
    
    func removeUserData(){
        self.setAnswerID(answerID:  nil)
        self.setCurrentFormID(formID: nil)
        self.resetAttempt()
    }
    
    var showAttemptCount: Int{
        return 3
    }
    
    func showDelay(eventName: String) -> TimeInterval{
        var delay: TimeInterval = 0.0
        self.targetings.forEach { (targetingDict) in
            if let name = targetingDict["name"] as? String, eventName == name {
                if let timeout = targetingDict["timeout"] as? Double{
                    delay = timeout
                }
                else if let timeoutDict = targetingDict["timeout"] as? Dictionary<String,Any>,
                        let enabled = timeoutDict["enabled"] as? Bool,
                        let timeout = timeoutDict["value"] as? String{
                    if enabled == true {
                       delay = TimeInterval(Double(timeout) ?? 0)
                    }
                }
            }
        }
        return delay
    }
    var currentAttempt: Int{
        return UserDefaults.standard.integer(forKey: attemptKey)
    }
    
    var formsCount: Int{
        return pages.count
    }
    
    func show() -> (Bool){
        
        //Временно: выходим если уже показывали форму хотя бы один раз
        #if DEBUG
          return true
        #else
        if self.currentFormID != nil {
            return false
        }
        #endif
        
        #warning("implement API call here")
        
        if self.currentAttempt < showAttemptCount{
            UserDefaults.standard.set(self.currentAttempt + 1, forKey: self.campaignId + "." + attemptKey)
            return true
        }
        
        return false
    }
    
    private func resetAttempt(){
        UserDefaults.standard.removeObject(forKey: self.campaignId + "." + attemptKey)
        UserDefaults.standard.synchronize()
    }
    
}
