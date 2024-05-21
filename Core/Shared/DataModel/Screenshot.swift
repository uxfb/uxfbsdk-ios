//
//  UXFScreenshot.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 29.09.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit

enum ScreenshotType {
    case screenshot
    case gallery
}

struct Screenshot {
    let id: String
    var image: UIImage
    var type: ScreenshotType
    var field: Field
}

struct ScreenshotData: Codable {
    let id: String
    let base64image: String
}
