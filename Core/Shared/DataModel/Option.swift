//
//  UXFOption.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 15.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

struct Option: Codable {
    let id: String
    let value: String
    let exceptional: Bool?

    init(id: String, value: String, exceptional: Bool?) {
        self.id = id
        self.value = value
        self.exceptional = exceptional
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        value = try container.decode(String.self, forKey: .value)
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.controlCharacters))
        exceptional = try container.decodeIfPresent(Bool.self, forKey: .exceptional)
    }
}
