//
//  UXFBaseViewController.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 09.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit
import PhotosUI

let visualEffectViewTag = 777

enum ViewPopupDirection {
    case upToDown
    case downToUp
    case alphaIn
    case alphaOut
}

enum ViewControllerState {
    case presenting
    case presented
    case backDismiss
    case dismissOnly
}

internal class CampaignViewController: UIViewController {
    @IBOutlet var contentView: UIView!
    private var privacyView: PrivacyView?
    
    @IBOutlet var shadowView: AnimatingShadowView! {
        didSet {
            shadowView.backgroundColor = campaign?.theme.bgColor ?? .white
        }
    }
    @IBOutlet var progressLabel: UILabel! {
        didSet {
            progressLabel.text = ""
            progressLabel.textColor = campaign?.theme.text03Color ?? .lightGray
        }
    }
    
    @IBOutlet var closeButton: UIButton! {
        didSet {
            closeButton.setImage(UIImage(named: "close_image", in: Consts.bundle, compatibleWith: nil)?.tint(with: campaign?.theme.iconColor ?? .lightGray), for: .normal)
        }
    }
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            configureTableView()
        }
    }
    
    @IBOutlet var topView: UIView! {
        didSet {
            topView.backgroundColor = campaign?.theme.bgColor ?? .white
        }
    }
    
    @IBOutlet var contentHeight: NSLayoutConstraint!
    
    @IBOutlet var verticallyConstraint: NSLayoutConstraint!
    @IBOutlet var leftConstraint: NSLayoutConstraint!
    @IBOutlet var rightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var titleViewHeightConstaint: NSLayoutConstraint!
    
    var presentationAnimated = true
    
    var state: ViewControllerState = .presenting
    var blackout: Blackout?
    
    var didTerminateHandler: ((_ info: Array<Dictionary<String, Any>>?, _ screenshots: [Screenshot], Int, Int)->())?
    var didCloseHandler: (()->(Void))?
    var completeHandler: ((_ info: Array<Dictionary<String, Any>>?, _ screenshots: [Screenshot])->())?
    var presentHandler: (()->())?
    
    var presentDirection: ViewPopupDirection = .downToUp
    var dismissDirection: ViewPopupDirection = .upToDown
    
    var closeOnSwipe: Bool = false
    
    var rotateToggle: Bool = false
    
    var properties: [String: Any] = [:]
    
    internal var campaign: Campaign?
    
    private var direction: CGFloat = 0
    private var lastTouch: CGFloat = 0
    
    private var dataManager: DataManager?
    
    var keyboardHeight: CGFloat = 0
    
    //    private var showGalleryTask: DispatchWorkItem?
    
    convenience init() {
        self.init(nibName: String(describing: type(of: self)), bundle: Consts.bundle)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        dataManager = DataManager(self, campaign: campaign)
        prepareUI()
        if let theme = campaign?.theme {
            privacyView = PrivacyView(frame: .zero, theme: theme, delegate: self)
            privacyView?.preparePrivacy(campaign?.privacy?.type ?? "")
        }
        
        if presentHandler != nil {
            presentHandler!()
        }
        if let progress = campaign?.progress?.enabled, progress {
            progressLabel.isHidden = false
        } else {
            progressLabel.isHidden = true
        }
        //        else if (campaign?.transforms.count ?? 0) > 0 {
        //            progressLabel.isHidden = true
        //        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rotated),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard
            let userinfo = notification.userInfo,
            let duration = (userinfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let endFrame = (userinfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let curveOption = userinfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        let space = UIScreen.main.bounds.height - (self.dataManager?.heightForCurrentPage() ?? 0)
        if space > 240 {
            if campaign?.type == .popup {
                let diff = space / 2 - endFrame.height
                self.bottomConstraint.constant = diff < 0 ? -diff : 0
            } else {
                self.bottomConstraint.constant = -endFrame.height + (self.dataManager?.safeSpace ?? 0)
            }
            
            UIView.animate(withDuration: duration, delay: 0) {
                self.view.layoutIfNeeded()
                self.tableView.contentInset = .zero
            }
        } else {
            UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .init(rawValue: curveOption)], animations: {
                let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: endFrame.height, right: 0)
                self.tableView.contentInset = edgeInsets
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userinfo = notification.userInfo else {
            return
        }
        
        guard
            let duration = (userinfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curveOption = userinfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        self.bottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .init(rawValue: curveOption)], animations: {
            let edgeInsets = UIEdgeInsets.zero
            self.tableView.contentInset = edgeInsets
            self.view.layoutIfNeeded()
        })
    }
    
    open override func viewDidLayoutSubviews() {
        DispatchQueue.main.async {
            self.updateLayouts()
        }
    }
    
    open override func viewWillLayoutSubviews() {
        if IS_IPAD {
            DispatchQueue.main.async {
                if let effectView = self.view.viewWithTag(visualEffectViewTag) {
                    effectView.frame = UIScreen.main.bounds
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func rotated() {
        DispatchQueue.main.async {
            if let effectView = self.view.viewWithTag(visualEffectViewTag) {
                effectView.frame = UIScreen.main.bounds
                self.dataManager?.checkPrivacy(nil)
            }
            self.tableView.reloadData()
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Support
    
    private func createFooter(withPrivacy: Bool) {
        var height: CGFloat = campaign?.copyright.isShow ?? true ? 50 : 16
        
        if withPrivacy {
            privacyView?.frame.origin.y = height
            height += privacyView?.frame.size.height ?? .leastNonzeroMagnitude
        }
        
        let tableFooterView = UIView(frame: CGRect(origin: .zero,
                                                   size: CGSize(width: UIScreen.main.bounds.width - 32,
                                                                height: height)))
        if campaign?.copyright.isShow ?? true {
            let image = UIImageView(frame: CGRect(origin: CGPoint(x: 16,
                                                                  y: 12),
                                                  size: CGSize(width: 30,
                                                               height: 30)))
            image.contentMode = .scaleAspectFit
            
            var urlString: String?
            let scale = UIScreen.main.scale
            switch scale {
                case 1:
                    urlString = campaign?.copyright.image?["1x"] as? String
                case 2:
                    urlString = campaign?.copyright.image?["2x"] as? String
                case 3:
                    urlString = campaign?.copyright.image?["3x"] as? String
                    
                default:
                    break
            }
            if let urlString = urlString, let url = URL(string: urlString) {
                image.cacheImage(url: url, withTemplate: true)
            } else {
                image.image = UIImage(named: "logo", in: Consts.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            }
            
            let tapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.cancelsTouchesInView = false
            tapGestureRecognizer.addTarget(self, action: #selector(onLogoTap(tap:)))
            tapGestureRecognizer.delegate = self
            image.addGestureRecognizer(tapGestureRecognizer)
            image.isUserInteractionEnabled = true
            
            image.tintColor = campaign?.theme.inputBorderColor
            tableFooterView.backgroundColor = campaign?.theme.bgColor ?? .white
            tableFooterView.addSubview(image)
        }
        if withPrivacy && privacyView != nil {
            privacyView?.removeFromSuperview()
            tableFooterView.addSubview(privacyView!)
        }
        tableView.tableFooterView = tableFooterView
    }
    
    private func configureTableView() {
        createFooter(withPrivacy: false)
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero,
                                                         size: CGSize(width: 1,
                                                                      height: 1)))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.delaysContentTouches = false
        tableView.backgroundColor = campaign?.theme.bgColor ?? .white
        
        tableView.register(UINib(nibName: "ButtonCell",
                                 bundle: Consts.bundle),
                           forCellReuseIdentifier: "ButtonCell")
        tableView.register(UINib(nibName: "SmilesCell",
                                 bundle: Consts.bundle),
                           forCellReuseIdentifier: "SmilesCell")
        tableView.register(UINib(nibName: "StarsCell",
                                 bundle: Consts.bundle),
                           forCellReuseIdentifier: "StarsCell")
        tableView.register(UINib(nibName: "CheckboxCell",
                                 bundle: Consts.bundle),
                           forCellReuseIdentifier: "CheckboxCell")
        tableView.register(UINib(nibName: "EmailCell",
                                 bundle: Consts.bundle),
                           forCellReuseIdentifier: "EmailCell")
        tableView.register(UINib(nibName: "HeaderCell",
                                 bundle: Consts.bundle),
                           forCellReuseIdentifier: "HeaderCell")
        tableView.register(UINib(nibName: "ImageCell",
                                 bundle: Consts.bundle),
                           forCellReuseIdentifier: "ImageCell")
        tableView.register(UINib(nibName: "InputCell",
                                 bundle: Consts.bundle),
                           forCellReuseIdentifier: "InputCell")
        tableView.register(UINib(nibName: "RadiobuttonCell",
                                 bundle: Consts.bundle),
                           forCellReuseIdentifier: "RadiobuttonCell")
        tableView.register(UINib(nibName: "TextCell",
                                 bundle: Consts.bundle),
                           forCellReuseIdentifier: "TextCell")
        tableView.register(UINib(nibName: "NpsCell",
                                 bundle: Consts.bundle),
                           forCellReuseIdentifier: "NpsCell")
        tableView.register(UINib(nibName: "RatingCell",
                                 bundle: Consts.bundle),
                           forCellReuseIdentifier: "RatingCell")
        tableView.register(UINib(nibName: "ScreenshotCell",
                                 bundle: Consts.bundle),
                           forCellReuseIdentifier: "ScreenshotCell")
        
        //        if #available(iOS 15.0, *) {
        //            tableView.sectionHeaderTopPadding = 0
        //        }
    }
    
    private func prepareUI() {
        progressLabel.text = dataManager?.progress
        contentView.backgroundColor = campaign?.theme.bgColor ?? .white
        tableView.backgroundColor = campaign?.theme.bgColor ?? .white
        contentHeight.constant = dataManager?.heightForCurrentPage() ?? 0
        //        contentView.backgroundColor = campaign?.theme.inputBgColor ?? .white
        
        tableViewBottomConstraint.constant = dataManager?.bottomSpace ?? 0
        titleViewHeightConstaint.constant = dataManager?.titleViewHeight ?? 54
        switch campaign?.type {
            case .slidein:
                dismissDirection = .upToDown
                verticallyConstraint.isActive = false
                bottomConstraint.isActive = true
                leftConstraint.constant = 0
                rightConstraint.constant = 0
                let panGestureRecognizer = UIPanGestureRecognizer()
                panGestureRecognizer.addTarget(self, action: #selector(onPan(pan:)))
                contentView.addGestureRecognizer(panGestureRecognizer)
                break
                
            case .popup:
                dismissDirection = .alphaOut
                verticallyConstraint.isActive = true
                bottomConstraint.isActive = false
                leftConstraint.constant = 24
                rightConstraint.constant = 24
                break
                
            default:
                break
        }
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.addTarget(self, action: #selector(onTap(tap:)))
        tapGestureRecognizer.delegate = self
        contentView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func updateLayouts() {
        prepareUI()
        shadowView.addShadowAndRoundCorner(cornerRadius: campaign?.theme.formBorderRadius ?? 8)
        
        switch campaign?.type {
            case .slidein:
                contentView.roundCorners(corners: [.topLeft, .topRight], radius: campaign?.theme.formBorderRadius ?? 8)
                break
            case .popup:
                contentView.roundCorners(corners: .allCorners, radius: campaign?.theme.formBorderRadius ?? 8)
                break
            default:
                break
        }
    }
    
    //MARK: - Actions
    
    @IBAction  func closeButtonTapped(_ sender: UIButton) {
        dataManager?.endCampaign(terminated: true)
    }
    
    override open func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: presentationAnimated) { [weak self] in
            if self?.state != .dismissOnly && self?.state != .backDismiss {
                for window in UIApplication.shared.windows {
                    if window is PassthroughWindow {
                        window.isHidden = true
                        window.resignKey()
                    }
                }
                UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            }
            
            completion?()
        }
    }
    
    @objc func onLogoTap(tap: UITapGestureRecognizer) -> Void {
        view.endEditing(true)
        var href: String = ""
        if (campaign?.copyright.href) != nil {
            href = (campaign?.copyright.href)!
        } else {
            href = Consts.defaultHref
        }
        
        guard href.count > 0,
              let url = URL(string: href),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc func onTap(tap: UITapGestureRecognizer) -> Void {
        view.endEditing(true)
        self.bottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func onPan(pan: UIPanGestureRecognizer) -> Void {
        view.endEditing(true)
        var safeArea: CGFloat = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            safeArea = window?.safeAreaInsets.bottom ?? 0
        }
        
        let sheetY = contentHeight.constant - (dataManager?.titleViewHeight ?? 0) - safeArea
        
        switch pan.state {
            case .began:
                lastTouch = self.bottomConstraint.constant
                //            view.frame.size.height = view.frame.height
                break
            case .changed:
                let velocity = pan.velocity(in: pan.view?.superview)
                
                direction = velocity.y
                break
            case .ended:
                if direction > 120 {
                    if closeOnSwipe {
                        dataManager?.endCampaign(terminated: true)
                    } else {
                        if self.bottomConstraint.constant == sheetY {
                            dataManager?.endCampaign(terminated: true)
                        }
                        else {
                            self.bottomConstraint.constant = sheetY
                        }
                    }
                }
                else if direction < -120 {
                    self.bottomConstraint.constant = 0
                }
                
                UIView.animate(withDuration: 0.1) {
                    self.view.layoutIfNeeded()
                }
                
                break
            default:
                break
        }
    }
}

extension CampaignViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIButton)
    }
}

extension CampaignViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataManager?.heightForFieldHeader(index: section) ?? 12
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return dataManager?.heightForFieldFooter(index: section) ?? 12
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return dataManager?.viewForFieldHeader(index: section)
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return dataManager?.viewForFieldFooter(index: section)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataManager?.fieldsCount() ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager?.numberForFieldCell(index: section) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataManager?.heightForFieldCell(indexPath: indexPath) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let field = dataManager?.fieldForRow(indexPath: indexPath) else {
            return UITableViewCell()
        }
        switch field.type {
            case .button:
                let cell = createCell(ButtonCell.self, indexPath: indexPath, field: field)
                return cell
                
            case .smiles:
                let cell = createCell(SmilesCell.self, indexPath: indexPath, field: field)
                return cell
                
            case .checkbox:
                let cell = createCell(CheckboxCell.self, indexPath: indexPath, field: field)
                return cell
                
            case .email:
                let cell = createCell(EmailCell.self, indexPath: indexPath, field: field)
                return cell
                
            case .header:
                let cell = createCell(HeaderCell.self, indexPath: indexPath, field: field)
                return cell
                
            case .image:
                let cell = createCell(ImageCell.self, indexPath: indexPath, field: field)
                return cell
                
            case .input:
                let cell = createCell(InputCell.self, indexPath: indexPath, field: field)
                return cell
                
            case .radiobutton:
                let cell = createCell(RadiobuttonCell.self, indexPath: indexPath, field: field)
                return cell
                
            case .text:
                let cell = createCell(TextCell.self, indexPath: indexPath, field: field)
                return cell
                
            case .stars:
                let cell = createCell(StarsCell.self, indexPath: indexPath, field: field)
                return cell
                
            case .nps:
                let cell = createCell(NpsCell.self, indexPath: indexPath, field: field)
                return cell
            case .rating:
                let cell = createCell(RatingCell.self, indexPath: indexPath, field: field)
                return cell
                
            case .screenshot:
                let cell = createCell(ScreenshotCell.self, indexPath: indexPath, field: field)
                let sShots = dataManager?.screenshots.filter({ screenshot in
                    screenshot.field.id == field.id
                }) ?? []
                cell.setScreenshots(sShots)
                ImageManager.theme = self.campaign?.theme
                let takeTask = DispatchWorkItem {
                    UIView.animate(withDuration: 0.15) {
                        self.view.alpha = 0
                    } completion: { finish in
                        ImageManager.showScreenshotTake { images in
                            self.addScreenshots(images, type: .screenshot, field: field)
                        } closeAction: {
                            UIView.animate(withDuration: 0.15) {
                                self.view.alpha = 1
                            }
                        }
                    }
                }
                
                let selectTask = DispatchWorkItem {
                    self.checkGalleryPermissions { result in
                        if result {
                            DispatchQueue.main.async {
                                let count = 3 - (sShots.count)
                                guard  count > 0 else {
                                    return
                                }
                                
                                PHPhotoLibrary.shared().unregisterChangeObserver(self)
                                ImageManager.showGallery(maxCount: count) { images in
                                    self.addScreenshots(images, type: .gallery, field: field)
                                }
                            }
                        }
                    }
                }
                
                cell.setActions(take: {
                    DispatchQueue.main.async(execute: takeTask)
                }, select: {
                    DispatchQueue.main.async(execute: selectTask)
                }, campaignType: campaign?.type ?? .slidein)
                
                
                return cell
                
            case .none, .bottom:
                let cell = UITableViewCell()
                cell.contentView.backgroundColor = campaign?.theme.bgColor ?? .white
                cell.backgroundColor = campaign?.theme.bgColor ?? .white
                return UITableViewCell()
        }
    }
    
    private func addScreenshots(_ images: [UIImage], type: ScreenshotType, field: Field) {
        var screenshots = dataManager?.screenshots
        for image in images {
            screenshots?.append(Screenshot(id: .randomImageName, image: image, type: type, field: field))
        }
        
        dataManager?.screenshotChanged(field, screenshots: screenshots ?? [])
    }
    
    private func checkGalleryPermissions(completionHandler: @escaping (Bool) -> ()) {
        var status: PHAuthorizationStatus?
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        
        guard let status = status else {
            completionHandler(false)
            return
        }
        
        if status == .notDetermined {
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    self.checkGalleryPermissionsStatus(status) { result in
                        completionHandler(result)
                    }
                }
            } else {
                PHPhotoLibrary.requestAuthorization { status in
                    self.checkGalleryPermissionsStatus(status) { result in
                        completionHandler(result)
                    }
                }
            }
        } else {
            checkGalleryPermissionsStatus(status) { result in
                completionHandler(result)
            }
        }
    }
    
    private func checkGalleryPermissionsStatus(_ status: PHAuthorizationStatus, completionHandler: @escaping (Bool) -> ()) {
        switch status {
            case .notDetermined:
                completionHandler(false)
                
            case .restricted:
                self.showAlert(title: Consts.Texts.information, message: Consts.Texts.noPhotoAccess, buttonTitle: Consts.Texts.close)
                completionHandler(false)
                
            case .denied:
                self.showAlertSettings()
                completionHandler(false)
                
            case .authorized:
                completionHandler(true)
                
            case .limited:
                let photosCount = PHAsset.fetchAssets(with: .image, options: nil).count
                if photosCount > 0 {
                    completionHandler(true)
                } else {
                    self.showAlertPhotoAccess()
                    completionHandler(false)
                }
                
            @unknown default:
                return
        }
    }
    
    //MARK: - Show Alert
    
    private func showAlertPhotoAccess() {
        DispatchQueue.main.async {
            let appName = Bundle.main.infoDictionary?["CFBundleName"] ?? "AppName"
            let alert = UIAlertController(title: "\"\(appName)\" \(Consts.Texts.wantToPhotoAccess)", message: Consts.Texts.noOnePhotoAccess, preferredStyle: .alert)
            let openPhotoAccessAction = UIAlertAction(title: Consts.Texts.changeChoice, style: .default) { alertAction in
                alert.dismiss(animated: true, completion: nil)
                
                if #available(iOS 14, *) {
                    PHPhotoLibrary.shared().register(self)
                    PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
                }
            }
            let closeAction = UIAlertAction(title: Consts.Texts.close, style: .default) { alertAction in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(openPhotoAccessAction)
            alert.addAction(closeAction)
            alert.presentGlobally(animated: true, completion: nil)
        }
    }
    
    private func showAlertSettings() {
        DispatchQueue.main.async {
            let appName = Bundle.main.infoDictionary?["CFBundleName"] ?? "AppName"
            let alert = UIAlertController(title: "\"\(appName)\" \(Consts.Texts.wantToPhotoAccess)", message: Consts.Texts.goSettingsAccess, preferredStyle: .alert)
            let openSettingsAction = UIAlertAction(title: Consts.Texts.openSettings, style: .default) { alertAction in
                alert.dismiss(animated: true, completion: nil)
                guard let url = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(url) else {
                    return
                }
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            let closeAction = UIAlertAction(title: "Закрыть", style: .default) { alertAction in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(openSettingsAction)
            alert.addAction(closeAction)
            alert.presentGlobally(animated: true, completion: nil)
        }
    }
    
    private func showAlert(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: buttonTitle, style: .default) { alertAction in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            alert.presentGlobally(animated: true, completion: nil)
        }
    }
    
    //MARK: - Table View support
    
    private func createCell<T: BaseCell>(_ type: T.Type, indexPath: IndexPath, field: Field) -> T {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as! T
        cell.configureWith(field, theme: (campaign?.theme)!, delegate: dataManager!, valueIndex: indexPath.row)
        cell.backgroundColor = campaign?.theme.bgColor ?? .white
        return cell
    }
    
    //MARK: - Update changes
    
    func scrollToTop(animated: Bool) {
        self.tableView.setContentOffset(.zero, animated: animated)
    }
    
    func updateField(idx: Int) {
        if let label = view.viewWithTag(idx) as? UILabel {
            label.text = ""
        }
        
        var indexSet = IndexSet(integersIn: 0..<self.tableView.numberOfSections)
        indexSet.remove(idx)
        
        //        self.tableView.reloadSections(indexSet, with: .none)
        self.tableView.reloadData()
        self.updateHeight()
    }
    
    func updateUI(_ sender: Int? = nil) {
        self.progressLabel.text = dataManager?.progress
        if let sender = sender {
            for i in 0..<(dataManager?.fieldsCount() ?? 0) {
                if i != sender {
                    self.tableView.reloadSections([i], with: .automatic)
                }
            }
        } else {
            self.tableView.reloadData()
        }
        
        self.updateHeight()
        self.dataManager?.checkPrivacy(nil)
        self.tableView.setContentOffset(.zero, animated: true)
    }
    
    func didBeginEditing(_ section: Int) {
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
        self.tableView.contentInset = edgeInsets
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .middle, animated: true)
    }
    
    func updateHeight() {
        let newHeight = self.dataManager?.heightForCurrentPage() ?? 0
        let currentHeight = self.contentView.frame.size.height
        
        if newHeight != currentHeight {
            self.contentHeight.constant = newHeight
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - Privacy
    
    func updatePrivacy(enabled: Bool, height: CGFloat, warning: String?, text: String?, checked: Bool) {
        if enabled {
            privacyView?.fillPrivacy(campaign?.privacy?.type ?? "", checked: checked)
            privacyView?.fillTexts(text ?? "", warning: warning ?? "")
            privacyView?.frame = .init(origin: .zero, size: .init(width: campaign?.type == .popup ? UIScreen.main.bounds.width-48 : UIScreen.main.bounds.width,
                                                                  height: height))
        }
        DispatchQueue.main.async {
            self.createFooter(withPrivacy: enabled)
        }
    }
    
    //MARK: - Autorotate
    
    open override var shouldAutorotate: Bool {
        return rotateToggle
    }
}

extension CampaignViewController: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        let photosCount = PHAsset.fetchAssets(with: .image, options: nil).count
        if photosCount > 0 {
            //            DispatchQueue.main.async(execute: self.showGalleryTask!)
        }
    }
}

extension CampaignViewController: PrivacyDelegate {
    func checked(_ value: Bool?) {
        dataManager?.checkPrivacy(value)
    }
    
    func tapPrivacy() {
        dataManager?.tapPrivacy()
    }
}

extension CampaignViewController: RouterDelegate {
    private func buildQuery(_ data: Dictionary<String, Any>) -> String {
        var output: String = ""
        for (key,value) in data {
            output +=  "\(key)=\(value)&"
        }
        output = String(output.dropLast()).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if output.count > 0 {
            output = "?\(output)"
        }
        return output
    }
    
    func openUrl(_ urlString: String, params: TransformQueryParameter?) {
        var queryDict: [String: Any] = [:]
        let systemParams = StatisticManager.getDeviceInfo()
        let userParams = properties
        
        for param in params?.system ?? [] {
            if let sParam = systemParams[param] {
                queryDict[param] = sParam
            } else {
                queryDict[param] = "nodata"
            }
        }
        
        for param in params?.user ?? [] {
            if let uParam = userParams[param] {
                queryDict[param] = uParam
            } else {
                queryDict[param] = "nodata"
            }
        }
        
        let queryParams = buildQuery(queryDict)
        let resultUrl = urlString + queryParams
        
        if let url = URL(string: resultUrl),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
