//
//  UXFTheme.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation

enum UXFThemeType: Int {
    case custom = 0
    case light = 1
    case dark = 2
}

@objcMembers
open class UXFTheme:  NSObject, Decodable{
    
    open var titleColor: UIColor =  UIColor.init("#2F3552") //header
    open var errorColor: UIColor = UIColor.init("#E92436") //Alert comment color
    open var progressColor: UIColor = UIColor.black
    open var formRadius: CGFloat = 8.0
    open var textColor: UIColor = UIColor.init("#2F3552") //text
    open var inputBackgroundColor: UIColor = UIColor.init("#F6F6F7")
    open var inputTextColor: UIColor = UIColor.init("#F6F6F7")
    open var controlColor: UIColor = UIColor.init("#9699A7") // navigation label color
    open var backgroundColor: UIColor = UIColor.white //form background color

    open var fontRegularName: String = "Roboto-Regular"
    open var fontMediumName: String = "Roboto-Medium"
    open var fontBoldName: String = "Roboto-Bold"
    
    enum CodingKeys: String, CodingKey {
        case titleColor
        case errorColor
        case formRadius
        case progressColor
        case textColor
        case inputBackgroundColor
        case inputTextColor
        case controlColor
        case backgroundColor
        case fontRegularName
        case fontMediumName
        case fontBoldName
    }
    
    required public init(from decoder: Decoder) throws {
        
        super.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let titleColorString = try? container.decode(String.self, forKey: .titleColor){
           self.titleColor = UIColor.init(titleColorString)
        }
        if let errorColorString = try? container.decode(String.self, forKey: .errorColor){
            self.errorColor = UIColor.init(errorColorString)
        }
        if let radius: CGFloat =  try? container.decode(CGFloat.self, forKey: .formRadius) {
            self.formRadius = radius
        }
        if let textColorString = try? container.decode(String.self, forKey: .textColor){
            self.textColor = UIColor.init(textColorString)
        }
        if let inputBackgroundColorString = try? container.decode(String.self, forKey: .inputBackgroundColor){
            self.inputBackgroundColor = UIColor.init(inputBackgroundColorString)
        }
        if let inputTextColorString = try? container.decode(String.self, forKey: .inputTextColor){
            self.inputTextColor = UIColor.init(inputTextColorString)
        }
        if let backgroundColorString = try? container.decode(String.self, forKey: .backgroundColor){
            self.backgroundColor = UIColor.init(backgroundColorString)
        }
        if let controlColorString = try? container.decode(String.self, forKey: .controlColor){
            self.controlColor = UIColor.init(controlColorString)
        }
        if let progressColorString = try? container.decode(String.self, forKey: .progressColor){
            self.progressColor = UIColor.init(progressColorString)
        }
        if let fontName = try container.decodeIfPresent(String.self, forKey: .fontRegularName){
           self.fontRegularName = fontName
        }
        if let fontName =  try container.decodeIfPresent(String.self, forKey: .fontMediumName){
           self.fontMediumName = fontName
        }
        if let fontName = try container.decodeIfPresent(String.self, forKey: .fontBoldName) {
           self.fontBoldName = fontName
        }
        
        loadFonts()
    }
    
    private func loadFonts(){
        let fontExtention = "ttf"
        let fonts = [fontRegularName, fontMediumName, fontBoldName]
        fonts.forEach { (fontName) in
            let bundle =  Bundle.init(for: UXFTheme.self)
            if let fontUrl = bundle.url(forResource: fontName, withExtension: fontExtention){
                _ = loadFont(fontUrl: fontUrl)
            }
        }
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
