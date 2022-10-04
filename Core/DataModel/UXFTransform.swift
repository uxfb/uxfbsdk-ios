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
    let from: UXFTransformFrom
    let to: UXFTransformTo
    let condition: UXFTransformCondition?
}

struct UXFTransformFrom: Codable {
    let field: String?
    let page: String?
}

struct UXFTransformTo: Codable {
    let action: String
    let value: String
    let type: String
}

struct UXFTransformCondition: Codable {
    let rule: String?
    var value: [String]?
    
    private enum CodingKeys: String, CodingKey {
       case rule, value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rule = try container.decode(String.self, forKey: .rule)
        do {
            value = try container.decodeIfPresent([Int].self, forKey: .value)?.map({ String($0) })
        } catch DecodingError.typeMismatch {
            value = try container.decodeIfPresent([String].self, forKey: .value)
        }
    }
}
