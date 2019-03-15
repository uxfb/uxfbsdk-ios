//
//  UXFButton.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 15.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIColor_Hex_Swift

struct UXFButton: Decodable{
    let sizeString: String!
    var size: Float{
        return Float(self.sizeString) ?? 0
    }
    let backgroundColorString: String!
    var background: UIColor{
        return UIColor(self.backgroundColorString)
    }
    
    let hoverColorString: String!
    var hover: UIColor{
        return UIColor(self.hoverColorString)
    }
    
    let colorString: String!
    var color: UIColor{
        return UIColor(self.colorString)
    }
    
    let radiusString: Float!
    var radius: Float{
        return Float(self.radiusString)
    }
    
    enum CodingKeys: String, CodingKey{
        case colorString = "color"
        case backgroundColorString = "background"
        case radiusString = "radius"
        case hoverColorString = "hover"
        case sizeString = "sizeString"
    }
}
