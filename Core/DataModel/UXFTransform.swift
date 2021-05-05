//
//  UXFTransform.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

struct UXFTransform: Codable {
    let id: String?
    let rule: String?
    let action: String?
    let value: [String]?
    let fromField: String?
    let toField: String?
    let fromButton: String?
    let toButton: String?
    let fromPage: String?
    let toPage: String?
}
