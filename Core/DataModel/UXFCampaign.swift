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
    private(set) var pages: Array<UXFPage> = []
    private(set) var type: UXFCampaignType!
    //private(set) var position: UXFCampaignPosition!
    //private(set) var isProgressEnabled: Bool!
}
