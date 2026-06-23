//
//  UXFPage.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 21.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

internal struct Page: Decodable {
    private(set) var id: String?
    private(set) var type: Int?
    private(set) var fields: [Field]
    private(set) var buttons: [Field]

    private enum CodingKeys: String, CodingKey {
        case id, type, fields, buttons
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        type = try container.decodeIfPresent(Int.self, forKey: .type)
        fields = try container.decodeIfPresent([Field].self, forKey: .fields) ?? []
        buttons = try container.decodeIfPresent([Field].self, forKey: .buttons) ?? []
    }
}
