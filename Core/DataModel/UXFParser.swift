//
//  UXFUIFabric.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 19.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

class UXFParser {
    static let contenViewOffset: CGFloat = 15.0
    static let contentSubviewOffset: CGFloat = 8.0
    static let formControllerViewOffset: CGFloat = 16.0
    static let bottomOffset: CGFloat = 8
    
    private(set) var customTheme: UXFBTheme?
    private(set) var isInitTheme: Bool = false
    private var _uiGroupDictionary: Dictionary <String, Array<String>> = [:]
    private var containerWidth: CGFloat {
        return (UIScreen.main.bounds.width - (UXFParser.formControllerViewOffset + UXFParser.contenViewOffset)*2)
    }
    
    init(theme: UXFBTheme?, isInitTheme: Bool = false) {
        self.customTheme = theme
        self.isInitTheme = isInitTheme
    }
    
    func parseTheme(jsonDict: Dictionary<String,Any>) -> UXFBTheme? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted) {
           let theme = try! JSONDecoder().decode(UXFBTheme.self, from: jsonData)
           return theme
        }
        return nil
    }
    
     func parseCampaign(campaignInfo: Dictionary<String,Any>) -> UXFCampaign?{
        
         let type = "\(campaignInfo["type"] as! Int)"
         let targetingArr = campaignInfo["targeting"] as! Array<Dictionary<String, Any>>
         let campaingId = "\(campaignInfo["campaignId"] as! Int)"
         let progressDict = campaignInfo["progress"] as? Dictionary<String, Any>
         let progress = (progressDict?["enabled"] as? Bool) ?? false
         let projectId = "\(campaignInfo["projectId"] as! Int)"
         let autoclose: Double = campaignInfo["autoclose"] as? Double ?? 0.0
         let showCopyright: Bool = campaignInfo["showCopyright"] as? Bool ?? true
         
        
        var theme: UXFBTheme?
        if let customTheme = self.customTheme, isInitTheme == true {
            theme = customTheme
        }
        else {
            theme = UXFBTheme.init()
            if let design = campaignInfo["design"] as? Dictionary<String, Any>,
               let themeType = UXFBThemeType.init(rawValue: (design["theme"] as? Int) ?? 0),
                   themeType == .custom {
                if let campaignTheme = parseTheme(jsonDict: design) {
                   theme = campaignTheme
                }
            }
        }
        
        var pages = Array<UXFPage>()
        if let pagesArrayOfDict = campaignInfo["pages"] as? Array<Dictionary<String, Any>> {
            for pageDict in pagesArrayOfDict{
                DDLogDebug("page: \(pageDict)")
                let pageId: String? = pageDict["id"] as? String
                let type: Int? = pageDict["type"] as? Int
                let fieldsDict = pageDict["fields"] as? Array<Dictionary<String, Any>> ?? []
                var fields = Array<UXFField>()
                for fieldDict in fieldsDict {
                    let fieldId: String? = fieldDict["id"] as? String
                    let fieldType: String? = fieldDict["type"] as? String
                    let fieldValue: String? = fieldDict["value"] as? String
                    let field = UXFField(id: fieldId,
                                         type: UXFFieldType(rawValue: fieldType ?? ""),
                                         value: fieldValue,
                                         uiData: fieldDict)
                    fields.append(field)
                }
                
                let buttonsDict = pageDict["buttons"] as? Array<Dictionary<String, Any>> ?? []
                var buttons = Array<UXFField>()
                for buttonDict in buttonsDict {
                    let buttonId: String? = buttonDict["id"] as? String
                    let buttonType: String? = buttonDict["type"] as? String
                    let buttonValue: String? = buttonDict["value"] as? String
                    let button = UXFField(id: buttonId,
                                          type: UXFFieldType(rawValue: buttonType ?? ""),
                                          value: buttonValue,
                                          uiData: buttonDict)
                    buttons.append(button)
                }
                let page = UXFPage.init(id: pageId,
                                        type: type,
                                        fields: fields,
                                        buttons: buttons)
                pages.append(page)
            }
        }
        
        var transformArr = Array<UXFTransform>()
        if let transformsArrayOfDict = campaignInfo["transforms"] as? Array<Dictionary<String, Any>> {
            for transformDict in transformsArrayOfDict{
                DDLogDebug("transform: \(transformDict)")
                let id: String? = transformDict["id"] as? String
                let rule: String? = transformDict["rule"] as? String
                let action: String? = transformDict["action"] as? String
                let fromField: String? = transformDict["fromField"] as? String
                let toField: String? = transformDict["toField"] as? String
                let fromButton: String? = transformDict["fromButton"] as? String
                let toButton: String? = transformDict["toButton"] as? String
                let fromPage: String? = transformDict["fromPage"] as? String
                let toPage: String? = transformDict["toPage"] as? String
                var valueArr: [String] = []
                if let value = transformDict["value"] as? [String] {
                    valueArr = value
                } else if let value = transformDict["value"] as? [Int] {
                    valueArr = value.map({ String($0) })
                }
                
                
                let transform = UXFTransform(id: id,
                                             rule: rule,
                                             action: action,
                                             value: valueArr,
                                             fromField: fromField,
                                             toField: toField,
                                             fromButton: fromButton,
                                             toButton: toButton,
                                             fromPage: fromPage,
                                             toPage: toPage)
                transformArr.append(transform)
            }
        }

        
        return UXFCampaign(campaignId: campaingId,
                           theme: theme,
                           pages: pages,
                           type: UXFCampaignType.init(rawValue: type),
                           targetings: targetingArr,
                           transforms: transformArr,
                           isProgressEnabled: progress,
                           projectId: projectId,
                           autoclose: autoclose,
                           showCopyright: showCopyright)
    }
}
