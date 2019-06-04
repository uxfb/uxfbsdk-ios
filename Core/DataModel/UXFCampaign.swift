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

    var attemptCompanyKey: String {
        return self.campaignId + ".campaignAttempt"
    }
    
    var currentFormIDKey: String {
        return self.campaignId + ".currentFormId"
    }

    private(set) var campaignId: String!
    private(set) var theme: UXFTheme!
    private(set) var pages: Array<UXFPage> = []
    private(set) var type: UXFCampaignType!
    private(set) var targetings: Array<Dictionary<String,Any>>!
    private(set) var isProgressEnabled: Bool!
    private(set) var projectId: String!
    private(set) var autoclose: Double!
    

    internal var сurrentFormID: String?{
        set{
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: self.currentFormIDKey)
            }
            else{
                UserDefaults.standard.removeObject(forKey: self.currentFormIDKey)
            }
            UserDefaults.standard.synchronize()
        }
        get{
            return  UserDefaults.standard.object(forKey: self.currentFormIDKey) as? String
        }
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
    
    mutating func removeUserData(){
        self.setAnswerID(answerID:  nil)
        self.сurrentFormID = nil
        self.resetAttempt()
    }
    
    var showAttemptCount: Int{
    #if DEBUG
        return Int.max
    #endif
        return 1
    }
    
    func showDelay(eventName: String) -> TimeInterval{
        var delay: TimeInterval = 0.0
        self.targetings.forEach { (targetingDict) in
            if let name = targetingDict["name"] as? String, eventName == name {
                if let timeout = targetingDict["timeout"] as? Double{
                    delay = timeout
                }/*
                else if let timeoutDict = targetingDict["timeout"] as? Dictionary<String,Any>,
                        let enabled = timeoutDict["enabled"] as? Bool,
                        let timeout = timeoutDict["value"] as? String{
                    if enabled == true {
                       delay = TimeInterval(Double(timeout) ?? 0)
                    }
                }*/
            }
        }
        return delay
    }
    
    var currentAttempt: Int{
        return UserDefaults.standard.integer(forKey: self.attemptCompanyKey)
    }
    
    var formsCount: Int{
        return pages.count
    }
    
    func show() -> (Bool){

        let attemptCount = self.currentAttempt
        if attemptCount < showAttemptCount{
            self.incAttempt()
            return true
        }
        
        return false
    }
    
    private func incAttempt(){
        UserDefaults.standard.set(self.currentAttempt + 1, forKey: self.attemptCompanyKey)
        UserDefaults.standard.synchronize()
    }
    
    private mutating func resetAttempt(){
        UserDefaults.standard.set(0, forKey: self.attemptCompanyKey)
        UserDefaults.standard.synchronize()
    }
    
}
