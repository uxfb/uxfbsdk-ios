//
//  UXFCampaign.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 21.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

enum UXFCampaignType: String {
    case popup = "101"
    case slidein = "102"
}

enum UXFCampaignPosition: String {
    case upperRight = "upperRight"
}

struct UXFCampaign{
    
    private var attemptCompanyKey: String {
        return self.campaignId + ".campaignAttempt"
    }
    
    private var currentFormIDKey: String {
        return self.campaignId + ".currentFormId"
    }
    
    private var raitingKey: String {
        return self.campaignId + ".raiting"
    }

    private(set) var campaignId: String!
    private(set) var theme: UXFBTheme!
    private(set) var pages: Array<UXFPage> = []
    private(set) var type: UXFCampaignType!
    private(set) var targetings: Array<Dictionary<String,Any>>!
    private(set) var transforms: Array<UXFTransform>!
    private(set) var isProgressEnabled: Bool!
    private(set) var projectId: String!
    private(set) var autoclose: Double!
    private(set) var showCopyright: Bool!
    
    var raiting: Int?{
        get{
           return UserDefaults.standard.object(forKey: self.raitingKey) as? Int
        }
    }
    
    func setRaiting(_ newRaiting: Int){
        UserDefaults.standard.set(newRaiting, forKey: self.raitingKey)
        UserDefaults.standard.synchronize()
    }

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
    
    var showAttemptCount: Int {
        return Int.max
    }
    
    func showDelay(eventName: String) -> TimeInterval {
        var delay: TimeInterval = 0.1
        self.targetings.forEach { (targetingDict) in
            if let name = targetingDict["value"] as? String, eventName == name {
                if let timeout = targetingDict["seconds"] as? Double{
                    delay = timeout
                }
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
    
    func show() -> (Bool) {
        let attemptCount = self.currentAttempt
        if attemptCount < showAttemptCount{
            self.incAttempt()
            return true
        }
        
        return false
    }
    
    mutating func updateTheme(theme: UXFBTheme) {
        self.theme = theme
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
