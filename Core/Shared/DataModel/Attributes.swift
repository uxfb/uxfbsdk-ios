//
//  Attributes.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 11.03.2024.
//  Copyright © 2024 UXF. All rights reserved.
//

import Foundation

public struct Attribute {
    let attributeName: String
    let rule: String
    let value: AttributeValue?
    let valueFrom: AttributeValue?
    let valueTo: AttributeValue?
}

enum AttributeValue: Decodable {
    
    case int(Int), string(String), date(Date)
    
    init(from decoder: Decoder) throws {
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            self = .int(int)
            return
        }
        
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        
        throw AttributeError.missingValue
    }
    
    enum AttributeError:Error {
        case missingValue
    }
}

class AttributesBuilder {
    typealias Attributes = [String : Any]
    
    
}
