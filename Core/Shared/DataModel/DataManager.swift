//
//  UXFDataPreparer.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

//// needs to refactoring to MANAGERS

import UIKit

enum FieldType: String {
    
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
    case rating = "rating"
    case screenshot = "screenshot"
}

protocol FieldDelegate {
    func fieldChanged(_ field: Field, answer: [String], refresh: Bool)
    func buttonTapped(_ field: Field, answer: [String], refresh: Bool)
    func textChanged(_ field: Field, answer: [String])
    func screenshotChanged(_ field: Field, screenshots: [Screenshot])
    func didBeginEditing(_ field: Field)
}

protocol RouterDelegate {
    func openUrl(_ urlString: String, params: TransformQueryParameter?)
}

class DataManager: FieldDelegate {
    
    private var viewController: CampaignViewController?
    
    private var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    private var height: CGFloat {
        return viewController?.view.bounds.height ?? UIScreen.main.bounds.height
    }
    
    private var currentPage: Int = 0
    private var campaign: Campaign?
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
    
    internal var safeSpace: CGFloat {
        get {
            if #available(iOS 13.0, *) {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    return scene.windows.first?.safeAreaInsets.bottom ?? .leastNonzeroMagnitude
                } else if let window = UIApplication.shared.windows.first {
                    return window.safeAreaInsets.bottom
                }
            } else {
                if let window = UIApplication.shared.windows.first {
                    return window.safeAreaInsets.bottom
                }
            }
            
            return .leastNonzeroMagnitude
        }
    }
    
    internal var bottomSpace: CGFloat {
        get {
            let bottomValue: CGFloat = safeSpace
            //            if privacyHeight != .leastNonzeroMagnitude {
            //                bottomValue = 0
            //            }
            return campaign?.type == .slidein ? bottomValue : 0
        }
    }
    
    init(_ target: CampaignViewController, campaign: Campaign?) {
        self.campaign = campaign
        self.viewController = target
    }
    
    private var answers = Array<Dictionary<String, Any>>()
    private var _screenshots: [Screenshot] = []
    public var screenshots: [Screenshot] {
        get {
            return _screenshots
        }
    }
    
    var isError: Bool = false
    
    private var isPrivacyChecked: Bool = false
    private var isPrivacyWarning: Bool = false
    
    var properties: [String: Any] = [:]
    
    //MARK: - Prepared Data
    
    internal func heightForCurrentPage() -> CGFloat {
        let page = campaign?.pages[currentPage]
        var height: CGFloat = 64
        if campaign?.copyright.isShow ?? true {
            height += 34
        }
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
                height = min(self.height, height)
                break
            case .popup:
                areas += extraSpace / 2
                height = min(self.height - 48, height)
                break
            default:
                break
        }
        
        height += privacyHeight
        
        let maxHeight = self.height - areas
        
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
    
    internal func viewForFieldHeader(index: Int) -> UIView? {
        let field = ((campaign?.pages[currentPage].fields ?? []) + (campaign?.pages[currentPage].buttons ?? []))[index]
        return checkFieldTransfromed(field) ? getFieldHeader(field) : nil
    }
    
    internal func viewForFieldFooter(index: Int) -> UIView? {
        let field = ((campaign?.pages[currentPage].fields ?? []) + (campaign?.pages[currentPage].buttons ?? []))[index]
        return checkFieldTransfromed(field) ? getFieldFooter(field) : nil
    }
    
    internal func heightForFieldCell(indexPath: IndexPath) -> CGFloat {
        let page = campaign?.pages[currentPage]
        let fields = (page?.fields ?? []) + (page?.buttons ?? [])
        let field = fields[indexPath.section]
        
        return getFieldHeight(field)
    }
    
    internal func fieldForRow(indexPath: IndexPath) -> Field {
        let page = campaign?.pages[currentPage]
        let fields = (page?.fields ?? []) + (page?.buttons ?? [])
        var field = fields[indexPath.section]
        
        let answer = answers.first { answer in ((answer["fieldId"] as? String) ?? "") == field.id }
        field.answers = (answer?["value"] as? [String]) ?? []
        field.isError = isError && ((field.uiData["required"] as? Bool) ?? false)
        
        field.isLastPage = campaign?.pages[currentPage].type == 2
        
        return field
    }
    
    var progress: String {
        get {
            return "\(currentPage + 1)/\(campaign?.pages.count ?? 0)"
        }
    }
    
    //MARK: - Support Fields
    
    private func getSpacing(fromField: Field, toField: Field?) -> CGFloat {
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
    
    private func getFooterSpacing(_ field: Field) -> CGFloat {
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
    
    private func getTitleSpacing(_ field: Field) -> CGFloat {
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
    
    private func getFieldHeaderHeight(_ field: Field) -> CGFloat {
        guard var value = field.value, value != "" else {
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
        
        let required = (field.uiData["required"] as? Bool) ?? false
        if required {
            value = "* " + value
        }
        
        let font = (campaign?.theme.fontH2)!
        let lines = value.linesCount(width: self.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace,
                                     font: font)//.mediumSemiboldFont)
        let valueHeight = CGFloat(lines) * font.lineHeight + getTitleSpacing(field)
        return valueHeight
    }
    
    private func getFieldFooterHeight(_ field: Field) -> CGFloat {
        var height: CGFloat = .leastNonzeroMagnitude
        
        if isError && fieldNeedComplete(field) {
            guard let warning = field.uiData["warning"] as? String else {
                return checkFieldTransfromed(field) ? 12 : .leastNonzeroMagnitude
            }
            let font = (campaign?.theme.fontP2)!
            let lines = warning.linesCount(width: self.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace,
                                           font: font)
            let valueHeight = CGFloat(lines) * font.lineHeight
            height += valueHeight + 8
        }
        else {
            height = .leastNonzeroMagnitude
        }
        
        return height + getFooterSpacing(field)
    }
    
    private func getFieldHeader(_ field: Field) -> UIView {
        if [FieldType.header, FieldType.text, FieldType.button, FieldType.image].contains(field.type) || field.value == nil || !checkFieldTransfromed(field) {
            return UIView()
        }
        
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: self.width - .leftArea - .rightArea,
                                                                    height: getFieldHeaderHeight(field))))
        
        
        
        let label = UILabel(frame: CGRect(origin: .init(x: 16, y: 0),
                                          size: CGSize(width: view.frame.width - extraSpace,
                                                       height: view.frame.height - getTitleSpacing(field))))// - 16)))
        
        label.textColor = campaign?.theme.text01Color
        
        let required = (field.uiData["required"] as? Bool) ?? false
        let text = "\(required ? "* " : "")\(field.value ?? "")"
        let range = (text as NSString).range(of: "*")
        let attributedString = NSMutableAttributedString(string:text)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: campaign?.theme.errorColorPrimary ?? Theme.init().errorColorPrimary, range: range)
        label.attributedText = attributedString
        
        
        label.font = campaign?.theme.fontH2
        
        label.textAlignment = .left
        label.numberOfLines = 0
        view.addSubview(label)
        view.backgroundColor = campaign?.theme.bgColor
        return view
    }
    
    private func getFieldFooter(_ field: Field) -> UIView {
        if isError && fieldNeedComplete(field) {
            guard let warning = field.uiData["warning"] as? String else {
                return UIView()
            }
            let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: self.width - .leftArea - .rightArea - extraSpace,
                                                                        height: getFieldFooterHeight(field))))
            let font = (campaign?.theme.fontP2)!
            let lines = warning.linesCount(width: self.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace,
                                           font: font)
            let valueHeight = CGFloat(lines) * font.lineHeight
            let label = UILabel(frame: CGRect(origin: CGPoint(x: 16,
                                                              y: 8),
                                              size: CGSize(width: view.frame.size.width - 32,
                                                           height: valueHeight)))
            
            label.text = warning
            label.textColor = campaign?.theme.errorColorPrimary
            label.font = font
            label.numberOfLines = 0
            let fieldIndex = Int((campaign?.pages[currentPage].fields.firstIndex(where: { (fld) -> Bool in
                fld.id == field.id
            }))!)
            label.tag = fieldIndex
            view.addSubview(label)
            view.clipsToBounds = true
            view.backgroundColor = campaign?.theme.bgColor
            return view
        }
        else {
            return UIView()
        }
    }
    
    private func getFieldHeight(_ field: Field) -> CGFloat {
        if !checkFieldTransfromed(field) {
            return .leastNonzeroMagnitude
        }
        switch field.type {
            case .button:
                return 40
                
            case .smiles:
                return 40
                
            case .checkbox:
                let width = self.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace - 48
                var height: CGFloat = 0
                let checkboxes = field.uiData["options"] as? Array<Dictionary<String, Any>> ?? []
                for checkbox in checkboxes {
                    let value = checkbox["value"] as? String ?? ""
                    let font = (campaign?.theme.fontP1)!
                    let lines = CGFloat(value.linesCount(width: width, font: font))
                    height += max(ceil(lines * font.lineHeight) + 24, 48)
                }
                return height
                
            case .email:
                return 40
                
            case .header:
                let font = (campaign?.theme.fontH1)!
                let lines = field.value!.linesCount(width: self.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace,
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
                let font = (campaign?.theme.fontP1)!
                let lines = min(answer.linesCount(width: self.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace,
                                                  font: font), 10)
                let valueHeight = ceil(CGFloat(lines) * font.lineHeight)
                
                return max(valueHeight, minHeight)
                
            case .radiobutton:
                let width = self.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace - 48
                var height: CGFloat = 0
                let buttons = field.uiData["options"] as? Array<Dictionary<String, Any>> ?? []
                for button in buttons {
                    let value = button["value"] as? String ?? ""
                    let font = (campaign?.theme.fontP1)!
                    let lines = CGFloat(value.linesCount(width: width, font: font))
                    height += max(ceil(lines * font.lineHeight) + 24, 48)
                }
                return height
                
            case .text:
                let font = (campaign?.theme.fontP1)!
                let lines = field.value!.linesCount(width: self.width -  CGFloat.leftArea - CGFloat.rightArea - extraSpace,
                                                    font: font)
                let valueHeight = ceil(CGFloat(lines) * font.lineHeight)
                return valueHeight
                
            case .stars:
                return 40
                
            case .bottom:
                return 40
                
            case .nps, .rating:
                if let messages = field.uiData["messages"] as? [String: String] {
                    let count = (messages["negative"]?.count ?? 0) + (messages["positive"]?.count ?? 0)
                    return count > 0 ? 110 : 76
                }
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
                return screenshots.filter { $0.field.id == field.id }.count > 0 ? 140 + buttonsHeight : buttonsHeight
                
            case .none:
                return 40
        }
    }
    
    //MARK: - UXFFieldDelegate
    
    func buttonTapped(_ field: Field, answer: [String], refresh: Bool) {
        viewController?.view.endEditing(true)
        isError = false
        if !isPrivacyChecked && privacyNeeded {
            isPrivacyWarning = true
            checkPrivacy(nil)
            
            if needsComplete() {
                isError = true
                viewController?.updateUI()
            }
            return
        }
        
        if needsComplete() {
            isError = true
            viewController?.updateUI()
        } else {
            let nextIndex = getNextIndex()
            if campaign?.pages[currentPage].type == 2 || nextIndex == -1 {
                endCampaign(terminated: false, isLink: nextIndex == -1)
            }
            else {
                nextPage(nextIndex)
            }
        }
    }
    
    func fieldChanged(_ field: Field, answer: [String], refresh: Bool = true) {
        DispatchQueue.main.async {
            self.answers = self.answers.filter { answer in ((answer["fieldId"] as? String) ?? "") != field.id }
            if answer.count > 0 {
                var scenariosResult: [String] = []
                
                self.campaign?.transforms.forEach({ transform in
                    transform.scenarios.forEach { scenario in
                        let conditions = scenario.conditions.filter({
                            if $0.from.field != field.id {
                                return false
                            }
                            let same = $0.condition?.value?.filter() { answer.contains($0) }.count ?? 0
                            switch $0.condition?.rule {
                                case "equal", "contain":
                                    return same > 0
                                    
                                case "filled":
                                    return answer.count > 0
                                    
                                default:
                                    return false
                            }
                        })
                        if conditions.count == scenario.conditions.count {
                            scenariosResult.append(scenario.id)
                        }
                    }
                })
                
                let newAnswer = ["pageId": self.campaign?.pages[self.currentPage].id ?? "",
                                 "fieldId": field.id as Any,
                                 "type": field.type?.rawValue as Any,
                                 "value": answer,
                                 "scenarios": scenariosResult] as [String : Any]
                self.answers.append(newAnswer)
            }
            
            if refresh {
                self.viewController?.updateUI() //fieldIndex
            }
        }
    }
    
    
    func textChanged(_ field: Field, answer: [String]) {
        answers = answers.filter { answer in ((answer["fieldId"] as? String) ?? "") != field.id }
        if answer.count > 0 {
            let newAnswer = ["fieldId": field.id as Any,
                             "type": field.type?.rawValue as Any,
                             "value": answer,
                             "transforms": ""] as [String : Any]
            answers.append(newAnswer)
        }
    }
    
    func screenshotChanged(_ field: Field, screenshots: [Screenshot]) {
        isError = false
        _screenshots = screenshots
        
        
        let screenshotIds = _screenshots.filter { $0.field.id == field.id }.map { $0.id }
        fieldChanged(field, answer: screenshotIds, refresh: true)
    }
    
    func didBeginEditing(_ field: Field) {
        guard let fieldIndex = campaign?.pages[currentPage].fields.firstIndex(where: { (fld) -> Bool in
            fld.id == field.id
        }) else {
            return
        }
        
        viewController?.didBeginEditing(fieldIndex)
    }
    
    //MARK: - PRIVACY
    
    var privacyNeeded: Bool {
        get {
            if let privacy = campaign?.privacy,
               privacy.enabled,
               (campaign?.privacy?.privacyPages ?? []).contains(campaign?.pages[currentPage].id ?? "") {
                return true
            }
            return false
        }
    }
    
    var privacyHeight: CGFloat {
        if privacyNeeded {
            let privacyString = self.campaign?.privacy?.declaration.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) ?? ""
            
            let warningString = self.campaign?.privacy?.warningMessage ?? ""
            
            var height: CGFloat = 36 //+ safeSpace
            
            height += privacyString.height(withConstrainedWidth: width - 64, font: campaign?.theme.fontP2 ?? .systemFont(ofSize: 14))
            if self.isPrivacyWarning {
                height += warningString.height(withConstrainedWidth: width - 64, font: campaign?.theme.fontP2 ?? .systemFont(ofSize: 14))
                height += 20
            }
            
            return max(height, 64)
        }
        return .leastNonzeroMagnitude
    }
    
    func tapPrivacy() {
        if let privacy = campaign?.privacy, privacy.type != "text" {
            isPrivacyWarning = false
            checkPrivacy(!isPrivacyChecked)
        }
    }
    
    func checkPrivacy(_ isChecked: Bool?) {
        if let isChecked = isChecked {
            self.isPrivacyChecked = isChecked
        }
        
        if privacyNeeded {
            let warningText: String? = isPrivacyWarning ? campaign?.privacy?.warningMessage : nil
            let privacyText: String? = campaign?.privacy?.declaration
            
            viewController?.updatePrivacy(enabled: height != .leastNonzeroMagnitude,
                                          height: privacyHeight,
                                          warning: warningText,
                                          text: privacyText,
                                          checked: isPrivacyChecked)
        } else {
            viewController?.updatePrivacy(enabled: false,
                                          height: .leastNonzeroMagnitude,
                                          warning: nil,
                                          text: nil,
                                          checked: isPrivacyChecked)
        }
    }
    
    //MARK: - Routing
    
    private func nextPage(_ index: Int) {
        toPage(index: index)
    }
    
    private func toPage(index: Int) {
        currentPage = index
        viewController?.scrollToTop(animated: false)
        viewController?.updateUI()
    }
    
    public func endCampaign(terminated: Bool, isLink: Bool = false) {
        var formattedAnswers = Array<Dictionary<String, Any>>()
        answers.forEach { (answer) in
            var item = answer
            switch (FieldType(rawValue: item["type"] as! String)) {
                case .radiobutton, .email, .input:
                    item["value"] = (answer["value"] as? [String])?.first
                    
                case .smiles, .nps, .rating:
                    item["value"] = Int(((answer["value"] as? [String])?.first)!)
                    
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
            
            result["externalLink"] = isLink ? 1 : 0
            
            results.append(result)
        }
        
        if isPrivacyChecked || !privacyNeeded {
            if terminated {
                viewController!.didTerminateHandler?(results, screenshots, currentPage + 1, campaign?.pages.count ?? 0)
            } else {
                viewController!.completeHandler!(results, screenshots)
                viewController!.didCloseHandler?()
            }
        } else {
            viewController!.didCloseHandler?()
        }
        
        viewController?.dismiss(animated: viewController?.presentationAnimated ?? true)
    }
    
    //MARK: - TRANSFORMATIONS
    
    private func fieldNeedComplete(_ field: Field) -> Bool {
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
    
    private func completedTransforms() -> [Transform] {
        let transforms = campaign?.transforms.filter({
            let scenarios = $0.scenarios.filter({
                let conditions = $0.conditions.filter { condition in
                    let answer = answers.first(where: { (dict) -> Bool in
                        ((dict["fieldId"] as? String) ?? "") == condition.from.field
                    })
                    let answers = (answer?["value"] as? [String]) ?? []
                    let type = FieldType(rawValue: (answer?["type"] as? String) ?? "")
                    
                    switch condition.condition?.rule {
                        case "equal":
                            let sameCount = condition.condition?.value?.filter() { answers.contains($0) }.count ?? 0
                            if sameCount == condition.condition?.value?.count &&
                                sameCount == fieldAnswersCount(condition.from.field ?? "") {
                                return true
                            }
                        case "contain":
                            let same = condition.condition?.value?.filter() { answers.contains($0) }
                            if same?.count ?? 0 > 0 {
                                return true
                            }
                            
                        case "filled":
                            if type == .checkbox {
                                if answers.count > 0 {
                                    return true
                                }
                            } else {
                                if (answers.first ?? "").count > 0 {
                                    return true
                                }
                            }
                            
                        case "unfilled":
                            if answer == nil {
                                return true
                            }
                            
                        default:
                            break
                    }
                    return false
                }
                return $0.conditions.count == conditions.count
            })
            return scenarios.count > 0
        }) ?? []
        
        return transforms
    }
    
    private func prepareNextIndex(_ currentPage: Int, basePage: Int) -> Int {
        let transforms = completedTransforms().filter { transform in
            var result = transform.to.action == "transition" &&
            transform.to.value != self.campaign?.pages[currentPage].id
            if let toPageIndex = campaign?.pages.lastIndex(where: { (page) -> Bool in
                page.id == transform.to.value
            }) {
                result = result && basePage < toPageIndex
            }
            
            return result
        }
        
        for transform in transforms {
            let toPageIndex = campaign?.pages.lastIndex(where: { (page) -> Bool in
                page.id == transform.to.value
            }) ?? (currentPage + 1)
            
            let toValue = transform.to.value
            let toType = transform.to.type
            let toParams = transform.to.queryParams
            
            switch toType {
                case "toPage":
                    return toPageIndex
                case "toDeeplink", "toURL":
                    openUrl(toValue, params: toParams)
                    return -1
                    
                default:
                    break
            }
        }
        
        guard let elseTransform = campaign?.transforms.first(where: { transform in
            return transform.scenarios.first { scenario in
                scenario.conditions.first { condition in
                    return (condition.from.page == campaign?.pages[basePage].id &&
                            transform.to.action == "transition" &&
                            condition.from.field == nil)
                } != nil
            } != nil
        }) else {
            return currentPage + 1
        }
        
        if elseTransform.to.type == "toDeeplink" || elseTransform.to.type == "toURL" {
            openUrl(elseTransform.to.value, params: elseTransform.to.queryParams)
            return -1
        } else {
            return campaign?.pages.lastIndex(where: { (page) -> Bool in
                page.id == elseTransform.to.value
            }) ?? (currentPage + 1)
        }
    }
    
    private func getNextIndex() -> Int {
        guard let campaign = campaign else {
            return currentPage + 1
        }
        
        var nextIndex = currentPage
        var needsShow = false
        
        while !needsShow {
            nextIndex = prepareNextIndex(nextIndex, basePage: currentPage)
            
            if campaign.pages.indices.contains(nextIndex) {
                if campaign.pages[nextIndex].type == 2 {
                    needsShow = true
                } else {
                    var fieldsToShow = false
                    for field in campaign.pages[nextIndex].fields {
                        if checkFieldTransfromed(field) {
                            fieldsToShow = true
                        }
                    }
                    
                    if fieldsToShow {
                        needsShow = true
                    }
                }
            } else {
                needsShow = true
            }
        }
        
        return nextIndex
    }
    
    private func checkFieldTransfromed(_ field: Field) -> Bool {
        guard let transforms = campaign?.transforms.filter({ $0.to.value == field.id }),
              transforms.count > 0 else {
            return true
        }
        
        let checkedTransforms = completedTransforms().filter({
            transforms.map {$0.id}.contains($0.id)
        })
        
        //        let checkedTransforms = transforms.filter({
        //            let scenarios = $0.scenarios.filter({
        //                let conditions = $0.conditions.filter { condition in
        //                    let answer = answers.first(where: { (dict) -> Bool in
        //                        ((dict["fieldId"] as? String) ?? "") == condition.from.field
        //                    })
        //                    let answers = (answer?["value"] as? [String]) ?? []
        //                    let type = FieldType(rawValue: (answer?["type"] as? String) ?? "")
        //
        //                    switch condition.condition?.rule {
        //                        case "equal":
        //                            let sameCount = condition.condition?.value?.filter() { answers.contains($0) }.count ?? 0
        //                            if sameCount == condition.condition?.value?.count &&
        //                                sameCount == fieldAnswersCount(condition.from.field ?? "") {
        //                                return true
        //                            }
        //                        case "contain":
        //                            let same = condition.condition?.value?.filter() { answers.contains($0) }
        //                            if same?.count ?? 0 > 0 {
        //                                return true
        //                            }
        //
        //                        case "filled":
        //                            if type == .checkbox {
        //                                if answers.count > 0 {
        //                                    return true
        //                                }
        //                            } else {
        //                                if (answers.first ?? "").count > 0 {
        //                                    return true
        //                                }
        //                            }
        //
        //                        case "unfilled":
        //                            if answer == nil {
        //                                return true
        //                            }
        //
        //                        default:
        //                            break
        //                        }
        //                    return false
        //                }
        //                return $0.conditions.count == conditions.count
        //            })
        //            return scenarios.count > 0
        //        })
        
        if checkedTransforms.count > 0 {
            return true
        }
        
        clearAnswers(field.id!)
        return false
    }
    
    private func openUrl(_ urlString: String, params: TransformQueryParameter?) {
        viewController?.openUrl(urlString, params: params)
    }
    
    private func clearAnswers(_ fieldId: String) {
        answers.removeAll { dict in
            if let fId = dict["fieldId"] as? String {
                return fId == fieldId
            }
            return false
        }
    }
    
    private func fieldAnswersCount(_ fieldId: String) -> Int {
        var result = 0
        let answer = answers.first { dict in
            if let fId = dict["fieldId"] as? String {
                return fId == fieldId
            }
            return false
        }
        if let value = answer?["value"] as? [String] {
            result = value.count
        }
        return result
    }
}


