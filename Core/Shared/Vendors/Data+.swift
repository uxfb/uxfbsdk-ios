//
//  Data+.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 29.09.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import Foundation

internal
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
