//
//  UXFBTheme.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
/// SDK theme class. To instantiate the default settings, call the ``init()`` method. **IMPORTANT**: all colors are specified in HEX format with a pound sign at the beginning, for example #ABC123
@objcMembers
open class YoHeTheme: NSObject, ThemeProtocol {
    
    /// Form background color
    open var bgColor: UIColor = UIColor.init("#FFFFFF")
    
    /// Color of close button icon, NPS/rating bar, checkbox outline and radio button in normal state
    open var iconColor: UIColor = UIColor.init("#A1B2E1")
    
    /// Color of title text and content of all blocks
    open var text01Color: UIColor = UIColor.init("#05174B")
    
    /// Color of the block for displaying text information
    open var text02Color: UIColor = UIColor.init("#25408E")
    
    /// Text color of page counter, placeholders, checkboxes and radio buttons in normal state
    open var text03Color: UIColor = UIColor.init("#7182B6")
    
    /// Primary color - the cursor in the input and the inner stroke of the input in focus, icons of the active checkbox and radio buttons
    open var mainColor: UIColor = UIColor.init("#0A2C73")
    
    /// The color of the error text label for the block, the color of the NPS/rating in the error state
    open var errorColorPrimary: UIColor = UIColor.init("#E52C7A")
    
    /// Input border color in error state
    open var errorColorSecondary: UIColor = UIColor.init("#FFAAB9")
    
    /// Input background color
    open var inputBgColor: UIColor = UIColor.init("#E9EEFB")
    
    /// Input border color in normal state
    open var inputBorderColor: UIColor = UIColor.init("#A1B2E1")
    
    /// Background color of checkbox, radio button and screenshot button in normal state
    open var controlBgColor: UIColor = UIColor.init("#E9EEFB")
    
    /// The background color of the checkbox, radio button and screenshot button in the selected state
    open var controlBgColorActive: UIColor = UIColor.init("#DBE2F7")
    
    /// The color of the checkbox icon, radio button, and NPS/rating slider
    open var controlIconColor: UIColor = UIColor.init("#FFFFFF")
    
    /// Button background color
    open var btnBgColor: UIColor = UIColor.init("#0A2C73")
    
    /// The color of the button in the highlighted state
    open var btnBgColorActive: UIColor = UIColor.init("#5B72B0")
    
    /// Button text color
    open var btnTextColor: UIColor = UIColor.init("#FFFFFF")
    
    /// Stars color
    open var iconStarColor: UIColor = UIColor.init("#FECA00")
    
    /// Smiles colors
    open var iconSmile1Color: UIColor = UIColor.init("#FECA00") //yellow
    open var iconSmile2Color: UIColor = UIColor.init("#232735") //black
    open var iconSmile3Color: UIColor = UIColor.init("#E84047") //red
    open var iconSmile4Color: UIColor = UIColor.init("#FFD740") //highlight
    
    /// Skeleton colors
    open var skeletonBase: UIColor = UIColor.init("#EDEDED")
    open var skeletonShine: UIColor = UIColor.init("#F8F8FA")
    
    /// Disabled colors
    open var bgDisabled: UIColor =  UIColor.init("#99A1B1")
    open var fgDisabled: UIColor =  UIColor.init("#99A1B1")
    open var borderDisabled: UIColor =  UIColor.init("#99A1B1")
    open var iconDisabledColor: UIColor =  UIColor.init("#777F8E").withAlphaComponent(0.2)
    
    /// Button rounding radius
     open var btnBorderRadius: CGFloat = 4
    
    /// Form rounding radius
     open var formBorderRadius: CGFloat = 8
    
     /// Form header font. Default System:Semibold:22
     open var fontH1: UIFont = .systemFont(ofSize: 22,
                                               weight: .semibold)


     /// Block header font. Default System:Semibold:17
     open var fontH2: UIFont = .systemFont(ofSize: 17,
                                               weight: .semibold)

     /// Font of all form elements. Default System:Regular:17
     open var fontP1: UIFont = .systemFont(ofSize: 17,
                                               weight: .regular)

     /// Font for block labels. Default System:Regular:14
     open var fontP2: UIFont = .systemFont(ofSize: 14,
                                               weight: .regular)

     /// Button font. Default System:Semibold:16
     open var fontBtn: UIFont = .systemFont(ofSize: 16,
                                              weight: .semibold)
    
    /// Caption font. Default System:Regular:16
    open var fontCaption: UIFont = .systemFont(ofSize: 16,
                                               weight: .regular)
    
    /// Initialize theme object
    public override init() {
        super.init()
    }

}
