//
//  UXFConfig.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 15.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIColor_Hex_Swift

struct UXFConfig: Decodable{
    
    let colorString: String!
    var color: UIColor {
        return UIColor(self.colorString)
    }
    let smiles: Dictionary<String, String>!
    let backgroundColorString: String!
    var background: UIColor{
        return UIColor(self.backgroundColorString)
    }
    let header: UXFHeader!
    let button: UXFButton!
    
    enum CodingKeys: String, CodingKey{
        case colorString = "color"
        case smiles = "smiles"
        case backgroundColorString = "background"
        case header = "header"
        case button = "button"
    }
}
