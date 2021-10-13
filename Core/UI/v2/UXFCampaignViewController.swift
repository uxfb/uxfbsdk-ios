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

enum UXFViewPopupDirection{
    case upToDown
    case downToUp
    case alphaIn
    case alphaOut
}

enum UXFViewControllerState{
    case presenting
    case presented
    case backDismiss
    case dismissOnly
}

open class UXFCampaignViewController: UIViewController {

    @IBOutlet var contentView: UIView!
    @IBOutlet var shadowView: AnimatingShadowView! {
        didSet {
            shadowView.backgroundColor = campaign?.theme.bgColor ?? .white
        }
    }
    @IBOutlet var progressLabel: UILabel! {
        didSet {
            progressLabel.text = ""
            progressLabel.textColor = campaign?.theme.iconColor ?? .lightGray
        }
    }
    
    @IBOutlet var closeButton: UIButton! {
        didSet {
            let bundle = Bundle(for: UXFeedback.self)
            closeButton.setImage(UIImage(named: "close_image", in: bundle, compatibleWith: nil)?.tint(with: campaign?.theme.iconColor ?? .lightGray), for: .normal)
        }
    }
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            configureTableView()
        }
    }
    
    @IBOutlet var topView: UIView! {
        didSet {
            topView.backgroundColor = .clear
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
    private (set) var formIndex: Int = 0
    
    
    var state: UXFViewControllerState = .presenting
    var blackout: UXFBBlackout?
    
    var didLoadHandler: ((_ formIndex: Int)->())?
    var didCloseHandler: ((_ formIndex: Int)->(Void))?
    var willCloseHandler: ((_ formIndex: Int)->(Void))?
    var backHandler: ((_ formIndex: Int)->())?
    
    var completeHandler: ((_ formIndex: Int, _ info: Array<Dictionary<String, Any>>?, _ screenshots: [UXFScreenshot])->())?
    
    var presentHandler: (()->())?
    
    var presentDirection: UXFViewPopupDirection = .downToUp
    var dismissDirection: UXFViewPopupDirection = .upToDown
    
    var closeOnSwipe: Bool = false
    
    internal var campaign: UXFCampaign?
    
    private var direction: CGFloat = 0
    private var lastTouch: CGFloat = 0
    
    private var dataManager: UXFDataManager?
    
    var keyboardHeight: CGFloat = 0
    
    private var showGalleryTask: DispatchWorkItem?
    
    convenience init() {
        let bundle = Bundle(for: UXFeedback.self)
        self.init(nibName: String(describing: type(of: self)), bundle: bundle)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        dataManager = UXFDataManager(self, campaign: campaign)
        prepareUI()
        
        if presentHandler != nil {
            presentHandler!()
        }
        
        if (campaign?.transforms.count ?? 0) > 0 {
            progressLabel.isHidden = true
        }
            
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            
            switch campaign?.type {
            case .popup:
                self.verticallyConstraint.constant = -keyboardHeight/2
                break
            case .slidein:
                self.bottomConstraint.constant = -keyboardHeight
                break
            default:
                break
            }
            
            self.view.layoutIfNeeded()
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0
        if self.bottomConstraint.constant != 0 {
            self.bottomConstraint.constant = 0
        }
        if self.verticallyConstraint.constant != 0 {
            self.verticallyConstraint.constant = 0
        }
        
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    open override func viewDidLayoutSubviews() {
        updateLayouts()
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView.reloadData()
    }

    //MARK: - Support
    
    private func configureTableView() {
        let bundle = Bundle(for: UXFeedback.self)
        let tableFooterView = UIView(frame: CGRect(origin: .zero,
                                                   size: CGSize(width: UIScreen.main.bounds.width,
                                                                height: 50)))
        let image = UIImageView(frame: CGRect(origin: CGPoint(x: 0,
                                                              y: 16),
                                              size: CGSize(width: 30,
                                                           height: 22)))
        image.image = UIImage(named: "uxf", in: bundle, compatibleWith: nil)
        tableFooterView.backgroundColor = campaign?.theme.bgColor ?? .white
        tableFooterView.addSubview(image)
        tableView.tableFooterView = tableFooterView
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero,
                                                         size: CGSize(width: 1,
                                                                      height: 1)))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.delaysContentTouches = false
        tableView.backgroundColor = campaign?.theme.bgColor ?? .white
        
        tableView.register(UINib(nibName: "UXFButtonCell",
                                 bundle: bundle),
                           forCellReuseIdentifier: "UXFButtonCell")
        tableView.register(UINib(nibName: "UXFSmilesCell",
                                 bundle: bundle),
                           forCellReuseIdentifier: "UXFSmilesCell")
        tableView.register(UINib(nibName: "UXFStarsCell",
                                 bundle: bundle),
                           forCellReuseIdentifier: "UXFStarsCell")
        tableView.register(UINib(nibName: "UXFCheckboxCell",
                                 bundle: bundle),
                           forCellReuseIdentifier: "UXFCheckboxCell")
        tableView.register(UINib(nibName: "UXFEmailCell",
                                 bundle: bundle),
                           forCellReuseIdentifier: "UXFEmailCell")
        tableView.register(UINib(nibName: "UXFHeaderCell",
                                 bundle: bundle),
                           forCellReuseIdentifier: "UXFHeaderCell")
        tableView.register(UINib(nibName: "UXFImageCell",
                                 bundle: bundle),
                           forCellReuseIdentifier: "UXFImageCell")
        tableView.register(UINib(nibName: "UXFInputCell",
                                 bundle: bundle),
                           forCellReuseIdentifier: "UXFInputCell")
        tableView.register(UINib(nibName: "UXFRadiobuttonCell",
                                 bundle: bundle),
                           forCellReuseIdentifier: "UXFRadiobuttonCell")
        tableView.register(UINib(nibName: "UXFTextCell",
                                 bundle: bundle),
                           forCellReuseIdentifier: "UXFTextCell")
        tableView.register(UINib(nibName: "UXFNpsCell",
                                 bundle: bundle),
                           forCellReuseIdentifier: "UXFNpsCell")
        tableView.register(UINib(nibName: "UXFScreenshotCell",
                                 bundle: bundle),
                           forCellReuseIdentifier: "UXFScreenshotCell")
    }
    
    private func prepareUI() {
        self.progressLabel.text = dataManager?.progress
        contentView.backgroundColor = campaign?.theme.bgColor ?? .white
        tableView.backgroundColor = campaign?.theme.bgColor ?? .white
        contentHeight.constant = dataManager?.heightForCurrentPage() ?? 0
        
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
        dataManager?.endCampaign()
//         self.dismiss(animated: presentationAnimated)
    }
    
    override open func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.willCloseHandler?(self.formIndex)
        
        super.dismiss(animated: presentationAnimated) { [weak self] in
            if let index = self?.formIndex{
                self?.didCloseHandler?(index)
            }
            self?.didCloseHandler = nil
            
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
    
    @objc func onTap(tap: UITapGestureRecognizer) -> Void {
        view.endEditing(true)
        self.bottomConstraint.constant = 0

        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func onPan(pan: UIPanGestureRecognizer) -> Void {
        view.endEditing(true)
//        let endPoint = pan.translation(in: pan.view?.superview)
        
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
                    self.dismiss(animated: presentationAnimated)
                } else {
                    if self.bottomConstraint.constant == sheetY {
                        self.dismiss(animated: presentationAnimated)
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

extension UXFCampaignViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIButton)
    }
}

extension UXFCampaignViewController: UITableViewDataSource, UITableViewDelegate {
    
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
            let cell = createCell(UXFButtonCell.self, indexPath: indexPath, field: field, theme: (campaign?.theme)!, delegate: dataManager!)
            return cell
        
        case .smiles:
            let cell = createCell(UXFSmilesCell.self, indexPath: indexPath, field: field, theme: (campaign?.theme)!, delegate: dataManager!)
            return cell
            
        case .checkbox:
            let cell = createCell(UXFCheckboxCell.self, indexPath: indexPath, field: field, theme: (campaign?.theme)!, delegate: dataManager!)
            return cell
            
        case .email:
            let cell = createCell(UXFEmailCell.self, indexPath: indexPath, field: field, theme: (campaign?.theme)!, delegate: dataManager!)
            return cell
            
        case .header:
            let cell = createCell(UXFHeaderCell.self, indexPath: indexPath, field: field, theme: (campaign?.theme)!, delegate: dataManager!)
            return cell
            
        case .image:
            let cell = createCell(UXFImageCell.self, indexPath: indexPath, field: field, theme: (campaign?.theme)!, delegate: dataManager!)
            return cell
            
        case .input:
            let cell = createCell(UXFInputCell.self, indexPath: indexPath, field: field, theme: (campaign?.theme)!, delegate: dataManager!)
            return cell
            
        case .radiobutton:
            let cell = createCell(UXFRadiobuttonCell.self, indexPath: indexPath, field: field, theme: (campaign?.theme)!, delegate: dataManager!)
            return cell
            
        case .text:
            let cell = createCell(UXFTextCell.self, indexPath: indexPath, field: field, theme: (campaign?.theme)!, delegate: dataManager!)
            return cell
            
        case .stars:
            let cell = createCell(UXFStarsCell.self, indexPath: indexPath, field: field, theme: (campaign?.theme)!, delegate: dataManager!)
            return cell
            
        case .nps:
            let cell = createCell(UXFNpsCell.self, indexPath: indexPath, field: field, theme: (campaign?.theme)!, delegate: dataManager!)
            return cell
            
        case .screenshot:
            let cell = createCell(UXFScreenshotCell.self, indexPath: indexPath, field: field, theme: (campaign?.theme)!, delegate: dataManager!)
            cell.setScreenshots(dataManager?.screenshots ?? [])
            
            let takeTask = DispatchWorkItem {
                UIView.animate(withDuration: 0.15) {
                    self.view.alpha = 0
                } completion: { finish in
                    UXFImageManager.showScreenshotTake { images in
                        self.addScreenshots(images, type: .screenhot)
                    } closeAction: {
                        UIView.animate(withDuration: 0.15) {
                            self.view.alpha = 1
                        }
                    }
                }
            }
            
            showGalleryTask = DispatchWorkItem {
                let count = 3 - (self.dataManager?.screenshots.count ?? 0)
                guard  count > 0 else {
                    return
                }
                
                PHPhotoLibrary.shared().unregisterChangeObserver(self)
                UXFImageManager.showGallery(maxCount: count) { images in
                    self.addScreenshots(images, type: .gallery)
                }
            }
            let selectTask = DispatchWorkItem {
                self.checkGalleryPermissions { result in
                    if result {
                        DispatchQueue.main.async(execute: self.showGalleryTask!)
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
    
    private func addScreenshots(_ images: [UIImage], type: UXFScreenshotType) {
        var screenshots = dataManager?.screenshots
        for image in images {
            screenshots?.append(UXFScreenshot(id: .randomImageName, image: image, type: type))
        }
        dataManager?.screenshotChanged(screenshots: screenshots ?? [])
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
            self.showAlert(title: "Информация", message: "Нет доступа к фотографиям устройства", buttonTitle: "Закрыть")
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
            let alert = UIAlertController(title: "\"\(appName)\" хочет получить доступ к вашим фотографиям", message: "Доступ не предоставлен ни к одной фотографии", preferredStyle: .alert)
            let openPhotoAccessAction = UIAlertAction(title: "Изменить выбор", style: .default) { alertAction in
                alert.dismiss(animated: true, completion: nil)
                
                if #available(iOS 14, *) {
                    PHPhotoLibrary.shared().register(self)
                    PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
                }
            }
            let closeAction = UIAlertAction(title: "Закрыть", style: .default) { alertAction in
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
            let alert = UIAlertController(title: "\"\(appName)\" хочет получить доступ к вашим фотографиям", message: "Перейдите в настройки, чтобы разрешить доступ", preferredStyle: .alert)
            let openSettingsAction = UIAlertAction(title: "Открыть настройки", style: .default) { alertAction in
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
    
    private func createCell<T: UXFBaseCell>(_ type: T.Type, indexPath: IndexPath, field: UXFField, theme: UXFBTheme, delegate: UXFFieldDelegate) -> T {
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
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        
        self.updateHeight()
    }
    
    func updateUI() {
//        self.view.endEditing(true)
        self.progressLabel.text = dataManager?.progress
        self.tableView.reloadData()
        
        self.updateHeight()
    }
    
    func updateHeight() {
        let newHeight = self.dataManager?.heightForCurrentPage() ?? 0
        let currentHeight = self.contentView.frame.size.height
        
        if newHeight != currentHeight {
            self.contentHeight.constant = newHeight
            self.view.layoutIfNeeded()
        }
    }
}

extension UXFCampaignViewController: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        let photosCount = PHAsset.fetchAssets(with: .image, options: nil).count
        if photosCount > 0 {
            DispatchQueue.main.async(execute: self.showGalleryTask!)
        }
    }
}
