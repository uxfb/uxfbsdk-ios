//
//  Copyright.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 18.10.2023.
//  Copyright © 2023 UXF. All rights reserved.
//

import Foundation

internal struct Copyright: Codable {
    private(set) var isShow: Bool
    private(set) var href: String?
    private(set) var image: [String: String]?
}
