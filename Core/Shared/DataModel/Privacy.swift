//
//  UXFBPrivacy.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 16.04.2022.
//  Copyright © 2022 UXF. All rights reserved.
//

import Foundation

internal struct Privacy: Codable {
    private(set) var warningMessage: String?
    private(set) var type: String
    private(set) var declaration: String
    private(set) var showType: String
    private(set) var privacyPages: [String]
    private(set) var enabled: Bool
}
