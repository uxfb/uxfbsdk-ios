//
//  UXFUIFabric.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 19.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

class Parser {
    static let contenViewOffset: CGFloat = 15.0
    static let contentSubviewOffset: CGFloat = 8.0
    static let formControllerViewOffset: CGFloat = 16.0
    static let bottomOffset: CGFloat = 8
    
    private(set) var customTheme: Theme?
    private(set) var isInitTheme: Bool = false
    private var _uiGroupDictionary: Dictionary <String, Array<String>> = [:]
    private var containerWidth: CGFloat {
        return (UIScreen.main.bounds.width - (Parser.formControllerViewOffset + Parser.contenViewOffset)*2)
    }
    
    init(theme: Theme?, isInitTheme: Bool = false) {
        self.customTheme = theme
        self.isInitTheme = isInitTheme
    }
    
    func parseTheme(jsonDict: Dictionary<String,Any>) -> Theme? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted) {
           let theme = try! JSONDecoder().decode(Theme.self, from: jsonData)
           return theme
        }
        return nil
    }
    
     func parseCampaign(campaignInfo: Dictionary<String,Any>) -> Campaign?{
        
         let type = "\(campaignInfo["type"] as! Int)"
         let targetingArr = campaignInfo["targeting"] as! Array<Dictionary<String, Any>>
         let campaingId = "\(campaignInfo["campaignId"] as! Int)"
         let progressDict = campaignInfo["progress"] as? Dictionary<String, Any>
         let progress = (progressDict?["enabled"] as? Bool) ?? false
         let projectId = "\(campaignInfo["projectId"] as! Int)"
         let autoclose: Double = campaignInfo["autoclose"] as? Double ?? 0.0
         let showCopyright: Bool = campaignInfo["showCopyright"] as? Bool ?? true
         
        
        var theme: Theme?
        if let customTheme = self.customTheme, isInitTheme == true {
            theme = customTheme
        }
        else {
            theme = Theme.init()
            if let design = campaignInfo["design"] as? Dictionary<String, Any>,
               let themeType = ThemeType.init(rawValue: (design["theme"] as? Int) ?? 0),
                   themeType == .custom {
                if let campaignTheme = parseTheme(jsonDict: design) {
                   theme = campaignTheme
                }
            }
        }
        
        var pages = Array<Page>()
        if let pagesArrayOfDict = campaignInfo["pages"] as? Array<Dictionary<String, Any>> {
            for pageDict in pagesArrayOfDict{
                DDLogDebug("page: \(pageDict)")
                let pageId: String? = pageDict["id"] as? String
                let type: Int? = pageDict["type"] as? Int
                let fieldsDict = pageDict["fields"] as? Array<Dictionary<String, Any>> ?? []
                var fields = Array<Field>()
                for fieldDict in fieldsDict {
                    let fieldId: String? = fieldDict["id"] as? String
                    let fieldType: String? = fieldDict["type"] as? String
                    let fieldValue: String? = fieldDict["value"] as? String
                    let field = Field(id: fieldId,
                                         type: FieldType(rawValue: fieldType ?? ""),
                                         value: fieldValue,
                                         uiData: fieldDict)
                    fields.append(field)
                }
                
                let buttonsDict = pageDict["buttons"] as? Array<Dictionary<String, Any>> ?? []
                var buttons = Array<Field>()
                for buttonDict in buttonsDict {
                    let buttonId: String? = buttonDict["id"] as? String
                    let buttonType: String? = buttonDict["type"] as? String
                    let buttonValue: String? = buttonDict["value"] as? String
                    let button = Field(id: buttonId,
                                          type: FieldType(rawValue: buttonType ?? ""),
                                          value: buttonValue,
                                          uiData: buttonDict)
                    buttons.append(button)
                }
                let page = Page.init(id: pageId,
                                        type: type,
                                        fields: fields,
                                        buttons: buttons)
                pages.append(page)
            }
        }
        
        var transformArr = Array<Transform>()
        if let transformsArrayOfDict = campaignInfo["transforms"] as? Array<Dictionary<String, Any>> {
            for transformDict in transformsArrayOfDict{
                DDLogDebug("transform: \(transformDict)")
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: transformDict, options: [])
                    let decoder = JSONDecoder()
                    let transform = try decoder.decode(Transform.self, from: jsonData)
                    
                    transformArr.append(transform)
                } catch {
                    print(error)
                }
            }
        }

        return Campaign(campaignId: campaingId,
                           theme: theme,
                           pages: pages,
                           type: CampaignType.init(rawValue: type),
                           targetings: targetingArr,
                           transforms: transformArr,
                           isProgressEnabled: progress,
                           projectId: projectId,
                           autoclose: autoclose,
                           showCopyright: showCopyright)
    }
}
