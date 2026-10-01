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

internal class TableView: UITableView {
    override func layoutSubviews() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        super.layoutSubviews()
        CATransaction.commit()
    }
}

internal class CampaignViewController: UIViewController {
    
    //MARK: - Outlets
    lazy var contentView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = campaign?.theme.bgColor ?? .white
        return view
    }()
    
    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = campaign?.theme.text03Color ?? .lightGray
        label.textAlignment = .center
        return label
    }()
    
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close_image", in: Consts.bundle, compatibleWith: nil)?.tint(with: campaign?.theme.iconColor ?? .lightGray), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var privacyView: PrivacyView = {
        let view = PrivacyView(theme: campaign!.theme, delegate: self)
        view.frame = .init(x: 0, y: 0, width: 100, height: 100)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var copyrightView: UIView = {
        let view = UIView()
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        var urlString: String?
        let scale = UIScreen.main.scale
        switch scale {
            case 1:
                urlString = campaign?.copyright?.image?["1x"] as? String
            case 2:
                urlString = campaign?.copyright?.image?["2x"] as? String
            case 3:
                urlString = campaign?.copyright?.image?["3x"] as? String
                
            default:
                break
        }
        image.image = UIImage(named: "logo", in: Consts.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        if let urlString = urlString, let url = URL(string: urlString) {
            image.cacheImage(url: url, withTemplate: true) { result in
                if !result {
                    image.image = UIImage(named: "logo", in: Consts.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                }
            }
        } else {
            image.image = UIImage(named: "logo", in: Consts.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        }
        
        image.tintColor = campaign?.theme.inputBorderColor
        
        view.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            image.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            image.heightAnchor.constraint(equalToConstant: 30),
            image.widthAnchor.constraint(equalToConstant: 30),
            image.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12)
        ])
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.addTarget(self, action: #selector(onLogoTap(tap:)))
        tapGestureRecognizer.delegate = self
        image.addGestureRecognizer(tapGestureRecognizer)
        image.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var holderView: UIView = {
        let view = UIView()
        view.backgroundColor = campaign?.theme.controlBgColor ?? .clear
        if campaign?.type == .slidein {
            view.heightAnchor.constraint(equalToConstant: dataManager?.safeSpace ?? 0).isActive = true
        } else {
            view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        }
        return view
    }()
    
    lazy var footerView: UIView = {
        let view = UIView(frame: .zero)
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.addArrangedSubview(copyrightView)
        stackView.addArrangedSubview(privacyView)
        stackView.addArrangedSubview(holderView)

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }()
    
    lazy var tableView: TableView = {
        var view: TableView!
        if #available(iOS 13.0, *) {
            view = TableView(frame: .zero, style: .grouped)
        } else {
            view = TableView(frame: .zero, style: .grouped)
        }
        
        if #available(iOS 15.0, *) {
            view.sectionHeaderTopPadding = .leastNonzeroMagnitude
        }
        
        view.delaysContentTouches = false
        view.tableHeaderView = UIView(frame: .zero)
        view.delegate = self
        view.dataSource = self
        view.allowsSelection = false
        view.delaysContentTouches = false
        view.backgroundColor = campaign?.theme.bgColor ?? .white
        view.separatorStyle = .none
        view.separatorColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.bounces = false
        view.backgroundColor = .white
        view.register(ButtonCell.self,
                      forCellReuseIdentifier: String(describing: ButtonCell.self))
        view.register(StarsCell.self,
                      forCellReuseIdentifier: String(describing: StarsCell.self))
        view.register(SmilesCell.self,
                      forCellReuseIdentifier: String(describing: SmilesCell.self))
        view.register(InputCell.self,
                      forCellReuseIdentifier: String(describing: InputCell.self))
        view.register(HeaderCell.self,
                      forCellReuseIdentifier: String(describing: HeaderCell.self))
        view.register(TextCell.self,
                      forCellReuseIdentifier: String(describing: TextCell.self))
        view.register(EmailCell.self,
                      forCellReuseIdentifier: String(describing: EmailCell.self))
        view.register(ImageCell.self,
                      forCellReuseIdentifier: String(describing: ImageCell.self))
        view.register(CheckboxCell.self,
                      forCellReuseIdentifier: String(describing: CheckboxCell.self))
        view.register(RadiobuttonCell.self,
                      forCellReuseIdentifier: String(describing: RadiobuttonCell.self))
        view.register(NpsCell.self,
                      forCellReuseIdentifier: String(describing: NpsCell.self))
        view.register(RatingCell.self,
                      forCellReuseIdentifier: String(describing: RatingCell.self))
        view.register(ScreenshotCell.self,
                      forCellReuseIdentifier: String(describing: ScreenshotCell.self))
        
        view.contentInset = .zero
        
        return view
    }()
    
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = campaign?.theme.bgColor ?? .white
        return view
    }()
    
    var contentHeight: NSLayoutConstraint = NSLayoutConstraint()
    var verticallyConstraint: NSLayoutConstraint!
    var leftConstraint: NSLayoutConstraint!
    var rightConstraint: NSLayoutConstraint!
    var bottomConstraint: NSLayoutConstraint!
    var tableViewBottomConstraint: NSLayoutConstraint!
    var titleViewHeightConstaint: NSLayoutConstraint!
    
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
    
    var isHalf: Bool = true
    
    var rotateToggle: Bool = false
    
    var properties: [String: Any] = [:]
    
    internal var campaign: Campaign?
    
    private var direction: CGFloat = 0
    private var lastTouch: CGFloat = 0
    
    private var dataManager: DataManager?
    
    var withKeyboard = false
    
    private var offsetBeforeEditing: CGPoint = .zero
    
    override func loadView() {
        self.view = PassthroughToWindowView()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        dataManager = DataManager(self, campaign: campaign)
        
        createViews()
        
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(headerImageDidLoad),
                                               name: .headerImageDidLoad,
                                               object: nil)
        
        self.updateFooter()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        withKeyboard = true
        
        guard
            let userinfo = notification.userInfo,
            let duration = (userinfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let endFrame = (userinfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let curveOption = userinfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        offsetBeforeEditing = tableView.contentOffset
        
        let space = UIScreen.main.bounds.height - (self.dataManager?.heightForCurrentPage() ?? 0)
        if space > 240 {
            if campaign?.type == .popup {
                let diff = space / 2 - endFrame.height
                self.verticallyConstraint.constant = diff < 0 ? (diff + 40) : 0
            } else {
                self.bottomConstraint.constant = -endFrame.height + (self.dataManager?.safeSpace ?? 0)
            }
            
            UIView.animate(withDuration: duration, delay: 0) {
                self.view.layoutIfNeeded()
                self.tableView.contentInset = .zero
            }
        } else {
            
            let halfScreen = UIScreen.main.bounds.height / 2
            
            let halfContent = (self.dataManager?.heightForCurrentPage() ?? 0) / 2
            
            let needsSpace = endFrame.height - (halfScreen - halfContent)
            
            UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .init(rawValue: curveOption)], animations: {
                
                let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: needsSpace, right: 0)
                self.tableView.contentInset = edgeInsets
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        withKeyboard = false
        
        guard let userinfo = notification.userInfo else {
            return
        }
        
        guard
            let duration = (userinfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curveOption = userinfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        if campaign?.type == .popup {
            self.verticallyConstraint.constant = 0
        } else {
            self.bottomConstraint.constant = 0
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .init(rawValue: curveOption)]) {
            self.view.layoutIfNeeded()
            self.tableView.contentInset = UIEdgeInsets.zero
            self.tableView.contentOffset = self.offsetBeforeEditing
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadTableView()
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
                self.reloadTableView()
            }
        }
    }
    
    @objc private func rotated() {
        DispatchQueue.main.async {
            if let effectView = self.view.viewWithTag(visualEffectViewTag) {
                effectView.frame = UIScreen.main.bounds
            }
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
                // Animation in progress
            }, completion: { _ in
                NotificationCenter.default.post(name: NSNotification.Name("Rotated"), object: nil)
            })
    }
    
    //MARK: - Support
    
    private func updateFooterWithDynamicContent(fromCreate: Bool = false) {
        guard let footerView = tableView.tableFooterView else { return }
    
        footerView.layoutIfNeeded()
        let newSize = footerView.systemLayoutSizeFitting(
            CGSize(width: self.tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        UIView.performWithoutAnimation {
            let oldFooterHeight = self.tableView.tableFooterView?.frame.height ?? 0
            
            footerView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: newSize.height)
            
            self.tableView.tableFooterView = footerView
            
            
            if !fromCreate {
                let footerHeight = self.tableView.tableFooterView?.frame.height ?? 0
                let contentHeight = self.tableView.contentSize.height
                let tableViewHeight = self.tableView.frame.height
                
                let offsetY = max(-self.tableView.contentInset.top, contentHeight + footerHeight - tableViewHeight)
                if newSize.height != oldFooterHeight {
                    self.tableView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
                }
            }
        }
    }
    
    func updateFooter() {
        let withPrivacy = dataManager?.privacyNeeded ?? false
        let withCopyright = campaign?.copyright?.isShow ?? false
        copyrightView.isHidden = !withCopyright
        privacyView.isHidden = !withPrivacy
        holderView.isHidden = false
        holderView.backgroundColor = withPrivacy ? campaign?.theme.controlBgColor : campaign?.theme.bgColor
        if campaign?.type == .popup {
            holderView.heightAnchor.constraint(equalToConstant: (copyrightView.isHidden && privacyView.isHidden) ? 32 : 0).isActive = true
        }

        if withPrivacy {
            privacyView.preparePrivacy(campaign?.privacy?.type ?? "")
        }
        updateFooterWithDynamicContent(fromCreate: true)

        contentHeight.constant = dataManager?.heightForCurrentPage() ?? 0
    }
    
    func createFooter(withPrivacy: Bool) {
        copyrightView.isHidden = !(campaign?.copyright?.isShow ?? false)
        privacyView.isHidden = !withPrivacy
        holderView.backgroundColor = withPrivacy ? campaign?.theme.controlBgColor : campaign?.theme.bgColor
        if withPrivacy {
            privacyView.preparePrivacy(campaign?.privacy?.type ?? "")
        }
        
        if campaign?.type == .popup {
            holderView.heightAnchor.constraint(equalToConstant: (copyrightView.isHidden && privacyView.isHidden) ? 32 : 0).isActive = true
        }
        
        tableView.tableFooterView = footerView
        updateFooterWithDynamicContent(fromCreate: true)
    }
    
    private static let sectionFooterReuseId = "SectionFooterView"

    private func createViews() {
        topView.addSubview(progressLabel)
        topView.addSubview(closeButton)
        contentView.addSubview(topView)
        contentView.addSubview(tableView)
        view.addSubview(shadowView)
        view.addSubview(contentView)

        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: Self.sectionFooterReuseId)

        createFooter(withPrivacy: dataManager?.privacyNeeded ?? false)
        
        if presentHandler != nil {
            presentHandler!()
        }
        if let progress = campaign?.progress, progress {
            progressLabel.isHidden = false
        } else {
            progressLabel.isHidden = true
        }
        
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        topView.translatesAutoresizingMaskIntoConstraints = false
        
        contentHeight = NSLayoutConstraint(item: contentView,
                                           attribute: .height,
                                           relatedBy: .equal,
                                           toItem: nil,
                                           attribute: .height,
                                           multiplier: 1,
                                           constant: 380)
        
        verticallyConstraint = NSLayoutConstraint(item: contentView,
                                                  attribute: .centerY,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: .centerY,
                                                  multiplier: 1,
                                                  constant: 0)
        leftConstraint = NSLayoutConstraint(item: contentView,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: view.safeAreaLayoutGuide,
                                            attribute: .leading,
                                            multiplier: 1,
                                            constant: 0)
        rightConstraint = NSLayoutConstraint(item: view.safeAreaLayoutGuide,
                                             attribute: .trailing,
                                             relatedBy: .equal,
                                             toItem: contentView,
                                             attribute: .trailing,
                                             multiplier: 1,
                                             constant: 0)
        bottomConstraint = NSLayoutConstraint(item: contentView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 0)
        tableViewBottomConstraint = NSLayoutConstraint(item: tableView,
                                                       attribute: .bottom,
                                                       relatedBy: .equal,
                                                       toItem: contentView,
                                                       attribute: .bottom,
                                                       multiplier: 1,
                                                       constant: 0)
        titleViewHeightConstaint = NSLayoutConstraint(item: topView,
                                                      attribute: .height,
                                                      relatedBy: .equal,
                                                      toItem: nil,
                                                      attribute: .height,
                                                      multiplier: 1,
                                                      constant: 54)
        
        
        NSLayoutConstraint.activate([
            leftConstraint,
            rightConstraint,
            bottomConstraint,
            verticallyConstraint,
            contentHeight,
            
            shadowView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            shadowView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            shadowView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            shadowView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            
            topView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleViewHeightConstaint,
            
            closeButton.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -12),
            closeButton.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -6),
            closeButton.heightAnchor.constraint(equalToConstant: 36),
            closeButton.widthAnchor.constraint(equalToConstant: 36),

            progressLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 44),
            progressLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -44),
            progressLabel.topAnchor.constraint(equalTo: topView.topAnchor),
            progressLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableViewBottomConstraint
        ])
        
        prepareUI()
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
    
    @objc
    private func closeButtonTapped() {
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
        if (campaign?.copyright?.href) != nil {
            href = (campaign?.copyright?.href)!
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
                    dataManager?.isHalfScreen = false
                    self.bottomConstraint.constant = 0
                    updateHeight()
                }
                
                UIView.animate(withDuration: 0.2) {
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating {
            dataManager?.isHalfScreen = false
            updateHeight()
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataManager?.heightForFieldHeader(index: section) ?? 12
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return dataManager?.heightForFieldHeader(index: section) ?? 12
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return dataManager?.heightForFieldFooter(index: section) ?? 12
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return dataManager?.viewForFieldHeader(index: section)
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let wrapper = tableView.dequeueReusableHeaderFooterView(withIdentifier: Self.sectionFooterReuseId)!
        configureSectionFooter(wrapper, for: section)
        return wrapper
    }

    private func configureSectionFooter(_ wrapper: UITableViewHeaderFooterView, for section: Int) {
        wrapper.contentView.subviews.forEach { $0.removeFromSuperview() }
        guard let content = dataManager?.viewForFieldFooter(index: section) else { return }
        content.translatesAutoresizingMaskIntoConstraints = false
        wrapper.contentView.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: wrapper.contentView.topAnchor),
            content.bottomAnchor.constraint(equalTo: wrapper.contentView.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: wrapper.contentView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: wrapper.contentView.trailingAnchor),
        ])
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    private func reloadTableView() {
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
        }
        
//        CATransaction.commit()
    }
    
    func scrollToTop(animated: Bool) {
        self.tableView.setContentOffset(.zero, animated: animated)
    }
    
    func updateField(idx: Int) {
        if let label = view.viewWithTag(idx) as? UILabel {
            label.text = ""
        }
        
        var indexSet = IndexSet(integersIn: 0..<self.tableView.numberOfSections)
        indexSet.remove(idx)
        
        reloadTableView()
        self.updateHeight()
    }
    
    func updateUI(_ sender: Int? = nil) {
        self.progressLabel.text = dataManager?.progress
        if let progress = campaign?.progress, progress {
            self.progressLabel.isHidden = dataManager?.isProgressHidden ?? true
        }

        if let sender = sender {
            let savedOffset = withKeyboard ? tableView.contentOffset : nil

            let newCount = dataManager?.fieldsCount() ?? 0
            let oldCount = tableView.numberOfSections

            UIView.performWithoutAnimation {
                tableView.beginUpdates()

                // Синхронизируем количество секций
                if newCount > oldCount {
                    tableView.insertSections(IndexSet(integersIn: oldCount..<newCount), with: .none)
                } else if newCount < oldCount {
                    tableView.deleteSections(IndexSet(integersIn: newCount..<oldCount), with: .none)
                }

                let senderField = dataManager?.fieldForRow(indexPath: IndexPath(row: 0, section: sender))
                let forceReloadSender = senderField?.type == .screenshot
                let sectionsToReload = IndexSet(
                    (0..<min(oldCount, newCount)).filter { section in
                        if section == sender { return forceReloadSender }
                        let oldRows = tableView.numberOfRows(inSection: section)
                        let newRows = dataManager?.numberForFieldCell(index: section) ?? oldRows
                        return oldRows != newRows
                    }
                )
                if !sectionsToReload.isEmpty {
                    tableView.reloadSections(sectionsToReload, with: .none)
                }

                tableView.endUpdates()
            }

            // Обновляем footer секции sender
            if let footer = tableView.footerView(forSection: sender) {
                configureSectionFooter(footer, for: sender)
            }

            if let savedOffset = savedOffset {
                tableView.layoutIfNeeded()
                tableView.setContentOffset(savedOffset, animated: false)
            }
        } else {
            self.reloadTableView()
        }

        self.updateHeight()
    }
    
    func didBeginEditing(_ section: Int) {
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 180, right: 0)
        self.tableView.contentInset = edgeInsets
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
    }
    
    func refreshFieldFooter(_ section: Int) {
        UIView.performWithoutAnimation {
            if let footer = tableView.footerView(forSection: section) {
                configureSectionFooter(footer, for: section)
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    func didEndEditing(_ section: Int) {
//        self.tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .middle, animated: true)
    }
    
    @objc private func headerImageDidLoad() {
        reloadTableView()
        updateHeight()
    }
    
    func updateHeight() {
        let newHeight = (self.dataManager?.heightForCurrentPage() ?? 0).rounded()
        let currentHeight = self.contentView.frame.size.height.rounded()

        guard newHeight != currentHeight else { return }

        self.contentHeight.constant = newHeight

        UIView.animate(withDuration: 0.2) {
            self.contentView.layoutIfNeeded()
        }
    }
    
    //MARK: - Privacy
    
    func updatePrivacy(enabled: Bool, warning: String?, text: String?, checked: Bool) {
        if enabled {
            self.privacyView.fillPrivacy(self.campaign?.privacy?.type ?? "", checked: checked)
            self.privacyView.fillTexts(text ?? "", warning: warning ?? "")
        }

        let dispatchWorkItem = {
            self.updateFooterWithDynamicContent(fromCreate: self.dataManager?.isHalfScreen ?? false)
            self.contentHeight.constant = self.dataManager?.heightForCurrentPage() ?? 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: dispatchWorkItem)
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
