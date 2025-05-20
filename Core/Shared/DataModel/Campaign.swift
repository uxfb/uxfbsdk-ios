//
//  UXFCampaign.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 21.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

enum CampaignType: String {
    case popup = "101"
    case slidein = "102"
}

struct Campaign {
    private(set) var campaignId: Int!
    private(set) var theme: ThemeProtocol!
    private(set) var pages: Array<Page> = []
    private(set) var type: CampaignType!
    private(set) var targeting: Targeting!
    private(set) var transforms: Array<Transform>!
    private(set) var projectId: String!
    private(set) var autoclose: Double!
    private(set) var copyright: Copyright!
    private(set) var privacy: Privacy?
    private(set) var progress: Bool?
    private(set) var textProperties: TextProperties?
    
    func showDelay(eventName: String) -> TimeInterval {
        var delay: TimeInterval = 0.1
        
        if eventName == targeting.value, let seconds = targeting.seconds{
            delay = seconds
        }

        return delay
    }
    
    mutating func updateTheme(theme: ThemeProtocol) {
        self.theme = theme
    }
}
