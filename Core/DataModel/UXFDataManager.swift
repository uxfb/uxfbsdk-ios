//
//  UXFDataPreparer.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

//// needs to refactoring to MANAGERS

import UIKit

enum UXFFieldType: String {
    case text = "text"
    case button = "button"
    case checkbox = "checkboxes"
    case email = "email"
    case header = "header"
    case image = "image"
    case input = "comment"
    case radiobutton = "radiobuttons"
    case smiles = "smiles"
    case stars = "stars"
    case bottom = "bottom"
    case nps = "nps"
    case screenshot = "screenshot"
}

protocol UXFFieldDelegate {
    func fieldChanged(_ field: UXFField, answer: [String], refresh: Bool)
    func buttonTapped(_ field: UXFField, answer: [String], refresh: Bool)
    func textChanged(_ field: UXFField, answer: [String], refresh: Bool)
    func screenshotChanged(screenshots: [UXFScreenshot])
}

class UXFDataManager: UXFFieldDelegate {
    
    private var viewController: UXFCampaignViewController?
    
    private var currentPage: Int = 0
    private var campaign: UXFCampaign?
    var extraSpace: CGFloat {
        get {
            return campaign?.type == .popup ? 80 : 32
        }
    }
    
    internal var isFullScreen = false
    
    internal var titleViewHeight: CGFloat {
        get {
            var safeArea: CGFloat = 0
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                safeArea = window?.safeAreaInsets.bottom ?? 0
            }
            if isFullScreen && campaign?.type == .slidein {
                return 54 + safeArea
            }
            else {
                return 54
            }
        }
    }
    
    internal var bottomSpace: CGFloat {
        get {
            var safeArea: CGFloat = 0
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                safeArea = window?.safeAreaInsets.bottom ?? 0
            }
            return campaign?.type == .slidein ? safeArea : 0
        }
    }
    
    init(_ target: UXFCampaignViewController, campaign: UXFCampaign?) {
        self.campaign = campaign
        self.viewController = target
    }
    
    private var answers = Array<Dictionary<String, Any>>()
    private var _screenshots: [UXFScreenshot] = []
    public var screenshots: [UXFScreenshot] {
        get {
            return _screenshots
        }
    }
    
    var isError: Bool = false
    
    //MARK: - Prepared Data
    
    internal func heightForCurrentPage() -> CGFloat {
        
        let page = campaign?.pages[currentPage]
        var height: CGFloat = 98
        for field in (page?.fields)! {
            height += checkFieldTransfromed(field) ? (getFieldHeight(field) + getFieldHeaderHeight(field) + getFieldFooterHeight(field)) : 2
        }
        for button in (page?.buttons)! {
            height += getFieldHeight(button) + getFieldHeaderHeight(button) + getFieldFooterHeight(button)
        }
        height += 12
        var areas = .bottomArea + .topArea //+ extraSpace
        switch campaign?.type {
        case .slidein:
            areas -= .bottomArea
            height += .bottomArea
            height = min(UIScreen.main.bounds.height, height)
            break
        case .popup:
            areas += extraSpace / 2
            height = min(UIScreen.main.bounds.height - 48, height)
            break
        default:
            break
        }
        
        let maxHeight = UIScreen.main.bounds.size.height - areas
        
        return min(height, maxHeight)
    }
    
    //MARK: - Data for table view
    
    internal func sectionsWithotButton() -> IndexSet {
        var set: IndexSet = []

        for i in 0..<fieldsCount() {
            set.insert(i)   
        }
        
        return set
    }
    
    internal func fieldsCount() -> Int {
        let cnt = (campaign?.pages[currentPage].fields.count ?? 0) + (campaign?.pages[currentPage].buttons.count ?? 0)
        return cnt
    }
    
    internal func heightForFieldHeader(index: Int) -> CGFloat {
        let field = ((campaign?.pages[currentPage].fields ?? []) + (campaign?.pages[currentPage].buttons ?? []))[index]
        
        return checkFieldTransfromed(field) ? getFieldHeaderHeight(field) : CGFloat.leastNonzeroMagnitude
    }
    
    internal func heightForFieldFooter(index: Int) -> CGFloat {
        let field = ((campaign?.pages[currentPage].fields ?? []) + (campaign?.pages[currentPage].buttons ?? []))[index]
        return checkFieldTransfromed(field) ? getFieldFooterHeight(field) : CGFloat.leastNonzeroMagnitude
    }
    
    internal func numberForFieldCell(index: Int) -> Int {
        let field = ((campaign?.pages[currentPage].fields ?? []) + (campaign?.pages[currentPage].buttons ?? []))[index]
        return checkFieldTransfromed(field) ? 1 : 0
    }
    
    internal func viewForFieldHeader(index: Int) -> UIView {
        let field = ((campaign?.pages[currentPage].fields ?? []) + (campaign?.pages[currentPage].buttons ?? []))[index]
        return checkFieldTransfromed(field) ? getFieldHeader(field) : UIView()
    }
    
    internal func viewForFieldFooter(index: Int) -> UIView {
        let field = ((campaign?.pages[currentPage].fields ?? []) + (campaign?.pages[currentPage].buttons ?? []))[index]
        return checkFieldTransfromed(field) ? getFieldFooter(field) : UIView()
    }
    
    internal func heightForFieldCell(indexPath: IndexPath) -> CGFloat {
        let page = campaign?.pages[currentPage]
        let fields = (page?.fields ?? []) + (page?.buttons ?? [])
        let field = fields[indexPath.section]
        
        return getFieldHeight(field)
    }
    
    internal func fieldForRow(indexPath: IndexPath) -> UXFField {
        let page = campaign?.pages[currentPage]
        let fields = (page?.fields ?? []) + (page?.buttons ?? [])
        var field = fields[indexPath.section]
        
        let answer = answers.first { answer in ((answer["fieldId"] as? String) ?? "") == field.id }
        field.answers = (answer?["value"] as? [String]) ?? []
        field.isError = isError
        return field
    }
    
    var progress: String {
        get {
            return "\(currentPage + 1)/\(campaign?.pages.count ?? 0)"
        }
    }
    
    //MARK: - Support Fields
    
    private func getSpacing(fromField: UXFField, toField: UXFField?) -> CGFloat {
        if toField?.type == .bottom {
            return 16
        }
        
        if fromField.type == .image {
            if toField?.type == .header || toField?.type == .text {
                return 8
            }
            else if toField?.type == .button {
                return 24
            }
            else {
                return 16
            }
        }
        
        if (fromField.type == .header || fromField.type == .text) && toField?.type == .text {
            return 16
        }
        
        if (toField?.type == .button && fromField.type != .header && fromField.type != .text && fromField.type != .image) {
            return 32
        }
        
        return 24
    }
    
    private func getFooterSpacing(_ field: UXFField) -> CGFloat {
        var spacing: CGFloat = CGFloat.leastNonzeroMagnitude
        
        guard let fieldIndex = campaign?.pages[currentPage].fields.firstIndex(where: { (fld) -> Bool in
            fld.id == field.id
        }) else {
            return spacing
        }
        
        
        let allFields = (campaign?.pages[currentPage].fields ?? []) + (campaign?.pages[currentPage].buttons)!
        
        
        for i in fieldIndex..<allFields.count {
            let nextIndex = i + 1
            if ((allFields.indices.contains(nextIndex)) == true) {
                let nextField = allFields[nextIndex]
                if checkFieldTransfromed(nextField) {
                    spacing = getSpacing(fromField: field, toField: nextField)
                    break
                }
            }
            else {
                spacing = getSpacing(fromField: field, toField: nil)
                break
            }
        }
        
        
        return spacing
    }
    
    private func getTitleSpacing(_ field: UXFField) -> CGFloat {
        var spacing: CGFloat = 0
        
        switch field.type {
        case .image:
            spacing = 8
            break
        case .header, .text:
            spacing = 16
            break
        default:
            spacing = 16
            break
        }
        return spacing
    }
    
    private func getFieldHeaderHeight(_ field: UXFField) -> CGFloat {
        guard let value = field.value, value != "" else {
            return CGFloat.leastNonzeroMagnitude //12
        }
        
        switch field.type {
        case .header, .text, .image:
            return CGFloat.leastNonzeroMagnitude //8
        case .button:
            return CGFloat.leastNonzeroMagnitude //8
        default:
            break
        }

        
        let font = (campaign?.theme.mediumFont(size: .mediumFontSize))!
        let lines = value.linesCount(width: UIScreen.main.bounds.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace,
                                            font: font)//.mediumSemiboldFont)
        let valueHeight = CGFloat(lines) * font.lineHeight + getTitleSpacing(field)
        return valueHeight
    }
    
    private func getFieldFooterHeight(_ field: UXFField) -> CGFloat {
        var height: CGFloat = 0
        
        if isError && fieldNeedComplete(field) {
            guard let warning = field.uiData["warning"] as? String else {
                return checkFieldTransfromed(field) ? 12 : 0
            }
            let font = (campaign?.theme.regularFont(size: .smallFontSize))!
            let lines = warning.linesCount(width: UIScreen.main.bounds.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace,
                                           font: font)
            let valueHeight = CGFloat(lines) * font.lineHeight
            height += valueHeight + 8
        }
        else {
            height = 0
//            switch field.type {
//            case .button:
//                return CGFloat.leastNonzeroMagnitude
//            case .smiles:
//                return 24
//            default:
//                return 16
//            }
        }
        
        return height + getFooterSpacing(field)
    }
    
    private func getFieldHeader(_ field: UXFField) -> UIView {
        if [UXFFieldType.header, UXFFieldType.text, UXFFieldType.button, UXFFieldType.image].contains(field.type) || field.value == nil || !checkFieldTransfromed(field) {
            return UIView()
        }
        
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width - .leftArea - .rightArea - extraSpace,
                                                                    height: getFieldHeaderHeight(field))))
        let label = UILabel(frame: CGRect(origin: .zero,
                                          size: CGSize(width: view.frame.width,
                                                       height: view.frame.height - getTitleSpacing(field))))// - 16)))
        
        label.textColor = campaign?.theme.text01Color
        
        let required = (field.uiData["required"] as? Bool) ?? false
        let text = "\(required ? "* " : "")\(field.value ?? "")"
        let range = (text as NSString).range(of: "*")
        let attributedString = NSMutableAttributedString(string:text)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: campaign?.theme.errorColorPrimary ?? UXFBTheme.init().errorColorPrimary, range: range)
        label.attributedText = attributedString
        
        
        label.font = campaign?.theme.mediumFont(size: .mediumFontSize)
//        label.font = .mediumSemiboldFont
        label.textAlignment = .center
        label.numberOfLines = 0
        view.addSubview(label)
        
        return view
    }
    
    private func getFieldFooter(_ field: UXFField) -> UIView {
        if isError && fieldNeedComplete(field) {
            guard let warning = field.uiData["warning"] as? String else {
                return UIView()
            }
            let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width - .leftArea - .rightArea - extraSpace,
                                                                        height: getFieldFooterHeight(field))))
            let font = (campaign?.theme.regularFont(size: .smallFontSize))!
            let lines = warning.linesCount(width: UIScreen.main.bounds.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace,
                                           font: font)
            let valueHeight = CGFloat(lines) * font.lineHeight
            let label = UILabel(frame: CGRect(origin: CGPoint(x: 0,
                                                              y: 8),
                                              size: CGSize(width: view.frame.size.width,
                                                           height: valueHeight)))
            
            label.text = warning
            label.textColor = campaign?.theme.errorColorPrimary
            label.font = font
            label.numberOfLines = 0
            view.addSubview(label)
            
            return view
        }
        else {
            return UIView()
        }
    }
    
    private func getFieldHeight(_ field: UXFField) -> CGFloat {
        if !checkFieldTransfromed(field) {
            return 0
        }
        switch field.type {
        case .button:
            return 40
        
        case .smiles:
            return 40
            
        case .checkbox:
            let width = UIScreen.main.bounds.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace - 48
            var height: CGFloat = 0
            let checkboxes = field.uiData["options"] as? Array<Dictionary<String, Any>> ?? []
            for checkbox in checkboxes {
                let value = checkbox["value"] as? String ?? ""
                let font = (campaign?.theme.regularFont(size: .mediumFontSize))!
//                let lines = CGFloat(value.linesCount(width: width, font: .mediumFont))
                let lines = CGFloat(value.linesCount(width: width, font: font))
                height += max(ceil(lines * font.lineHeight) + 24, 48)
            }
            return height
            
        case .email:
            return 40
            
        case .header:
            let font = (campaign?.theme.boldFont(size: .bigFontSize))!// .bigSemiboldFont)
            let lines = field.value!.linesCount(width: UIScreen.main.bounds.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace,
                                                font: font)
            let valueHeight = ceil(CGFloat(lines) * font.lineHeight)
            return valueHeight
            
        case .image:
            return 56
            
        case .input:
            var minHeight: CGFloat = 40
            guard let mode = field.uiData["mode"] as? String else {
                return 40
            }
            
            if mode == "multi" {
                minHeight = 84
            }
            
            
            let answerDict = answers.first { (answer) -> Bool in
                (answer["fieldId"] as? String) == field.id
            }
            let answer = (answerDict?["value"] as? [String] ?? []).first ?? ""
//            let answer = field.answers.first ?? ""
            let font = (campaign?.theme.regularFont(size: .mediumFontSize))!
            let lines = min(answer.linesCount(width: UIScreen.main.bounds.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace,
                                              font: font), 10) //.mediumFont
            let valueHeight = ceil(CGFloat(lines) * font.lineHeight)
            
            return max(valueHeight, minHeight)
            
        case .radiobutton:
            let width = UIScreen.main.bounds.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace - 48
            var height: CGFloat = 0
            let buttons = field.uiData["options"] as? Array<Dictionary<String, Any>> ?? []
            for button in buttons {
                let value = button["value"] as? String ?? ""
                let font = (campaign?.theme.regularFont(size: .mediumFontSize))!
                let lines = CGFloat(value.linesCount(width: width, font: font))
//                let lines = CGFloat(value.linesCount(width: width, font: .mediumFont))
                
                height += max(ceil(lines * font.lineHeight) + 24, 48)
            }
            return height
            
        case .text:
            let font = (campaign?.theme.regularFont(size: .mediumFontSize))!
            let lines = field.value!.linesCount(width: UIScreen.main.bounds.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace,
                                                font: font)//.mediumFont)
            let valueHeight = ceil(CGFloat(lines) * font.lineHeight)
            return valueHeight
            
        case .stars:
            return 40
        case .bottom:
            return 40
        case .nps:
            return 110
        case .screenshot:
            var buttonsHeight: CGFloat = 0
            
            switch campaign?.type {
            case .popup:
                buttonsHeight = 82
            case .slidein:
                buttonsHeight = 48
            case .none:
                return 0
            }
            return screenshots.count > 0 ? 140+buttonsHeight : buttonsHeight
        case .none:
            return 40
        }
    }
    
    //MARK: - UXFFieldDelegate
    
    func buttonTapped(_ field: UXFField, answer: [String], refresh: Bool) {
        viewController?.view.endEditing(true)
        isError = false
        if needsComplete() {
            isError = true
            viewController?.updateUI()
        }
        else {
            if campaign?.pages[currentPage].type == 2 {
                endCampaign()
            }
            else {
                nextPage()
            }
        }
    }
    
    func fieldChanged(_ field: UXFField, answer: [String], refresh: Bool = true) {
        isError = false
        answers = answers.filter { answer in ((answer["fieldId"] as? String) ?? "") != field.id }
        if answer.count > 0 {
            let transforms: [String] = []
            let newAnswer = ["pageId": campaign?.pages[currentPage].id ?? "",
                             "fieldId": field.id as Any,
                             "type": field.type?.rawValue as Any,
                             "value": answer,
                             "transforms": transforms] as [String : Any]
            answers.append(newAnswer)
        }

        if refresh {
            viewController?.updateUI()
        }
    }
    
    
    func textChanged(_ field: UXFField, answer: [String], refresh: Bool = true) {
        let fieldIndex = Int((campaign?.pages[currentPage].fields.firstIndex(where: { (fld) -> Bool in
            fld.id == field.id
        }))!)
        
        answers = answers.filter { answer in ((answer["fieldId"] as? String) ?? "") != field.id }
        if answer.count > 0 {
            let newAnswer = ["fieldId": field.id as Any,
                             "type": field.type?.rawValue as Any,
                             "value": answer,
                             "transforms": ""] as [String : Any]
            answers.append(newAnswer)
        }
        
        viewController?.updateField(idx: fieldIndex)
    }
    
    func screenshotChanged(screenshots: [UXFScreenshot]) {
        isError = false
        _screenshots = screenshots
        viewController?.updateUI()
    }
    
    //MARK: - Routing
    
    private func nextPage() {
        toPage(index: getNextIndex())
    }
    
    private func toPage(index: Int) {
        currentPage = index
        viewController?.scrollToTop(animated: false)
        viewController?.updateUI()
    }
    
    public func endCampaign() {
        var formattedAnswers = Array<Dictionary<String, Any>>()
        answers.forEach { (answer) in
            var item = answer
            switch (UXFFieldType(rawValue: item["type"] as! String)) {
            case .radiobutton, .email, .input:
                item["value"] = (answer["value"] as? [String])?.first
                break
            case .smiles, .nps:
                item["value"] = Int(((answer["value"] as? [String])?.first)!)
                break
            default:
                item["value"] = answer["value"]
            }
            formattedAnswers.append(item)
        }
        
        var results: [[String: Any]] = []
        
        for i in 0...currentPage {
            let page = campaign?.pages[i]
            let fields = formattedAnswers.filter { (answer) -> Bool in
                let pageId = answer["pageId"] as? String
                return page?.id == pageId ?? ""
            }
            
            var result: [String: Any] = [:]
            result["pageId"] = page?.id ?? ""
            if fields.count > 0 {
                result["fields"] = fields.map { $0.filter{ $0.key != "pageId" } }
            }
            
            let currentPageId = campaign?.pages[currentPage].id ?? ""
            
            result["close"] = page?.id == currentPageId ? 1 : 0
            
            results.append(result)
        }
        
        viewController!.completeHandler!(0, results, screenshots)
        viewController?.dismiss(animated: viewController?.presentationAnimated ?? true)
    }
    
    //MARK:- TRANSFORMATIONS!
    
    private func fieldNeedComplete(_ field: UXFField) -> Bool {
        let required = ((field.uiData["required"] as? Bool) ?? false) //|| (field.type == .smiles)
        let transformered = checkFieldTransfromed(field)
        let answered = answers.map({ (dict) -> String in
            (dict["fieldId"] as? String) ?? ""
        }).contains(field.id)
        
        if required && transformered && !answered {
            return true
        }
        return false
    }
    
    private func needsComplete() -> Bool {
        let page = campaign?.pages[currentPage]
        let fields = page!.fields
        for field in fields {
            if fieldNeedComplete(field) {
                return true
            }
        }
        
        return false
    }
    
    private func getNextIndex() -> Int {
        
        guard let transforms = campaign?.transforms.filter({ transform in
            transform.fromPage == campaign?.pages[currentPage].id && transform.action == "transition"
        }) else {
            return currentPage + 1
        }
        
        for transform in transforms {
            let toPageIndex = campaign?.pages.lastIndex(where: { (page) -> Bool in
                page.id == transform.toPage
            }) ?? (currentPage + 1)
            
            let answer = answers.first(where: { (dict) -> Bool in
                ((dict["fieldId"] as? String) ?? "") == transform.fromField
            })
            
            let answers = (answer?["value"] as? [String]) ?? []
            
            let type = UXFFieldType(rawValue: (answer?["type"] as? String) ?? "")
            
            switch transform.rule {
            case "equal":
                let same = transform.value?.filter() { answers.contains($0) }
                if same?.count ?? 0 > 0 {
                    return toPageIndex
                }
                break
            case "filled":
                if type == .checkbox {
                    if answers.count > 0 {
                        return toPageIndex
                    }
                }
                else {
                    if (answers.first ?? "").count > 0 {
                        return toPageIndex
                    }
                }
                break
            case "unfilled":
                if answer == nil {
                    return toPageIndex
                }
                break
            default:
                break
            }
        }
        
        
        guard let elseTransform = campaign?.transforms.first(where: { transform in
            transform.fromPage == campaign?.pages[currentPage].id && transform.action == "transition" && transform.fromField == nil
        }) else {
            return currentPage + 1
        }
        
        return campaign?.pages.lastIndex(where: { (page) -> Bool in
            page.id == elseTransform.toPage
        }) ?? (currentPage + 1)
    }
    
    private func checkFieldTransfromed(_ field: UXFField) -> Bool {
        guard let transform = campaign?.transforms.first(where: { (transform) -> Bool in
            transform.toField == field.id || transform.toButton == field.id
        }) else {
            return true
        }
        
        guard let answer = answers.first(where: { (dict) -> Bool in
            ((dict["fieldId"] as? String) ?? "") == transform.fromField
        }) else {
            return false
        }
        
        let type = UXFFieldType(rawValue: (answer["type"] as? String) ?? "")
        let answers = (answer["value"] as? [String]) ?? []
        
        if transform.rule == "equal" {
            let same = transform.value?.filter() { answers.contains($0) }
            if same?.count ?? 0 > 0 {
                return true
            }
        } else if transform.rule == "filled" {
            if type == .checkbox {
                if answers.count > 0 {
                    return true
                }
            }
            else {
                if (answers.first ?? "").count <= 0 {
                    return true
                }
            }
        }
         
        return false
    }
}

