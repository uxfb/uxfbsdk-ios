//
//  Targeting.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 30.03.2024.
//  Copyright © 2024 UXF. All rights reserved.
//

import Foundation

internal struct Targeting: Decodable {
    private(set) var counts: Int?
    private(set) var enabled: Bool?
    private(set) var isMultiVisited: Bool?
    private(set) var seconds: Double?
    private(set) var type: String?
    private(set) var value: String?
    private(set) var attributes: [CampaignAttribute]?
}
