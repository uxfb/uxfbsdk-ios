//
//  UXFScreenshot.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 29.09.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit

enum UXFScreenshotType {
    case screenshot
    case gallery
}

struct UXFScreenshot {
    let id: String
    var image: UIImage
    var type: UXFScreenshotType
    var field: UXFField
}

struct UXFScreenshotData: Codable {
    let id: String
    let base64image: String
}
