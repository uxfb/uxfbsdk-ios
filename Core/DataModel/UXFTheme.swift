//
//  UXFTheme.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIColor_Hex_Swift

class UXFTheme : NSObject {
    
    private(set) var titleColor: UIColor!
    private(set) var textColor: UIColor!
    private(set) var accendentTextColor: UIColor!
    private(set) var accentColor: UIColor!
    private(set) var backgroundColor: UIColor!
    private(set) var errorColor: UIColor!
    private(set) var cardColor: UIColor!
    private(set) var smiles: Array<String> = []
    
    init(colorsDict: Dictionary<String, String>,
         smilesDict: Dictionary<String, String>) {
 
        titleColor = UIColor(colorsDict["title"] ?? "")
        textColor = UIColor(colorsDict["text"] ?? "")
        accendentTextColor = UIColor(colorsDict["accentedText"] ?? "")
        accentColor = UIColor(colorsDict["accent"] ?? "")
        backgroundColor = UIColor(colorsDict["background"] ?? "")
        errorColor = UIColor(colorsDict["error"] ?? "")
        cardColor = UIColor(colorsDict["card"] ?? "")
    
        for key in smilesDict.keys.sorted(){
            if let value = smilesDict[key]{
              smiles.append(value)
            }
        }
       // smiles = smilesDict.values.sorted()
    }
   
    /*
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
    }*/
}
