//
//  UXFBTheme.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation

enum UXFBThemeType: Int {
    case custom = 0                    
    case light = 1
    case dark = 2
}

@objcMembers
open class UXFBTheme:  NSObject, Decodable{
    
    open var text03Color: UIColor =  UIColor.init("#8B90A0")
    open var inputBorderColor: UIColor =  UIColor.init("#D3D4D8")
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
    
    open var fontRegularName: String?
    open var fontMediumName: String?
    open var fontBoldName: String?
    
    private var _regularFont: UIFont?
    open var regularFont: UIFont{
        get{
            return _regularFont ?? self.regularFont(size: UIFont.systemFontSize)
        }
        set{
            _regularFont = newValue
        }
    }
    
    open func regularFont(size: CGFloat) -> UIFont{
        if (_regularFont != nil){
            return _regularFont!.withSize(size)
        }
        let systemFont = UIFont.systemFont(ofSize: size, weight: .regular)
        guard let fontName = self.fontRegularName else {
            return systemFont
        }
        return UIFont.init(name: fontName, size: size) ?? systemFont
    }

    
    private var _mediumFont: UIFont?
    open var mediumFont: UIFont{
        get{
            return _mediumFont ?? self.mediumFont(size: UIFont.systemFontSize)
        }
        set{
            _mediumFont = newValue
        }
    }
    
    open func mediumFont(size: CGFloat) -> UIFont{
        if(_mediumFont != nil){
            return _mediumFont!.withSize(size)
        }
        let systemFont = UIFont.systemFont(ofSize: size, weight: .medium)
        guard let fontName = self.fontMediumName else {
            return systemFont
        }
        return UIFont.init(name: fontName, size: size) ?? systemFont
    }
    
    private var _boldFont: UIFont?
    open var boldFont: UIFont{
        get{
            return  _boldFont ?? self.boldFont(size: UIFont.systemFontSize)
        }
        set{
            _boldFont = newValue
        }
    }
    
    open func boldFont(size: CGFloat) -> UIFont{
        if(_boldFont != nil){
            return  _boldFont!.withSize(size)
        }
        let systemFont = UIFont.systemFont(ofSize: size, weight: .bold)
        guard let fontName = self.fontBoldName else{
            return systemFont
        }
        return UIFont.init(name: fontName, size: size) ?? systemFont
    }
    
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
        
        case fontRegularName
        case fontMediumName
        case fontBoldName
    }
    
    required public init(from decoder: Decoder) throws {
        super.init()
        
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
        
        if let fontRegularName = try container.decodeIfPresent(String.self, forKey: .fontRegularName){
           self.fontRegularName = fontRegularName
        }
        if let fontMediumName =  try container.decodeIfPresent(String.self, forKey: .fontMediumName){
           self.fontMediumName = fontMediumName
        }
        if let fontBoldName = try container.decodeIfPresent(String.self, forKey: .fontBoldName) {
           self.fontBoldName = fontBoldName
        }
        
        loadFonts()
    }
    
    private func loadFonts(){
//        let floatVersion = (UIDevice.current.systemVersion as NSString).floatValue
//        if (floatVersion >= 11){
//
//           if(self.fontRegularName == nil){
//               self.fontRegularName = "Helvetica-Regular"
//           }
//           if(self.fontBoldName == nil){
//               self.fontBoldName = "Helvetica-Bold"
//           }
//           if(self.fontMediumName == nil){
//               self.fontMediumName = "Helvetica-Medium"
//           }
//
//               let fontExtention = "ttf"
//               let fonts = [fontRegularName, fontMediumName, fontBoldName]
//               fonts.forEach { (fontName) in
//                   let bundle =  Bundle.init(for: UXFBTheme.self)
//                   if let fontUrl = bundle.url(forResource: fontName, withExtension: fontExtention){
//                       _ = loadFont(fontUrl: fontUrl)
//                   }
//               }
//        }
    }
    
    public override init() {
        super.init()
        loadFonts()
    }
    
    open func getSmile(imageName: String, completion: (_ smileImage: UIImage)->()) ->(UIImage?){
        let bundle = Bundle(for: UXFeedback.self)
        let image = UIImage.init(named: imageName, in: bundle, compatibleWith: nil)
        return image
    }
    
    open func smileImageName(by index: Int) -> (String){
        let names = ["angry", "mad", "confused", "happy", "in-love"]
        if index < names.count {
            return names[index]
        }
        else{
            return ""
        }
    }
    
    open func loadFont(fontUrl: URL) -> Bool {
        if let inData = try? Data(contentsOf: fontUrl) {
            var error: Unmanaged<CFError>?
            if let cfdata = CFDataCreate(nil, [UInt8](inData), inData.count),
                let provider = CGDataProvider(data: cfdata),
                let font = CGFont(provider) {
                    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
                        DDLogDebug("Failed to load font: \(String(describing: error))")
                    }
                    return true
                }
            }
        return false
    }
}
