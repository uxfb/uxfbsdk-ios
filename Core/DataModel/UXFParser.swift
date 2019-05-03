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
import UITextField_Blocks

class UXFParser{
    
    static let contenViewOffset: CGFloat = 15.0
    static let contentSubviewOffset: CGFloat = 8.0
    static let formControllerViewOffset: CGFloat = 16.0
    
    public static let sharedInstance = UXFParser.init()
    private var _uiGroupDictionary: Dictionary <String, Array<String>> = [:]
    
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
    
    internal  func parseUIElement(dictionary: Dictionary<String, Any>,
                                  submitHandler: ((Dictionary<String,Any>)->())?)->(UIView?){
        
        var groupView: UIView? = nil
        
        if let type = dictionary["type"] as? String{
            
            var groupIndex = 0
            if let groupID = dictionary["_id"] as? String {
                if var groupIDs = _uiGroupDictionary[type]{
                    
                    let index =  groupIDs.firstIndex(where: { (value) -> Bool in
                        return groupID == value
                    })
                    if index == nil {
                        groupIDs.append(groupID)
                        groupIndex = (groupIDs.count - 1)
                    }
                }
                else{
                    _uiGroupDictionary[type] = [groupID]
                }
            }
            let groupID = "\(type)\(groupIndex)"
            
            switch type {
            case "button":
                groupView =  createButton(dictionary: dictionary, groupID: groupID)
                break
            case "header":
                groupView =  createUIHeader(dictionary: dictionary, groupID: groupID)
                break
            case "text":
                groupView =  createUIText(dictionary: dictionary, groupID: groupID)
                break
            case "checkboxes":
                groupView = createUICheckbox(dictionary: dictionary, groupID: groupID)
                break
            case "smiles":
                groupView = createSmiles(dictionary: dictionary, groupID: groupID, submitHandler: submitHandler)
                break
            case "comment":
                groupView = createComment(dictionary: dictionary, groupID: groupID, submitHandler: submitHandler)
                break
            default:
               groupView = nil
               break
            }
            
            groupView?.tag = groupIndex
        }
        
       return groupView
    }
    
    private func createComment(dictionary: Dictionary<String, Any>,
                               groupID: String,
                               submitHandler: ((Dictionary<String,Any>)->())?) ->(UIView){
        
        let view = UIView.init(frame: CGRect.init(x: 0,
                                                  y: 0,
                                                  width: (UIScreen.main.bounds.width - (UXFParser.formControllerViewOffset + UXFParser.contenViewOffset)*2),
                                                  height: 44))
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 24))
        label.text = dictionary["value"] as? String
        let labelFontSize: CGFloat = (IS_IPAD == true ? 20.0 : 16.0)
        label.font =  label.font.withSize(labelFontSize)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        //label.backgroundColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
  
        /*var labelHeight = labelFontSize
        if let text = label.text {
            labelHeight = text.height(withConstrainedWidth: (view.frame.size.width - UXFParser.contentSubviewOffset*2), font: label.font)
        }*/
        let labelHeight = labelFontSize * 2.5//label.frame.size.height
        
        let textFieldHeight = 48.0
        
        var commentFields:Array<UXFTextField> = []
        var commentAlerts: Array<UILabel> = []
        if  let commentsInfo = dictionary["customComments"] as? Dictionary<String, Any>,
            let enabledComments = commentsInfo["enabled"] as? Bool, enabledComments == true,
            let comments = commentsInfo["comments"] as? Dictionary<String, String>{
            
            for commentKey in comments.keys.sorted(){
                let comment = comments[commentKey]
                
                let textField = UXFTextField.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 48))
                textField.contentLeftPadding = 16.0
                //textField.borderStyle = .line
                //textField.setContentHuggingPriority(UILayoutPriority.init(rawValue: 251), for: .vertical)
                textField.backgroundColor = UIColor.init("#F6F6F7")
                textField.shouldChangeCharactersInRangeBlock = { (textInput, range, text)->(Bool) in
                    if let inputTextField = textInput as? UXFTextField{
                        inputTextField.inputState = inputTextField.text?.count ?? 0 > 0 ? .input : .normal
                    }
                    return true
                }
                textField.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(textField)
                commentFields.append(textField)
                
                let alertLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 24))
                alertLabel.textAlignment = .left
                alertLabel.font =  alertLabel.font.withSize(14.0)
                alertLabel.textColor = UIColor.init("#E92436")
                alertLabel.text = "Заполните обязательное поле".localized()
                alertLabel.translatesAutoresizingMaskIntoConstraints = false
                
                view.addSubview(alertLabel)
                commentAlerts.append(alertLabel)
            }
        }
        
        var views: Dictionary <String, Any> = ["label": label]
        var index = 0
        for textField in commentFields{
            views["textField\(index)"] =  textField
            index += 1
        }
        
        index = 0
        for alertLabel in commentAlerts{
             views["alertLabel\(index)"] = alertLabel
             index += 1
        }
    
       
        var allConstraints: [NSLayoutConstraint] = []
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(UXFParser.contentSubviewOffset)-[label]-\(UXFParser.contentSubviewOffset)-|",
                                                         metrics: nil,
                                                         views: views as [String : Any])
        
        for textFieldIndex in 0..<commentFields.count{
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(UXFParser.contentSubviewOffset)-[textField\(textFieldIndex)]-\(UXFParser.contentSubviewOffset)-|",
                metrics: nil,
                views: views as [String : Any])
        }
        
        for alertLabelIndex in 0..<commentAlerts.count{
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(UXFParser.contentSubviewOffset)-[alertLabel\(alertLabelIndex)]-\(UXFParser.contentSubviewOffset)-|",
                metrics: nil,
                views: views as [String : Any])
        }

        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label(>=\(labelHeight))]-11-[textField0(\(textFieldHeight))]-11-[alertLabel0(17)]-65@750-|",
            options: [.alignAllCenterX],
            metrics: nil,
            views: views as [String : Any])
        
        view.addConstraints(allConstraints)
        //view.backgroundColor = UIColor.blue
        
        return view
    }
    
    private  func createSmiles(dictionary: Dictionary<String, Any>,
                                  groupID: String,
                            submitHandler: ((Dictionary<String,Any>)->())?) ->(UIView){
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 44))
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 24))
        label.text = dictionary["value"] as? String
        let labelFontSize: CGFloat = (IS_IPAD == true ? 20.0 : 16.0)
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
        self.createSmileButtons(info: smilesInfo,
                                layoutView: stackView,
                                groupId: groupID,
            submitHandler: submitHandler)

        let views = ["label": label, "stackview": stackView]
        var allConstraints: [NSLayoutConstraint] = []
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|",
                                                                    metrics: nil,
                                                                    views: views as [String : Any])
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[stackview(==label@750,<=414)]",
                                                                    metrics: nil,
                                                                    views: views as [String : Any])
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[label(>=\(labelFontSize))]-15-[stackview(\(stackViewHeight))]-33@750-|",
             options: [.alignAllCenterX],
                                                                 metrics: nil,
                                                                 views: views as [String : Any])
        //view.backgroundColor = UIColor.blue
        view.addConstraints(allConstraints)
        
        return view
    }
    
    private  func createButton(dictionary: Dictionary<String, Any>, groupID: String)->(UXFButton){
        let button = UXFButton.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 33))
        button.titleLabel?.text = dictionary["value"] as? String
        return button
    }
    
    private  func createUICheckbox(dictionary: Dictionary<String, Any>, groupID: String)->(UIView){
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 33))
        let switchView = UISwitch.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: view.bounds.size.height))
        view.addSubview(switchView)
        #warning("title not implemented")
        return view
    }
    
    private  func createUIHeader(dictionary: Dictionary<String, Any>, groupID: String)->(UILabel){
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 33))
        label.text = dictionary["value"] as? String
        label.sizeToFit()
        return label
    }
    
    private  func createUIText(dictionary: Dictionary<String, Any>, groupID: String)->(UILabel){
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 33))
        label.text = dictionary["value"] as? String
        label.sizeToFit()
        return label
    }
    
    //MARK: - Smiles
    
    private func createSmileButtons(info:  Dictionary<String, Any>,
                              layoutView: UIStackView,
                              groupId: String,
                              submitHandler: ((Dictionary<String,Any>)->())?){
        let smilesKeys = info.keys.sorted()
        
        for smileKey in smilesKeys{
            let smileIndex = Int(smileKey)!
            
            let button = UXFSmileButton.init(index: smileIndex,
                                             isRequired: info["isRequered"] as? Bool,
                                             warning: info["warning"] as? String,
                                             hint: info["hint"] as? String)
            button.imageView?.contentMode = .scaleAspectFit
            if #available(iOS 11.0, *) {
                button.adjustsImageSizeForAccessibilityContentSizeCategory = true
            }
            let imageName =  UXFParser.sharedInstance.smileImageName(by: smileIndex)
            let previewButtonImage =  UXFParser.sharedInstance.getSmile(imageName: imageName, completion: { (image) in
                button.setImage(image, for: UIControl.State.normal)
            })
            button.setImage(previewButtonImage, for: UIControl.State.normal)
            
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
                submitHandler?([groupId : button.index])
            }
        }
    }

    
     func getSmile(imageName: String, completion: (_ smileImage: UIImage)->()) ->(UIImage?){
        return UIImage.init(named: imageName)
    }
    
     func smileImageName(by index: Int) -> (String){
        let names = ["angry", "mad", "confused", "happy", "in-love"]
        if index < names.count {
            return names[index]
        }
        else{
            return ""
        }
    }
}
