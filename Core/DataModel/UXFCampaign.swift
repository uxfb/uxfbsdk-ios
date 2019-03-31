//
//  UXFCampaign.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 21.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

enum UXFCampaignType: String{
    case slidein = "slidein"
}

enum UXFCampaignPosition: String{
    case upperRight = "upperRight"
}

struct UXFCampaign{

    #warning("implement campaign ID here")
    private let attemptKey = "campaingAttempt"
    
    var formsCount: Int{
        return 2
    }
    
    private(set) var pages: Array<UXFPage> = []
    private(set) var type: UXFCampaignType!
    //private(set) var position: UXFCampaignPosition!
    //private(set) var isProgressEnabled: Bool!
    var showAttemptCount: Int!
    var showDelay: TimeInterval!
    var currentAttempt: Int{
        return UserDefaults.standard.integer(forKey: attemptKey)
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
