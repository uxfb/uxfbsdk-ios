//
//  UXFText.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 15.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

struct UXFText: Decodable {
    let colorString: String!
    var color: UIColor{
        return UIColor(self.colorString)
    }
    
    let sizeString: String!
    var size: Float{
        return Float(self.sizeString) ?? 0
    }
    
    let weight: Int!
    
    enum CodingKeys: String, CodingKey{
        case colorString = "color"
        case sizeString = "sizeString"
        case weight = "weight"
    }
}
