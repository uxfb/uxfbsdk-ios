//
//  UXFUIFabric.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 19.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import CocoaLumberjack
import UIColor_Hex_Swift

protocol UXFParserProtocol {
    func parseCampaing(compaignInfo: Dictionary<String,Any>) -> (UXFCampaign?)
}

class UXFParser : UXFParserProtocol{
    
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
                        if let filed = self.parseUIElement(dictionary: fieldInfo){
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
    
    func parseUIElement(dictionary: Dictionary<String, Any>)->(UIView?){
        
        if let type = dictionary["type"] as? String{
            switch type {
            case "button":
                return createButton(dictionary: dictionary)
            case "header":
                return createUIHeader(dictionary: dictionary)
            case "text":
                return createUIText(dictionary: dictionary)
            case "checkboxes":
                return createUICheckbox(dictionary: dictionary)
            case "smiles":
                return createSmiles(dictionary: dictionary)
            default:
                return nil
            }
        }
        
       return nil
    }
    
    private func createSmiles(dictionary: Dictionary<String, Any>) ->(UIView){
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 64))
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 24))
        label.text = dictionary["value"] as? String
        label.font =  label.font.withSize(16)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(label)
 
        
        let stackView = UIStackView.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 32))
        stackView.translatesAutoresizingMaskIntoConstraints = true
        stackView.backgroundColor = UIColor.gray
        view.addSubview(stackView)
        
        let views = ["label": label, "stackview": stackView]
        var allConstraints: [NSLayoutConstraint] = []
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-9-[label]-9-|",
                                                                    metrics: nil,
                                                                    views: views as [String : Any])
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-9-[stackview]-9-|",
                                                                    metrics: nil,
                                                                    views: views as [String : Any])
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label(24)]-15-[stackview(32)]-|",
                                                                 metrics: nil,
                                                                 views: views as [String : Any])
        view.backgroundColor = UIColor.red
        NSLayoutConstraint.activate(allConstraints)
        
        return view
    }
    
    private func createButton(dictionary: Dictionary<String, Any>)->(UXFButton){
        let button = UXFButton.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 33))
        button.titleLabel?.text = dictionary["value"] as? String
        return button
    }
    
    private func createUICheckbox(dictionary: Dictionary<String, Any>)->(UIView){
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 33))
        let switchView = UISwitch.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: view.bounds.size.height))
        view.addSubview(switchView)
        #warning("title not implemented")
        return view
    }
    
    private func createUIHeader(dictionary: Dictionary<String, Any>)->(UILabel){
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 33))
        label.text = dictionary["value"] as? String
        label.sizeToFit()
        return label
    }
    
    private func createUIText(dictionary: Dictionary<String, Any>)->(UILabel){
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 33))
        label.text = dictionary["value"] as? String
        label.sizeToFit()
        return label
    }
}
