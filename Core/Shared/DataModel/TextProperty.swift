//
//  TextProperties.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 09.03.2025.
//  Copyright © 2025 UXF. All rights reserved.
//

internal struct TextPropertyLink {
    let text: String
    let link: String
}

internal struct TextPropertyTransformResult {
    let attributedString: NSAttributedString
    let links: [TextPropertyLink]
}

internal struct TextProperties: Codable {
    private(set) var h1: [TextProperty]?
    private(set) var h2: [TextProperty]?
    private(set) var p: [TextProperty]?
}

internal struct TextProperty: Codable {
    private(set) var name: String
    private(set) var type: String
    private(set) var value: String
}

