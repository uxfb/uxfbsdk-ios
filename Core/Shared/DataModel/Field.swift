//
//  UXFField.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

struct FieldImage: Codable {
    let type: String?
    let position: String?
    let alignment: String?
    let src: String?
    let threeX: String?

    enum CodingKeys: String, CodingKey {
        case type, position, alignment, src
        case threeX = "3x"
    }
}

struct FieldMessages: Codable {
    let negative: String?
    let positive: String?
}

struct FieldButtons: Codable {
    let create: String?
    let upload: String?
}

struct Field: Decodable {
    private(set) var id: String?
    private(set) var type: FieldType?
    private(set) var value: String?
    private(set) var description: String?
    private(set) var required: Bool?
    private(set) var placeholder: String?
    private(set) var options: [Option]?
    private(set) var mode: String?
    private(set) var image: FieldImage?
    private(set) var warning: String?
    private(set) var buttons: FieldButtons?
    private(set) var messages: FieldMessages?
    private(set) var ratingCount: Int?
    private(set) var noAnswerName: String?
    var answers: [String] = []
    var isError: Bool = false
    var isLastPage: Bool = false

    private enum CodingKeys: String, CodingKey {
        case id, type, value, description
        case required, placeholder, options, mode
        case image, warning, buttons, messages, ratingCount
        case noAnswerName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        let typeString = try container.decodeIfPresent(String.self, forKey: .type)
        type = typeString.flatMap { FieldType(rawValue: $0) }
        value = try container.decodeIfPresent(String.self, forKey: .value)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        required = try container.decodeIfPresent(Bool.self, forKey: .required)
        placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        options = try container.decodeIfPresent([Option].self, forKey: .options)
        mode = try container.decodeIfPresent(String.self, forKey: .mode)
        image = try container.decodeIfPresent(FieldImage.self, forKey: .image)
        warning = try container.decodeIfPresent(String.self, forKey: .warning)
        buttons = try container.decodeIfPresent(FieldButtons.self, forKey: .buttons)
        messages = try container.decodeIfPresent(FieldMessages.self, forKey: .messages)
        ratingCount = try container.decodeIfPresent(Int.self, forKey: .ratingCount)
        noAnswerName = try container.decodeIfPresent(String.self, forKey: .noAnswerName)
    }
}
