//
//  UXFParser.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 01/05/2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import CocoaLumberjack

protocol UXFAPIParserProtocol {
   func parseCampaing(compaignInfo: Dictionary<String,Any>) -> (UXFCampaign?)
}

internal class UXFAPIParser : UXFAPIParserProtocol{
    
     func parseCampaing(compaignInfo: Dictionary<String,Any>) -> (UXFCampaign?){
            
            let type = compaignInfo["type"] as! String
            let targetingArr = compaignInfo["targeting"] as! Array<Dictionary<String, Any>>
            let campaingId = compaignInfo["campaignId"] as! String
            let progressDict = compaignInfo["progress"] as! Dictionary<String, Any>
            let progress = progressDict["enabled"] as! Bool
            
            var pages = Array<UXFPage>()
            if let pagesArrayOfDict = compaignInfo["pages"] as? Array<Dictionary<String, Any>> {
                
                for pageDict in pagesArrayOfDict{
                    DDLogDebug("page: \(pageDict)")
                    
                    let pageId =  pageDict["_id"] as! String
                    var fields: Array<UIView> = []
                    if let filedsInfoArr = pageDict["fields"] as? Array<Dictionary<String, Any>> {
                        for fieldInfo in  filedsInfoArr{
                            if let filed = UXFUIFabric.sharedInstance.parseUIElement(dictionary: fieldInfo){
                                fields.append(filed)
                            }
                        }
                    }
                    
                    /*var button: UXFButton?
                    if let buttonInfo = pageDict["button"] as? Dictionary<String, Any>{
                        button = UXFUIFabric.sharedInstance.parseUIElement(dictionary: buttonInfo) as? UXFButton
                    }*/
                    let page = UXFPage.init(_id: pageId,
                                            //button: button,
                                            fields: fields)
                    pages.append(page)
                }
            }
            
            return UXFCampaign.init(campaignId: campaingId,
                                        pages: pages,
                                        type: UXFCampaignType.init(rawValue: type),
                                        targetings: targetingArr,
                                        isProgressEnabled: progress)
    }
}
