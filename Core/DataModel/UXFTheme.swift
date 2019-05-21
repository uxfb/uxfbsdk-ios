//
//  UXFTheme.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import HEXColor

open class UXFTheme{
    
    open var titleColor: UIColor = UIColor.init("#2F3552") //header
    open var textColor: UIColor = UIColor.init("#2F3552") //text
    open var accendentTextColor: UIColor = UIColor.green
    open var accentColor: UIColor  = UIColor.green
    open var backgroundColor: UIColor = UIColor.white //form background color
    open var errorColor: UIColor = UIColor.init("#E92436") //Alert comment color
    open var cardColor: UIColor = UIColor.yellow
    open var formCornerRadius: CGFloat = 8.0
    open var progressColor: UIColor = UIColor.init("#9699A7") // navigation label color
    open var fontRegularName: String = "Roboto-Regular"
    open var fontMediumName: String = "Roboto-Medium"
    open var fontLightName: String = "Roboto-Light"
    open var fontBoldName: String = "Roboto-Bold"
    
    public init(){
       
    }
    
    public init(colorsDict: Dictionary<String, String>,
         smilesDict: Dictionary<String, String>) {
 
        if let titleColorString = colorsDict["title"]{
           titleColor = UIColor(titleColorString)
        }
        if let textColorString = colorsDict["text"] {
           textColor = UIColor(textColorString)
        }
        if let accendentColorString = colorsDict["accentedText"] {
          accendentTextColor = UIColor(accendentColorString)
        }
        if let accentColorString = colorsDict["accent"] {
          accentColor = UIColor(accentColorString)
        }
        if let backgroundColorString = colorsDict["background"] {
            backgroundColor = UIColor(backgroundColorString)
        }
        if let errorColorString = colorsDict["error"] {
           errorColor = UIColor(errorColorString)
        }
        if let cardColorString = colorsDict["card"] {
           cardColor = UIColor(cardColorString)
        }
        if let progrressColorString = colorsDict["progressColor"] {
            progressColor = UIColor(progrressColorString)
        }
        
        let fontExtention = "ttf"
        let fonts = [fontRegularName, fontMediumName, fontLightName, fontBoldName]
        fonts.forEach { (fontName) in
            let bundle =  Bundle.init(for: UXFTheme.self)
            if let fontUrl = bundle.url(forResource: fontName, withExtension: fontExtention){
               _ = loadFont(fontUrl: fontUrl)
            }
        }
       
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
