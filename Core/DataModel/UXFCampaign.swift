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

struct UXFCampaign{
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
    
    mutating func updateTheme(theme: UXFBTheme) {
        self.theme = theme
    }
}
