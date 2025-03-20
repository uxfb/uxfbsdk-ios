//
//  TextManager.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 23.02.2025.
//  Copyright © 2025 UXF. All rights reserved.
//

import UIKit

internal class TextPropertyManager {
    
    private static var textProperties: TextProperties = TextProperties(h1: [TextProperty(name: "#",
                                                                                         type: "size",
                                                                                         value: "1,09/1,11"),
                                                                            TextProperty(name: "##",
                                                                                         type: "size",
                                                                                         value: "0,88/0,91")],
                                                                       h2: [TextProperty(name: "#",
                                                                                         type: "size",
                                                                                         value: "1,1/1,17"),
                                                                            TextProperty(name: "##",
                                                                                         type: "size",
                                                                                         value: "0,9/0,92")],
                                                                       p: [TextProperty(name: "#",
                                                                                        type: "size",
                                                                                        value: "1,13/1,19"),
                                                                           TextProperty(name: "##",
                                                                                        type: "size",
                                                                                        value: "0,88/0,92")])
    
    //MARK: - Tags
    // <str>text</str> - жирный
    // <em>text</em> - курсив
    // <s></s> - зачеркнутый
    // <a>text|https://link.com<a> - ссылка
    
    //MARK: - Alignment
    // <left> - лево
    // <center> - центр
    // <right> - право
    
    
    /*
     EXAMPLE
     
     "h1<#><center> Насколько <em><str>легко<str> пользоваться<em> <s>не<s> нашим <a>классным сайтом|https://a.com<a>?"
     */
    
    //MARK: - Implementations
    
    private enum TextPropertyAlignment: String {
        case left = "<left>"
        case center = "<center>"
        case right = "<right>"
        case req = "<req>"
    }
    
    private enum TextPropertyStyle: String {
        case h1 = "<h1>"
        case h2 = "<h2>"
        case p = "<p>"
    }
    
    private enum TextPropertySize: String {
        case big = "<#>"
        case small = "<##>"
    }
    
    static func heightForAttributed(string: NSAttributedString, and maxWidth: CGFloat) -> CGFloat {
        
        let boundingRect = string.boundingRect(with: .init(width: maxWidth,
                                                           height: .greatestFiniteMagnitude),
                                               options: [.usesLineFragmentOrigin, .usesFontLeading],
                                               context: nil)

        let height = boundingRect.height
        
        return height
    }
    
    static func convert(_ data: String, theme: ThemeProtocol, defaultFont: UIFont, textProperties: TextProperties?, withRequired: Bool) -> NSAttributedString {
        if let textProperties = textProperties {
            Self.textProperties = textProperties
        }
        
        let text = "\(withRequired ? "* " : "")\(data)"
        
        
        let newFont = getFont(from: data, and: defaultFont)
        
        let paragraphStyle = Self.paragraphStyle(string: data)
        
        let clearString = clearParagraphTags(text)
        
        let attributedString = Self.transformStringWithCustomTags(input: clearString,
                                                                  defaultFont: newFont,
                                                                  theme: theme)
        
        if let paragraphStyle = paragraphStyle {
            attributedString.addAttribute(.paragraphStyle,
                                          value: paragraphStyle,
                                          range: NSRange(location: 0,
                                                         length: attributedString.length))
        }
        
        
        let range = (text as NSString).range(of: "*")
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                      value: theme.errorColorPrimary,
                                      range: range)
        
        return attributedString
    }
    
    private static func clearParagraphTags(_ input: String) -> String {
        var resultString = input
        
        resultString = resultString.replacingOccurrences(of: TextPropertyAlignment.left.rawValue, with: "")
        resultString = resultString.replacingOccurrences(of: TextPropertyAlignment.center.rawValue, with: "")
        resultString = resultString.replacingOccurrences(of: TextPropertyAlignment.right.rawValue, with: "")
        resultString = resultString.replacingOccurrences(of: TextPropertyAlignment.req.rawValue, with: "")
        
        resultString = resultString.replacingOccurrences(of: TextPropertyStyle.h1.rawValue, with: "")
        resultString = resultString.replacingOccurrences(of: TextPropertyStyle.h2.rawValue, with: "")
        resultString = resultString.replacingOccurrences(of: TextPropertyStyle.p.rawValue, with: "")
        
        resultString = resultString.replacingOccurrences(of: TextPropertySize.big.rawValue, with: "")
        resultString = resultString.replacingOccurrences(of: TextPropertySize.small.rawValue, with: "")
        
        return resultString
    }
    
    private static func getFont(from string: String, and defaultFont: UIFont) -> UIFont {
        
        
        var value: String?
        
        var sizeName = ""
        
        if string.contains(TextPropertySize.big.rawValue) {
            sizeName = String(String(TextPropertySize.big.rawValue.dropLast()).dropFirst())
        } else if string.contains(TextPropertySize.small.rawValue) {
            sizeName = String(String(TextPropertySize.small.rawValue.dropLast()).dropFirst())
        }
        
        if string.contains(TextPropertyStyle.h1.rawValue) {
            value = textProperties.h1?.first(where: { property in
                property.name == sizeName
            })?.value
        } else if string.contains(TextPropertyStyle.h2.rawValue) {
            value = textProperties.h2?.first(where: { property in
                property.name == sizeName
            })?.value
        } else if string.contains(TextPropertyStyle.p.rawValue) {
            value = textProperties.p?.first(where: { property in
                property.name == sizeName
            })?.value
        }
        
        let usingValues = (value ?? "1,0/1,0").split(separator: "/")
        
        var kFontSize: Float = 1.0
        //        var kLineHeight: Float = 1.0
        
        if usingValues.count == 2 {
            let formatter = NumberFormatter()
            formatter.locale = Locale(identifier: "fr_FR") // French locale uses comma as decimal separator
            formatter.decimalSeparator = ","
            
            if let number = formatter.number(from: String(usingValues[0])) {
                let floatValue = number.floatValue
                kFontSize = floatValue
            }
            
            //            if let number = formatter.number(from: String(usingValues[1])) {
            //                let floatValue = number.floatValue
            //                kLineHeight = floatValue
            //            }
        }
        
        let font = defaultFont.withSize(defaultFont.pointSize * CGFloat(kFontSize))
        
        return font
    }
    
    private static func paragraphStyle(string: String) -> NSMutableParagraphStyle? {
        let paragraphStyle = NSMutableParagraphStyle()
        
        if string.contains(TextPropertyAlignment.left.rawValue) {
            paragraphStyle.alignment = .left
        } else if string.contains(TextPropertyAlignment.center.rawValue) {
            paragraphStyle.alignment = .center
        } else if string.contains(TextPropertyAlignment.right.rawValue) {
            paragraphStyle.alignment = .right
        }
        
        return paragraphStyle
    }
    
    private static func transformStringWithCustomTags(input: String, defaultFont: UIFont, theme: ThemeProtocol) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: input)
        attributedString.addAttribute(.font,
                                      value: defaultFont,
                                      range: NSRange(location: 0, length: attributedString.length))
        
        let traits = defaultFont.fontDescriptor.symbolicTraits
        
        var italicFont = defaultFont
        
        if let italicFontDescriptor = defaultFont.fontDescriptor.withSymbolicTraits([traits, .traitItalic]) {
            italicFont = UIFont(descriptor: italicFontDescriptor, size: defaultFont.pointSize)
        }
        
        var strongFont = defaultFont
        
        if let strongFontDescriptor = defaultFont.fontDescriptor.withSymbolicTraits([traits, .traitBold]) {
            strongFont = UIFont(descriptor: strongFontDescriptor, size: defaultFont.pointSize)
        }
        
        
        let tagPatterns = [
            ("<em>", [NSAttributedString.Key.font: italicFont]),
            ("<str>", [NSAttributedString.Key.font: strongFont]),
            ("<s>", [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]),
            ("<a>", [NSAttributedString.Key.font: defaultFont,
                     NSAttributedString.Key.foregroundColor: theme.btnBgColor,
                     NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        ]
        
        for (tag, attributes) in tagPatterns {
            var searchRange = NSRange(location: 0, length: attributedString.length)
            
            while searchRange.location < attributedString.length {
                let openTagRange = (attributedString.string as NSString).range(of: tag, options: [], range: searchRange)
                if openTagRange.location == NSNotFound { break }
                
                attributedString.replaceCharacters(in: openTagRange, with: "")
                
                searchRange.location = openTagRange.location
                searchRange.length = attributedString.length - openTagRange.location
                
                let closeTagRange = (attributedString.string as NSString).range(of: tag, options: [], range: searchRange)
                if closeTagRange.location == NSNotFound { break }
                
                attributedString.replaceCharacters(in: closeTagRange, with: "")
                
                let contentRange = NSRange(location: openTagRange.location, length: closeTagRange.location - openTagRange.location)
                
                if tag == "<a>" {
                    let linkComponents = (attributedString.string as NSString).substring(with: contentRange).components(separatedBy: "|")
                    
                    var attributesInRange: [NSAttributedString.Key: Any] = [:]

                    attributedString.enumerateAttributes(in: contentRange, options: []) { attributes, range, _ in
                        attributesInRange = attributes
                    }
                    
                    if linkComponents.count == 2 {
                        let linkText = linkComponents[0]
                        let linkURLString = linkComponents[1]
                        
                        if let linkURL = URL(string: linkURLString) {
                            let linkAttributedString = NSMutableAttributedString(string: linkText)
                            
                            let linkAttributes: [NSAttributedString.Key: Any] = [
                                .link: linkURL
                            ]
                            
                            linkAttributedString.addAttributes(attributes,
                                                               range: NSRange(location: 0,
                                                                              length: linkAttributedString.length))
                            linkAttributedString.addAttributes(linkAttributes,
                                                               range: NSRange(location: 0,
                                                                              length: linkAttributedString.length))
                            linkAttributedString.addAttributes(attributesInRange,
                                                               range: NSRange(location: 0,
                                                                              length: linkAttributedString.length))
                            
                            attributedString.replaceCharacters(in: contentRange, with: linkAttributedString)
                        }
                    }
                } else {
                    attributedString.addAttributes(attributes, range: contentRange)
                }
                
                searchRange.location = closeTagRange.location
                searchRange.length = attributedString.length - closeTagRange.location
            }
        }
        
        return attributedString
        
    }
}
