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
    
    private(set) var customTheme: ThemeProtocol?
    private(set) var isInitTheme: Bool = false
    private var _uiGroupDictionary: Dictionary <String, Array<String>> = [:]
    private var containerWidth: CGFloat {
        return (UIScreen.main.bounds.width - (Parser.formControllerViewOffset + Parser.contenViewOffset)*2)
    }
    
    init(theme: ThemeProtocol?, isInitTheme: Bool = false) {
        self.customTheme = theme
        self.isInitTheme = isInitTheme
    }
    
    func parseCampaignData(campaignDataInfo: Dictionary<String,Any>,
                           copyright: Copyright?,
                           textProperties: TextProperties?) -> CampaignData? {
        if let id = campaignDataInfo["campaignId"] as? Int,
           let priority = campaignDataInfo["priority"] as? Int {
            
            var jsonData: Data?
            if let dict = campaignDataInfo["data"] as? Dictionary<String, Any> {
                jsonData = try? JSONSerialization.data(withJSONObject: dict)
            }
            
            var copyrightData: Data?
            var textPropertiesData: Data?
            if let copyrightDict = copyright?.dict {
                copyrightData = try? JSONSerialization.data(withJSONObject: copyrightDict)
            }
            if let textPropertiesDict = textProperties?.dict {
                textPropertiesData = try? JSONSerialization.data(withJSONObject: textPropertiesDict)
            }
            
            return CampaignData(campaignId: id,
                                priority: priority,
                                data: jsonData,
                                copyright: copyrightData,
                                textProperties: textPropertiesData)
        }
        
        return nil
    }
    
    func parseCampaign(campaignInfo: Dictionary<String,Any>,
                       copyright: Copyright?,
                       textProperties: TextProperties?) -> Campaign? {
        
        let type = "\(campaignInfo["type"] as! Int)"
        let campaingId = campaignInfo["campaignId"] as! Int
        let projectId = "\(campaignInfo["projectId"] as! Int)"
        let autoclose: Double = campaignInfo["autoclose"] as? Double ?? 0.0
        let progress: Bool = campaignInfo["progress"] as? Bool ?? false
        
        var targetings: Targeting?
        if let targetingDict = campaignInfo["targeting"] as? Dictionary<String, Any> {
            if let triggerDict = targetingDict["trigger"] {
                targetings = try? Targeting(from: triggerDict)
            } else {
                targetings = Targeting()
            }
        }
        
        var theme: ThemeProtocol?
        if let customTheme = self.customTheme, isInitTheme == true {
            theme = customTheme
        }
        else {
            theme = Theme.init()
            if let design = campaignInfo["design"] as? Dictionary<String, Any>,
               let themeType = ThemeType.init(rawValue: (design["theme"] as? Int) ?? 0),
                   themeType == .custom {
                if let campaignTheme = try? Theme(from: design) {
                    theme = campaignTheme
                }
            }
        }
        
        let pages: [Page] = (try? [Page](from: campaignInfo["pages"] as Any)) ?? []
        let transformArr: [Transform] = (try? [Transform](from: campaignInfo["transforms"] as Any)) ?? []
        let privacy: Privacy? = (campaignInfo["privacy"] as? Dictionary<String, Any>).flatMap { try? Privacy(from: $0) }
        let campaignTextProperties: TextProperties? = (campaignInfo["textProperties"] as? Dictionary<String, Any>).flatMap { try? TextProperties(from: $0) }
        
         return Campaign(campaignId: campaingId,
                         theme: theme,
                         pages: pages,
                         type: CampaignType.init(rawValue: type),
                         targeting: targetings,
                         transforms: transformArr,
                         projectId: projectId,
                         autoclose: autoclose,
                         copyright: copyright,
                         privacy: privacy,
                         progress: progress,
                         textProperties: campaignTextProperties ?? textProperties)
    }
}
