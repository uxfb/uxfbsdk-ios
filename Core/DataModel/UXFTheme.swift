//
//  UXFTheme.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIColor_Hex_Swift

struct UXFTheme : Decodable {
    
    let colors: Dictionary<String, String>!
    let smiles: Dictionary<String, String>!
    
    var titleColor: UIColor{
        return UIColor(colors["title"] ?? "")
    }
    var textColor: UIColor{
        return UIColor(colors["text"] ?? "")
    }
    var accendentTextColor: UIColor{
        return UIColor(colors["accentedText"] ?? "")
    }
    var accentColor: UIColor{
        return UIColor(colors["accent"] ?? "")
    }
    var backgroundColor: UIColor{
        return UIColor(colors["background"] ?? "")
    }
    var errorColor: UIColor{
        return UIColor(colors["error"] ?? "")
    }
    var cardColor: UIColor{
        return UIColor(colors["card"] ?? "")
    }
}
