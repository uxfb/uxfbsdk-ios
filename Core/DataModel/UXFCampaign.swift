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

    private let attemptKey = "campaingAttempt"

    private(set) var campaignId: String!
    private(set) var pages: Array<UXFPage> = []
    private(set) var type: UXFCampaignType!
    private(set) var targetings: Array<Dictionary<String,Any>>!
    private(set) var isProgressEnabled: Bool!
    private(set) var projectId: String!
    
    var showAttemptCount: Int{
        return 3
    }
    var showDelay: TimeInterval{
        return 1.0
    }
    var currentAttempt: Int{
        return UserDefaults.standard.integer(forKey: attemptKey)
    }
    
    var formsCount: Int{
        return pages.count
    }
    
    func show() -> (Bool){
        #warning("implement API call here")
        if self.currentAttempt < showAttemptCount{
            UserDefaults.standard.set(self.currentAttempt + 1, forKey: attemptKey)
            return true
        }
        
        return true//false
    }
    
}
