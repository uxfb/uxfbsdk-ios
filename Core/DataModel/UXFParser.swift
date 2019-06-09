//
//  UXFUIFabric.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 19.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import Nuke

class UXFParser{
    
    static let contenViewOffset: CGFloat = 15.0
    static let contentSubviewOffset: CGFloat = 8.0
    static let formControllerViewOffset: CGFloat = 16.0
    static let bottomOffset: CGFloat = 8
    
    private(set) var customTheme: UXFTheme?
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
    
    init(theme: UXFTheme?) {
        self.customTheme = theme
    }
    
    func parseTheme(jsonDict: Dictionary<String,Any>) -> UXFTheme? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted) {
           let theme = try! JSONDecoder().decode(UXFTheme.self, from: jsonData)
            return theme
        }
        return nil
       // if let controlColorString = jsonDict["controlColor"]
    }
    
     func parseCampaing(campaignInfo: Dictionary<String,Any>) -> (UXFCampaign?){
        
        let type = campaignInfo["type"] as! String
        let targetingArr = campaignInfo["targeting"] as! Array<Dictionary<String, Any>>
        let campaingId = campaignInfo["campaignId"] as! String
        let progressDict = campaignInfo["progress"] as! Dictionary<String, Any>
        let progress = progressDict["enabled"] as! Bool
        let projectId = campaignInfo["projectId"] as! String
        let autocolse: Double = campaignInfo["autocolse"] as? Double ?? 0.0
        var theme: UXFTheme = self.customTheme ?? UXFTheme.init()
        
        if let design = campaignInfo["design"] as? Dictionary<String, Any>,
           let themeType = UXFThemeType.init(rawValue: (design["theme"] as? Int) ?? 0),
               themeType != .custom{
            if let campaignTheme = parseTheme(jsonDict: design) {
               theme = campaignTheme
            }
        }
        
        var pages = Array<UXFPage>()
        if let pagesArrayOfDict = campaignInfo["pages"] as? Array<Dictionary<String, Any>> {
            
            for pageDict in pagesArrayOfDict{
                DDLogDebug("page: \(pageDict)")
                let pageId: String? = pageDict["_id"] as? String
                let page = UXFPage.init(id: pageId, uiData: pageDict)
                pages.append(page)
            }
        }
        
        return UXFCampaign.init( campaignId: campaingId,
                                theme: theme,
                                pages: pages,
                                type: UXFCampaignType.init(rawValue: type),
                                targetings: targetingArr,
                                isProgressEnabled: progress,
                                projectId:  projectId,
                                autoclose: autocolse)
    }
    
    //MARK: support
    
    private func setLabelText(label: UILabel,
                              text: String?,
                              textAlignment: NSTextAlignment = NSTextAlignment.center,
                              fontName: String? = nil,
                              fontSize: CGFloat = 17.0,
                              textColor: UIColor? = nil,
                              width: CGFloat? = nil,
                              theme: UXFTheme) -> CGFloat{
        
        label.textAlignment = textAlignment
        label.numberOfLines = 0
        if text != nil {
            let attributedString = NSMutableAttributedString(string: text!)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = fontSize * 0.5
            paragraphStyle.alignment = textAlignment
            
            let font = UIFont.init(name: fontName ?? theme.fontMediumName, size: fontSize)
            
            attributedString.addAttributes([NSAttributedString.Key.font : font as Any,
                                            NSAttributedString.Key.foregroundColor: textColor ?? theme.textColor],
                                           range: NSMakeRange(0, attributedString.length))
            
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                          value:paragraphStyle,
                                          range:NSMakeRange(0, attributedString.length))
            
            label.attributedText = attributedString
        }
        else{
            label.text = ""
        }
        
        var labelHeight = fontSize
        if let text = label.attributedText {
            labelHeight = text.height(withConstrainedWidth: width ?? self.containerWidth)
        }
        return labelHeight
    }
    
    internal  func parseUIElement(dictionary: Dictionary<String, Any>,
                                  theme: UXFTheme,
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
                groupView =  createButton(dictionary: dictionary, groupID: groupID, theme: theme)
                break
            case "header":
                groupView =  createUIHeader(dictionary: dictionary, groupID: groupID, theme: theme)
                break
            case "text":
                groupView =  createUIText(dictionary: dictionary, groupID: groupID, theme: theme)
                break
            case "checkboxes":
                groupView = createUICheckbox(dictionary: dictionary, groupID: groupID, theme: theme)
                break
            case "smiles":
                groupView = createSmiles(dictionary: dictionary, groupID: groupID, theme: theme,  submitHandler: submitHandler)
                break
            case "comment":
                groupView = createComment(dictionary: dictionary, groupID: groupID, theme: theme, submitHandler: submitHandler)
                break
            case "email":
                groupView = createEmailInput(dictionary: dictionary, groupID: groupID, theme: theme, submitHandler: submitHandler)
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
                                                            width: 50,
                                                            height: 50))
        imageView.contentMode = .scaleAspectFit
        let scale = UIScreen.main.scale
        if let setInfo = dictionary["set"] as? Dictionary<String, String>,
           let imagePath = setInfo["\(Int(scale))x"],
           let imageUrl = URL.init(string:  imagePath){
               Nuke.loadImage(with: imageUrl, into: imageView)
        }
        //imageView.backgroundColor = UIColor.gray
        return imageView
    }
    
    private func createEmailInput(dictionary: Dictionary<String, Any>,
                               groupID: String,
                               theme: UXFTheme,
                               submitHandler: ((Dictionary<String,Any>?)->())?) ->(UIView?){
        var height: CGFloat = 0.0
        let view = UIView.init(frame: CGRect.init(x: 0,
                                                  y: 0,
                                                  width: (UIScreen.main.bounds.width - (UXFParser.formControllerViewOffset + UXFParser.contenViewOffset)*2),
                                                  height: 44))
        let labelYOffset: CGFloat = 10.0
        height += labelYOffset
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 24))
        let text =  (dictionary["value"] as? String)  ?? "Введите Email и мы ответим Вам в ближайшее время"
        let labelFontSize: CGFloat = (IS_IPAD == true ? 20.0 : 16.0)
        let labelHeight = self.setLabelText(label: label,
                          text: text,
                          fontName: theme.fontMediumName,
                          fontSize: labelFontSize,
                             theme: theme)
        //label.backgroundColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        height += labelHeight
        view.addSubview(label)
        
        let textFieldHeight: CGFloat = 48.0
        let textFieldYOffset: CGFloat = 15.0
        let textField = UXFTextField.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 48))
        textField.font = UIFont.init(name: theme.fontRegularName, size: textField.font!.pointSize)
        textField.placeholder = "Email"
        textField.textColor = theme.inputTextColor
        textField.backgroundColor = theme.inputBackgroundColor
        height += textFieldHeight + textFieldYOffset
        textField.contentLeftPadding = 16.0
        //textField.borderStyle = .line
        //textField.setContentHuggingPriority(UILayoutPriority.init(rawValue: 251), for: .vertical)
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
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=0)-[skipButton]-(16)-[sendButton]-|",
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
                               theme: UXFTheme,
                               submitHandler: ((Dictionary<String,Any>?)->())?) ->(UIView?){
        
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
        
        var titleText: String = (dictionary["value"] as? String)  ?? "Вы чем-то расстроены?"
        
        if let selectedSmile = self._selectedSmileIndex,
            let messages: Dictionary<String,String> = dictionary["messages"] as? Dictionary<String, String>{
            
            isCommentRequired = (selectedSmile <= 2)
    
            if isCommentRequired {
           
                if let message = messages["negative"] {
                       titleText  =  message
                }

                alertCommentText  = messages["warning"] ?? "Комментарий обязательный"
            }
            else if let message = messages["positive"]{
                titleText  = message
            }
        }
    
        let labelFontSize: CGFloat = (IS_IPAD == true ? 20.0 : 16.0)
        let labelHeight = self.setLabelText(label: label,
                          text: titleText,
                          fontName: theme.fontMediumName,
                          fontSize: labelFontSize,
                          theme: theme)
        //label.backgroundColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        height += labelHeight
        view.addSubview(label)
        
        let textFieldHeight: CGFloat = 48.0
        let textFieldYOffset: CGFloat = 15.0
        let alertLabelYOffset: CGFloat = 11.0
        let alertLabelFontSize:CGFloat = 14.0
        var alertLabelHeight = alertLabelFontSize
        
        let sendButton = UIButton.init()
        
        let textField = UXFTextField.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 48))
        height += textFieldHeight + textFieldYOffset
        textField.contentLeftPadding = 16.0
        textField.font = UIFont.init(name: theme.fontRegularName, size: textField.font!.pointSize)
        textField.textColor = theme.inputTextColor
        textField.backgroundColor = theme.inputBackgroundColor
        //textField.borderStyle = .line
        //textField.setContentHuggingPriority(UILayoutPriority.init(rawValue: 251), for: .vertical)
        textField.didChange = { (inputTextField, text) in
                inputTextField.inputState = text?.count ?? 0 > 0 ? .input : .normal
                if isCommentRequired == true {
                   // sendButton.isEnabled = (text?.count ?? 0 > 0)
                    sendButton.alpha = (text?.count ?? 0 > 0 ? 1.0 : 0.5)
                }
        }
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        var alertLabel: UILabel?
        if let alertText = alertCommentText {
            alertLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: alertLabelHeight))
            alertLabelHeight = self.setLabelText(label: alertLabel!,
                              text: alertText,
                              textAlignment: .left,
                              fontName: theme.fontRegularName,
                              fontSize: alertLabelFontSize,
                              theme: theme)
            alertLabel!.translatesAutoresizingMaskIntoConstraints = false
            height += alertLabelYOffset + alertLabelHeight
            view.addSubview(alertLabel!)
        }
        
        if isCommentRequired == true {
            textField.placeholder = "Обязательное поле".localized()
            alertLabel!.alpha = 0
            alertLabel!.textColor = theme.errorColor
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
            if let commentText = textField.text, commentText.count > 0{
                submitHandler?([groupID : commentText])
            }
            else if isCommentRequired == true{
                alertLabel?.alpha = 1.0
                textField.inputState = .alert
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
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=33)-[sendButton]-(>=33)-|",
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
                                  theme: UXFTheme,
                            submitHandler: ((Dictionary<String,Any>?)->())?) ->(UIView){
        
        var height: CGFloat = 0.0
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.containerWidth, height: 44))
        
        let labelYOffset: CGFloat = 0.0
        height += labelYOffset
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 24))
        let labelFontSize: CGFloat = (IS_IPAD == true ? 20.0 : 16.0)
        let labelHeight =  self.setLabelText(label: label, text: dictionary["value"] as? String, fontSize: labelFontSize, theme: theme)
       // label.backgroundColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
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
        
        self.createSmileButtons(layoutView: stackView,
                                groupId: groupID,
                                theme: theme,
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
    
    private  func createButton(dictionary: Dictionary<String, Any>, groupID: String, theme: UXFTheme)->(UXFButton){
        let button = UXFButton.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 33))
        
        if button.titleLabel != nil {
           button.titleLabel?.text = dictionary["value"] as? String
           button.titleLabel?.font = UIFont.init(name: theme.fontMediumName, size: button.titleLabel!.font.pointSize)
        }
        return button
    }
    
    private  func createUICheckbox(dictionary: Dictionary<String, Any>, groupID: String, theme: UXFTheme)->(UIView){
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 33))
        let switchView = UISwitch.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: view.bounds.size.height))
        view.addSubview(switchView)
        #warning("title not implemented")
        return view
    }
    
    private  func createUIHeader(dictionary: Dictionary<String, Any>, groupID: String, theme: UXFTheme)->(UILabel){
        
        let labelYOffset: CGFloat = 10.0
        var height: CGFloat = labelYOffset
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.containerWidth - UXFParser.contentSubviewOffset*2, height: 24))
        
        let labelFontSize: CGFloat = (IS_IPAD == true ? 20.0 : 16.0)
        let labelHeight = self.setLabelText(label: label, text: dictionary["value"] as? String,
                          fontName: theme.fontBoldName,
                          fontSize: labelFontSize,
                          textColor: theme.titleColor,
                          theme: theme)
        //label.backgroundColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        height += labelHeight
        
        return label
    }
    
    private  func createUIText(dictionary: Dictionary<String, Any>, groupID: String, theme: UXFTheme)->(UIView){
        
        let view = UIView.init()
        view.backgroundColor = UIColor.clear
        
        let labelYOffset: CGFloat = 4.0
        var height: CGFloat = labelYOffset
        let label = UILabel.init()
        let labelFontSize: CGFloat = (IS_IPAD == true ? 20.0 : 16.0)
        let labelHeight = self.setLabelText(label: label,
                          text: dictionary["value"] as? String,
                          fontName: theme.fontMediumName,
                          fontSize: labelFontSize,
                          theme: theme)
        //label.backgroundColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        height += labelHeight
        view.addSubview(label)
        
        let views = ["label": label]
        var allConstraints: [NSLayoutConstraint] = []
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|",
                                                         metrics: nil,
                                                         views: views as [String : Any])
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(labelYOffset)-[label(>=\(labelHeight))]-\(labelYOffset)-|",
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
    
    //MARK: - Smiles
    
    private func createSmileButtons(layoutView: UIStackView,
                                    groupId: String,
                                    theme: UXFTheme,
                              submitHandler: ((Dictionary<String,Any>)->())?){
        
        let smilesCount = 5
        for smileIndex in 0..<smilesCount {

            let button = UXFSmileButton.init(index: smileIndex)
            button.imageView?.contentMode = .scaleAspectFit
            if #available(iOS 11.0, *) {
                button.adjustsImageSizeForAccessibilityContentSizeCategory = true
            }
        
            let imageName =  theme.smileImageName(by: smileIndex)
            let previewButtonImage =  theme.getSmile(imageName: imageName, completion: { (image) in
                button.setImage(image, for: UIControl.State.normal)
            })
            button.setImage(previewButtonImage, for: UIControl.State.normal)
            
            var buttonWidth = layoutView.bounds.size.width/CGFloat(smilesCount)
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
                self?._selectedSmileIndex = button.index
                submitHandler?([groupId : button.index])
            }
        }
    } 
     
}
