//
//  UXFTheme.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import HEXColor

class UXFTheme : NSObject {
    
    private(set) var titleColor: UIColor = UIColor.black
    private(set) var textColor: UIColor = UIColor.black
    private(set) var accendentTextColor: UIColor!
    private(set) var accentColor: UIColor!
    private(set) var backgroundColor: UIColor = UIColor.groupTableViewBackground
    private(set) var errorColor: UIColor = UIColor.init("#E92436")
    private(set) var cardColor: UIColor!
    private(set) var smiles: Array<String> = []
    
    init(colorsDict: Dictionary<String, String>,
         smilesDict: Dictionary<String, String>) {
 
        if let titleColorString = colorsDict["title"]{
           titleColor = UIColor(titleColorString)
        }
        if let textColorString = colorsDict["text"] {
           textColor = UIColor(textColorString)
        }
        accendentTextColor = UIColor(colorsDict["accentedText"] ?? "")
        accentColor = UIColor(colorsDict["accent"] ?? "")
        if let backgroundColorString = colorsDict["background"] {
            backgroundColor = UIColor(backgroundColorString)
        }
        if let errorColorString = colorsDict["error"] {
           errorColor = UIColor(errorColorString)
        }
        cardColor = UIColor(colorsDict["card"] ?? "")
    
        for key in smilesDict.keys.sorted(){
            if let value = smilesDict[key]{
              smiles.append(value)
            }
        }
       // smiles = smilesDict.values.sorted()
    }
}
