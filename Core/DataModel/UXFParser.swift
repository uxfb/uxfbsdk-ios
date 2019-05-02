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

class UXFParser{
    
    class func parseCampaing(compaignInfo: Dictionary<String,Any>) -> (UXFCampaign?){
        
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
                let page = UXFPage.init(id: pageId, uiData: pageDict)
                pages.append(page)
            }
        }
        
        return UXFCampaign.init(campaignId: campaingId,
                                pages: pages,
                                type: UXFCampaignType.init(rawValue: type),
                                targetings: targetingArr,
                                isProgressEnabled: progress)
    }
    
    //MARK: support
    
    internal class func parseUIElement(dictionary: Dictionary<String, Any>, submitHandler: ((Dictionary<String,Any>)->())?)->(UIView?){
        
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
                return createSmiles(dictionary: dictionary, submitHandler: submitHandler)
            default:
                return nil
            }
        }
        
       return nil
    }
    
    private class func createSmiles(dictionary: Dictionary<String, Any>, submitHandler: ((Dictionary<String,Any>)->())?) ->(UIView){
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 44))
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 24))
        label.text = dictionary["value"] as? String
        let labelFontSize: CGFloat = (IS_IPAD == true ? 24.0 : 16.0)
        label.font =  label.font.withSize(labelFontSize)
        label.textAlignment = .center
        label.sizeToFit()
        //label.backgroundColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
 
        let stackViewHeight: CGFloat = IS_IPAD == true ? 48.0 : 40.0
        let stackView = UIStackView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: stackViewHeight))
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 5
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        
        let smilesInfo = dictionary["smiles"] as! Dictionary<String, Any>
        self.createSmiles(info: smilesInfo, layoutView: stackView, submitHandler: submitHandler)

        let views = ["label": label, "stackview": stackView]
        var allConstraints: [NSLayoutConstraint] = []
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|",
                                                                    metrics: nil,
                                                                    views: views as [String : Any])
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[stackview(==label@750,<=414)]",
                                                                    metrics: nil,
                                                                    views: views as [String : Any])
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label(>=\(labelFontSize))]-15-[stackview(\(stackViewHeight))]-33@750-|",
             options: [.alignAllCenterX],
                                                                 metrics: nil,
                                                                 views: views as [String : Any])
        //view.backgroundColor = UIColor.blue
        view.addConstraints(allConstraints)
        
        return view
    }
    
    private class func createButton(dictionary: Dictionary<String, Any>)->(UXFButton){
        let button = UXFButton.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 33))
        button.titleLabel?.text = dictionary["value"] as? String
        return button
    }
    
    private class func createUICheckbox(dictionary: Dictionary<String, Any>)->(UIView){
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 33))
        let switchView = UISwitch.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: view.bounds.size.height))
        view.addSubview(switchView)
        #warning("title not implemented")
        return view
    }
    
    private class func createUIHeader(dictionary: Dictionary<String, Any>)->(UILabel){
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 33))
        label.text = dictionary["value"] as? String
        label.sizeToFit()
        return label
    }
    
    private class func createUIText(dictionary: Dictionary<String, Any>)->(UILabel){
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 33))
        label.text = dictionary["value"] as? String
        label.sizeToFit()
        return label
    }
    
    //MARK: - Smiles
    
    private class func createSmiles(info:  Dictionary<String, Any>,
                              layoutView: UIStackView,
                              submitHandler: ((Dictionary<String,Any>)->())?){
        let smilesKeys = info.keys.sorted()
        
        for smileKey in smilesKeys{
            let smileIndex = Int(smileKey)!
            let button = self.createSmileButton(info: info[smileKey] as! Dictionary<String, Any>,
                                                smileIndex: smileIndex)
            var buttonWidth = layoutView.bounds.size.width/CGFloat(smilesKeys.count)
            let buttonHeight = layoutView.bounds.size.height
            if buttonWidth > buttonHeight{
                buttonWidth = buttonHeight
            }
            button.frame =  CGRect.init(x: 0,
                                        y: 0,
                                        width: buttonWidth,
                                        height: buttonHeight)
            layoutView.addArrangedSubview(button)
            button.addAction(for: .touchUpInside) {
                submitHandler?(["smiles0" : button.index])
            }
        }
    }
    
    private class func createSmileButton(info: Dictionary<String, Any>,
                                   smileIndex: Int) -> (UXFSmileButton){
        
        let button = UXFSmileButton.init(index: smileIndex,
                                         isRequired: info["isRequered"] as? Bool,
                                         warning: info["warning"] as? String,
                                         hint: info["hint"] as? String)
        button.imageView?.contentMode = .scaleAspectFit
        if #available(iOS 11.0, *) {
            button.adjustsImageSizeForAccessibilityContentSizeCategory = true
        }
        let imageName =  UXFParser.smileImageName(by: smileIndex)
        let previewButtonImage =  UXFParser.getSmile(imageName: imageName, completion: { (image) in
            button.setImage(image, for: UIControl.State.normal)
        })
        button.setImage(previewButtonImage, for: UIControl.State.normal)
        
        return button
    }
    
    class func getSmile(imageName: String, completion: (_ smileImage: UIImage)->()) ->(UIImage?){
        return UIImage.init(named: imageName)
    }
    
    class func smileImageName(by index: Int) -> (String){
        let names = ["angry", "mad", "confused", "happy", "in-love"]
        if index < names.count {
            return names[index]
        }
        else{
            return ""
        }
    }
}
