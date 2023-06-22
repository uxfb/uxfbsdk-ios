//
//  UXFBTheme.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

enum ThemeType: Int {
    case custom = 0                    
    case light = 1
    case dark = 2
}

class Blackout: NSObject {
    var color: UIColor = .clear
    var opacity: Int = 0
    var blur: Int = 0
    
    convenience init(color: UIColor, opacity: Int, blur: Int) {
        self.init()
        self.color = color
        self.opacity = opacity
        self.blur = blur
    }
}

protocol ThemeProtocol {
    var text03Color: UIColor { get set }
    var inputBorderColor: UIColor { get set }
    var iconColor: UIColor { get set }
    var btnBgColorActive: UIColor { get set }
    var btnBorderRadius: CGFloat { get set }
    var errorColorSecondary: UIColor { get set }
    var errorColorPrimary: UIColor { get set }
    var mainColor: UIColor { get set }
    var controlBgColorActive: UIColor { get set }
    var formBorderRadius: CGFloat { get set }
    var inputBgColor: UIColor { get set }
    var text01Color: UIColor { get set }
    var controlBgColor: UIColor { get set }
    var controlIconColor: UIColor { get set }
    var btnBgColor: UIColor { get set }
    var text02Color: UIColor { get set }
    var btnTextColor: UIColor { get set }
    var bgColor: UIColor { get set }
    
    var fontH1: UIFont { get set }
    var fontH2: UIFont { get set }
    var fontP1: UIFont { get set }
    var fontP2: UIFont { get set }
    var fontBtn: UIFont { get set }
}

@objcMembers
open class Theme: NSObject, Decodable, ThemeProtocol {
    open var text03Color: UIColor = UIColor.init("#8B90A0")
    open var inputBorderColor: UIColor = UIColor.init("#D3D4D8")
    open var iconColor: UIColor =  UIColor.init("#B5B8C2")
    open var btnBgColorActive: UIColor =  UIColor.init("#1983C8")
    open var btnBorderRadius: CGFloat = 4
    open var errorColorSecondary: UIColor =  UIColor.init("#F4A0A3")
    open var errorColorPrimary: UIColor =  UIColor.init("#E84047")
    open var mainColor: UIColor =  UIColor.init("#0076C2")
    open var controlBgColorActive: UIColor =  UIColor.init("#DBF1FF")
    open var formBorderRadius: CGFloat = 8
    open var inputBgColor: UIColor =  UIColor.init("#F3F3F3")
    open var text01Color: UIColor =  UIColor.init("#232735")
    open var controlBgColor: UIColor =  UIColor.init("#F3F3F3")
    open var controlIconColor: UIColor =  UIColor.init("#FFFFFF")
    open var btnBgColor: UIColor =  UIColor.init("#0076C2")
    open var text02Color: UIColor =  UIColor.init("#505565")
    open var btnTextColor: UIColor =  UIColor.init("#FFFFFF")
    open var bgColor: UIColor =  UIColor.init("#FFFFFF")
    
    var fontH1: UIFont = .systemFont(ofSize: 22,
                                              weight: .semibold)
   
    var fontH2: UIFont = .systemFont(ofSize: 17,
                                              weight: .semibold)
    
    var fontP1: UIFont = .systemFont(ofSize: 17,
                                              weight: .regular)
    
    var fontP2: UIFont = .systemFont(ofSize: 14,
                                              weight: .regular)
    
    var fontBtn: UIFont = .systemFont(ofSize: 16,
                                             weight: .semibold)
    
    
    enum CodingKeys: String, CodingKey {
        case bgColor
        case iconColor
        case mainColor
        case btnBgColor
        case text01Color
        case text02Color
        case text03Color
        case btnTextColor
        case inputBgColor
        case controlBgColor
        case btnBorderRadius
        case btnBgColorActive
        case controlIconColor
        case formBorderRadius
        case inputBorderColor
        case errorColorSecondary
        case errorColorPrimary
        case controlBgColorActive
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let radius: CGFloat =  try? container.decode(CGFloat.self, forKey: .btnBorderRadius) {
            self.btnBorderRadius = radius
        }
        if let radius: CGFloat =  try? container.decode(CGFloat.self, forKey: .formBorderRadius) {
            self.formBorderRadius = radius
        }
        if let text03ColorString = try? container.decode(String.self, forKey: .text03Color){
           self.text03Color = UIColor.init(text03ColorString)
        }
        if let iconColorString = try? container.decode(String.self, forKey: .iconColor){
            self.iconColor = UIColor.init(iconColorString)
        }
        if let btnBgColorActiveString = try? container.decode(String.self, forKey: .btnBgColorActive){
            self.btnBgColorActive = UIColor.init(btnBgColorActiveString)
        }
        if let errorColorSecondaryString = try? container.decode(String.self, forKey: .errorColorSecondary){
            self.errorColorSecondary = UIColor.init(errorColorSecondaryString)
        }
        if let errorColorPrimaryString = try? container.decode(String.self, forKey: .errorColorPrimary){
            self.errorColorPrimary = UIColor.init(errorColorPrimaryString)
        }
        if let mainColorString = try? container.decode(String.self, forKey: .mainColor){
            self.mainColor = UIColor.init(mainColorString)
        }
        if let controlBgColorActiveString = try? container.decode(String.self, forKey: .controlBgColorActive){
            self.controlBgColorActive = UIColor.init(controlBgColorActiveString)
        }
        if let inputBgColorString = try? container.decode(String.self, forKey: .inputBgColor){
            self.inputBgColor = UIColor.init(inputBgColorString)
        }
        if let controlBgColorString = try? container.decode(String.self, forKey: .controlBgColor){
            self.controlBgColor = UIColor.init(controlBgColorString)
        }
        if let controlIconColorString = try? container.decode(String.self, forKey: .controlIconColor){
            self.controlIconColor = UIColor.init(controlIconColorString)
        }
        if let btnBgColorString = try? container.decode(String.self, forKey: .btnBgColor){
            self.btnBgColor = UIColor.init(btnBgColorString)
        }
        if let text02ColorString = try? container.decode(String.self, forKey: .text02Color){
            self.text02Color = UIColor.init(text02ColorString)
        }
        if let btnTextColorString = try? container.decode(String.self, forKey: .btnTextColor){
            self.btnTextColor = UIColor.init(btnTextColorString)
        }
        if let bgColorString = try? container.decode(String.self, forKey: .bgColor){
            self.bgColor = UIColor.init(bgColorString)
        }
    }
    
    public override init() {
        super.init()
    }
}
