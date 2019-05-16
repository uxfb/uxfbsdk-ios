//
//  UXFUIFabric.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 19.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import HEXColor
import Nuke

class UXFParser{
    
    static let contenViewOffset: CGFloat = 15.0
    static let contentSubviewOffset: CGFloat = 8.0
    static let formControllerViewOffset: CGFloat = 16.0
    static let bottomOffset: CGFloat = 8
    
    private(set) var theme: UXFTheme!
    private var _uiGroupDictionary: Dictionary <String, Array<String>> = [:]
    private var containerWidth: CGFloat {
        return (UIScreen.main.bounds.width - (UXFParser.formControllerViewOffset + UXFParser.contenViewOffset)*2)
    }
    
    private var _selectedSmileIndex: Int? {
        get {
            if UserDefaults.standard.object(forKey: "selectedSmileIndex") != nil {
               return UserDefaults.standard.integer(forKey: "selectedSmileIndex")
            }
            return nil
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "selectedSmileIndex")
        }
    }
    private var _selectedSmileInfo: Dictionary <String, Any>?{
        get {
            return UserDefaults.standard.object(forKey: "selectedSmileInfo") as? Dictionary<String,Any>
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "selectedSmileInfo")
            UserDefaults.standard.synchronize()
        }
    }
    
    init(theme: UXFTheme) {
        self.theme = theme
    }
    
     func parseCampaing(compaignInfo: Dictionary<String,Any>) -> (UXFCampaign?){
        
        let type = compaignInfo["type"] as! String
        let targetingArr = compaignInfo["targeting"] as! Array<Dictionary<String, Any>>
        let campaingId = compaignInfo["campaignId"] as! String
        let progressDict = compaignInfo["progress"] as! Dictionary<String, Any>
        let progress = progressDict["enabled"] as! Bool
        let projectId = compaignInfo["projectId"] as! String
        
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
                                isProgressEnabled: progress,
                                projectId:  projectId)
    }
    
    //MARK: support
    
    internal  func parseUIElement(dictionary: Dictionary<String, Any>,
                                  submitHandler: ((Dictionary<String,Any>?)->())?)->(UIView?){
        
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
            case "email":
                groupView = createEmailInput(dictionary: dictionary, groupID: groupID, submitHandler: submitHandler)
                break
            case "image":
                groupView = createImage(dictionary: dictionary, groupID: groupID)
                break
            default:
               groupView = nil
               break
            }
            
            groupView?.tag = groupIndex
        }
        
       return groupView
    }
    
    private func createImage(dictionary: Dictionary<String, Any>,
                                groupID: String)->(UIView?){
        let imageView = UIImageView.init(frame: CGRect.init(x: 0,
                                                            y: 0,
                                                            width: 56,
                                                            height: 56))
        imageView.contentMode = .scaleAspectFit
        let scale = UIScreen.main.scale
        if let setInfo = dictionary["set"] as? Dictionary<String, String>,
           let imagePath = setInfo["\(Int(scale))x"],
           let imageUrl = URL.init(string:  imagePath){
               Nuke.loadImage(with: imageUrl, into: imageView)
        }
        return imageView
    }
    
    private func createEmailInput(dictionary: Dictionary<String, Any>,
                               groupID: String,
                               submitHandler: ((Dictionary<String,Any>?)->())?) ->(UIView?){
        var height: CGFloat = 0.0
        let view = UIView.init(frame: CGRect.init(x: 0,
                                                  y: 0,
                                                  width: (UIScreen.main.bounds.width - (UXFParser.formControllerViewOffset + UXFParser.contenViewOffset)*2),
                                                  height: 44))
        let labelYOffset: CGFloat = 10.0
        height += labelYOffset
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 24))
        label.text = (dictionary["value"] as? String)  ?? "Введите Email и мы ответим Вам в ближайшее время"
        let labelFontSize: CGFloat = (IS_IPAD == true ? 20.0 : 16.0)
        label.font =  label.font.withSize(labelFontSize)
        label.numberOfLines = 0
        label.textColor = self.theme.textColor
        label.textAlignment = .center
        label.sizeToFit()
        //label.backgroundColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        var labelHeight = labelFontSize
        if let text = label.text {
            labelHeight = text.height(withConstrainedWidth: (view.frame.size.width - UXFParser.contentSubviewOffset*2), font: label.font)
        }
        height += labelHeight
        view.addSubview(label)
        
        let textFieldHeight: CGFloat = 48.0
        let textFieldYOffset: CGFloat = 15.0
        let textField = UXFTextField.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 48))
        height += textFieldHeight + textFieldYOffset
        textField.contentLeftPadding = 16.0
        //textField.borderStyle = .line
        //textField.setContentHuggingPriority(UILayoutPriority.init(rawValue: 251), for: .vertical)
        textField.backgroundColor = UIColor.init("#F6F6F7")
        textField.didChange = { (inputTextField, text) in
            inputTextField.inputState = text?.count ?? 0 > 0 ? .input : .normal
        }
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        let sendButton = UIButton.init()
        sendButton.setTitle("Отправить".localized(), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitleColor(sendButton.tintColor, for: .normal)
        let sendButtonYOffet: CGFloat = 25.0
        let sendButtonHeight: CGFloat = 44.0
        //sendButton.backgroundColor = UIColor.gray
        sendButton.addAction {
            if let commentText = textField.text{
                submitHandler?([groupID : commentText])
            }
            else{
                submitHandler?(nil)
            }
        }
        height += sendButtonYOffet + sendButtonHeight
        view.addSubview(sendButton)
        
        let skipButton = UIButton.init()
        skipButton.setTitle("Пропустить".localized(), for: .normal)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.setTitleColor(skipButton.tintColor, for: .normal)
        skipButton.addAction {
            submitHandler?(nil)
        }
        view.addSubview(skipButton)
        
        let views: Dictionary <String, Any> = ["label": label, "sendButton" : sendButton, "skipButton" : skipButton, "textField" : textField]

        var allConstraints: [NSLayoutConstraint] = []
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(UXFParser.contentSubviewOffset)-[label]-\(UXFParser.contentSubviewOffset)-|",
            metrics: nil,
            views: views as [String : Any])
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=0)-[skipButton]-[sendButton]-|",
                                                         metrics: nil,
                                                         views: views as [String : Any])
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(UXFParser.contentSubviewOffset)-[textField]-\(UXFParser.contentSubviewOffset)-|",
            metrics: nil,
            views: views as [String : Any])
        
        
        height += UXFParser.bottomOffset
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[skipButton(\(sendButtonHeight))]-\(UXFParser.bottomOffset)-|",
            metrics: nil,
            views: views as [String : Any])
        
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(labelYOffset)-[label(>=\(labelHeight))]-\(textFieldYOffset)-[textField(\(textFieldHeight))]-\(sendButtonYOffet)-[sendButton(\(sendButtonHeight))]-\(UXFParser.bottomOffset)-|",
            metrics: nil,
            views: views as [String : Any])
        
        view.addConstraints(allConstraints)
        //view.backgroundColor = UIColor.blue
        view.frame = CGRect.init(x: 0,
                                 y: 0,
                                 width: view.frame.size.width,
                                 height: height)
        
        return view
    }
    
    private func createComment(dictionary: Dictionary<String, Any>,
                               groupID: String,
                               submitHandler: ((Dictionary<String,Any>?)->())?) ->(UIView?){
        
        guard let  commentsInfo = dictionary["customComments"] as? Dictionary<String, Any> else {
            return nil
        }
        
        var height: CGFloat = 0.0
        let view = UIView.init(frame: CGRect.init(x: 0,
                                                  y: 0,
                                                  width: (UIScreen.main.bounds.width - (UXFParser.formControllerViewOffset + UXFParser.contenViewOffset)*2),
                                                  height: 44))
        
        let labelYOffset: CGFloat = 10.0
        height += labelYOffset
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 24))
        
        var alertCommentText: String?
        var isCommentRequired = false
        
        var titleText: String = (dictionary["value"] as? String)  ?? "Вы чем-то расстроены? Пожалуйста, поделитесь этим с нами"
        
        if let selectedSmile = self._selectedSmileIndex,
            let smileInfo = self._selectedSmileInfo{
            
            isCommentRequired = smileInfo["isRequired"] as! Bool
            if isCommentRequired {
                alertCommentText = smileInfo["warning"] as? String
            }
            
            if let enabledComments = commentsInfo["enabled"] as? Bool,
                enabledComments == true,
                let customCommentInfo = commentsInfo["comments"] as? Dictionary<String, String>,
                let custimCommentText = customCommentInfo["\(selectedSmile)"]{
                titleText = custimCommentText
            }
        }
    
       // label.textColor = 
        label.text = titleText
        let labelFontSize: CGFloat = (IS_IPAD == true ? 20.0 : 16.0)
        label.font =  label.font.withSize(labelFontSize)
        label.numberOfLines = 0
        label.textColor = self.theme.textColor
        label.textAlignment = .center
        label.sizeToFit()
        //label.backgroundColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        var labelHeight = labelFontSize
        if let text = label.text {
            labelHeight = text.height(withConstrainedWidth: self.containerWidth, font: label.font)
        }
        height += labelHeight
        view.addSubview(label)
        
        let textFieldHeight: CGFloat = 48.0
        let textFieldYOffset: CGFloat = 15.0
        let alertLabelYOffset: CGFloat = 11.0
        let alertLabelFontSize:CGFloat = 14.0
        var alertLabelHeight = alertLabelFontSize
        
        let sendButton = UIButton.init()
        sendButton.isEnabled = !isCommentRequired
        sendButton.alpha = sendButton.isEnabled == true ? 1.0 : 0.3
        
        let textField = UXFTextField.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 48))
        height += textFieldHeight + textFieldYOffset
        textField.contentLeftPadding = 16.0
        //textField.borderStyle = .line
        //textField.setContentHuggingPriority(UILayoutPriority.init(rawValue: 251), for: .vertical)
        textField.backgroundColor = UIColor.init("#F6F6F7")
        textField.didChange = { (inputTextField, text) in
                inputTextField.inputState = text?.count ?? 0 > 0 ? .input : .normal
                if isCommentRequired == true {
                    sendButton.isEnabled = (text?.count ?? 0 > 0)
                    sendButton.alpha = sendButton.isEnabled == true ? 1.0 : 0.5
                }
        }
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        var alertLabel: UILabel?
        if isCommentRequired == true {
            textField.placeholder = "Обязательное поле".localized()
            alertLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: alertLabelHeight))
            alertLabel!.textAlignment = .left
            alertLabel!.font =  alertLabel!.font.withSize(alertLabelFontSize)
            alertLabel!.textColor = self.theme.errorColor
            alertLabel?.numberOfLines = 0
            let alertText = alertCommentText ?? "Заполните обязательное поле".localized()
            alertLabel!.text = alertText
            alertLabelHeight = alertText.height(withConstrainedWidth: (view.frame.size.width - UXFParser.contentSubviewOffset*2), font: alertLabel!.font)
            alertLabel!.translatesAutoresizingMaskIntoConstraints = false
            height += alertLabelYOffset + alertLabelHeight
            view.addSubview(alertLabel!)
        }
        else{
            textField.placeholder = "Необязательное поле".localized()
        }
        
        
        sendButton.setTitle("Отправить".localized(), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitleColor(sendButton.tintColor, for: .normal)
        let sendButtonYOffet: CGFloat = 25.0
        let sendButtonHeight: CGFloat = 44.0
        //sendButton.backgroundColor = UIColor.gray
        sendButton.addAction {
            if let commentText = textField.text{
                submitHandler?([groupID : commentText])
            }
            else{
                submitHandler?(nil)
            }
        }
        height += sendButtonYOffet + sendButtonHeight
        
        view.addSubview(sendButton)
        
        var views: Dictionary <String, Any> = ["label": label, "sendButton" : sendButton, "textField" : textField]
        if alertLabel != nil {
            views["alertLabel"] = alertLabel!
        }
        
        var allConstraints: [NSLayoutConstraint] = []
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(UXFParser.contentSubviewOffset)-[label]-\(UXFParser.contentSubviewOffset)-|",
                                                         metrics: nil,
                                                         views: views as [String : Any])
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-33-[sendButton]-33-|",
            metrics: nil,
            views: views as [String : Any])
        
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(UXFParser.contentSubviewOffset)-[textField]-\(UXFParser.contentSubviewOffset)-|",
                metrics: nil,
                views: views as [String : Any])
        
        
        var alertLabelConstraintsText = ""
        if views["alertLabel"] != nil {
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(UXFParser.contentSubviewOffset)-[alertLabel]-\(UXFParser.contentSubviewOffset)-|",
                metrics: nil,
                views: views as [String : Any])
            alertLabelConstraintsText = "\(alertLabelYOffset)-[alertLabel(\(alertLabelHeight))]-"
        }

        height += UXFParser.bottomOffset
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(labelYOffset)-[label(>=\(labelHeight))]-\(textFieldYOffset)-[textField(\(textFieldHeight))]-\(alertLabelConstraintsText)\(sendButtonYOffet)-[sendButton(\(sendButtonHeight))]-\(UXFParser.bottomOffset)-|",
            options: [.alignAllCenterX],
            metrics: nil,
            views: views as [String : Any])
        
        view.addConstraints(allConstraints)
        //view.backgroundColor = UIColor.blue
        view.frame = CGRect.init(x: 0,
                                 y: 0,
                                 width: view.frame.size.width,
                                 height: height)
        return view
    }
    
    private  func createSmiles(dictionary: Dictionary<String, Any>,
                                  groupID: String,
                            submitHandler: ((Dictionary<String,Any>?)->())?) ->(UIView){
        
        var height: CGFloat = 0.0
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.containerWidth, height: 44))
        
        let labelYOffset: CGFloat = 0.0
        height += labelYOffset
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 24))
        label.text = dictionary["value"] as? String
        let labelFontSize: CGFloat = (IS_IPAD == true ? 20.0 : 16.0)
        label.font =  label.font.withSize(labelFontSize)
        label.textAlignment = .center
        label.textColor = theme.textColor
        label.sizeToFit()
       // label.backgroundColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        var labelHeight = labelFontSize
         if let text = label.text {
         labelHeight = text.height(withConstrainedWidth: (view.frame.size.width - UXFParser.contentSubviewOffset*2), font: label.font)
         }
        height += labelHeight
 
        let stackViewYOffset: CGFloat = 24.0
        let stackViewBottom: CGFloat = 43.0
        height += stackViewYOffset + stackViewBottom
        let stackViewHeight: CGFloat = IS_IPAD == true ? 48.0 : 40.0
        height += stackViewHeight
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
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(labelYOffset)-[label(>=\(labelHeight))]-\(stackViewYOffset)-[stackview(\(stackViewHeight))]-\(stackViewBottom)-|",
             options: [.alignAllCenterX],
                                                                 metrics: nil,
                                                                 views: views as [String : Any])
        //view.backgroundColor = UIColor.blue
        view.addConstraints(allConstraints)
        view.frame = CGRect.init(x: 0,
                                 y: 0,
                             width: view.frame.size.width,
                            height: height)
        
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
        
        let labelYOffset: CGFloat = 10.0
        var height: CGFloat = labelYOffset
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.containerWidth - UXFParser.contentSubviewOffset*2, height: 24))
        label.text = dictionary["value"] as? String
        let labelFontSize: CGFloat = (IS_IPAD == true ? 20.0 : 16.0)
        label.font =  label.font.withSize(labelFontSize)
        label.textAlignment = .center
        label.textColor = self.theme.titleColor
        label.numberOfLines = 0
        label.sizeToFit()
        //label.backgroundColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        var labelHeight = labelFontSize
        if let text = label.text {
            labelHeight = text.height(withConstrainedWidth: label.frame.size.width, font: label.font)
        }
        height += labelHeight
        
        return label
    }
    
    private  func createUIText(dictionary: Dictionary<String, Any>, groupID: String)->(UILabel){
        let labelYOffset: CGFloat = 10.0
        var height: CGFloat = labelYOffset
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.containerWidth - UXFParser.contentSubviewOffset*2, height: 24))
        label.text = dictionary["value"] as? String
        let labelFontSize: CGFloat = (IS_IPAD == true ? 20.0 : 16.0)
        label.font =  label.font.withSize(labelFontSize)
        label.textColor = self.theme.textColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        //label.backgroundColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        var labelHeight = labelFontSize
        if let text = label.text {
            labelHeight = text.height(withConstrainedWidth: label.frame.size.width, font: label.font)
        }
        height += labelHeight
        
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
            let smileInfo = info[smileKey] as! Dictionary <String, Any>
            let smileHint = smileInfo["hint"] as? String
            
            let button = UXFSmileButton.init(index: smileIndex,
                                             isRequired: info["isRequered"] as? Bool,
                                             warning: info["warning"] as? String,
                                             hint: smileHint)
            button.imageView?.contentMode = .scaleAspectFit
            if #available(iOS 11.0, *) {
                button.adjustsImageSizeForAccessibilityContentSizeCategory = true
            }
        
            let imageName =  self.theme.smileImageName(by: smileIndex)
            let previewButtonImage =  self.theme.getSmile(imageName: imageName, completion: { (image) in
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
            button.addAction(for: .touchUpInside) { [weak self] in
                self?._selectedSmileInfo = info[smileKey] as? Dictionary<String, Any>
                self?._selectedSmileIndex = button.index
                submitHandler?([groupId : button.index])
            }
        }
    } 
     
}
