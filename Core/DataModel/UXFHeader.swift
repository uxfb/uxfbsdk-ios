//
//  UXFHeader.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 15.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIColor_Hex_Swift

struct UXFHeader : Decodable {
    let logo: String!
    let backgroundColorString: String!
    var background: UIColor{
        return UIColor(self.backgroundColorString)
    }
    
    enum CodingKeys: String, CodingKey{
        case logo = "logo"
        case backgroundColorString = "background"
    }
}
