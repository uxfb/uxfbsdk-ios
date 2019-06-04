//
//  UXFViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 22.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

enum UXFViewPopupDirection{
    case rightToLeft
    case leftToRight
    case upToDown
    case downToUp
    case alphaIn
    case alphaOut
}

enum UXFViewControllerState{
    case presenting
    case presented
    case outDismiss
    case closeDismiss
}

open class UXFViewController: UIViewController{
    
    @IBOutlet var backButton: UIButton?
    @IBOutlet var progressLabel: UILabel?
    @IBOutlet var bottomOffset: NSLayoutConstraint?
    @IBOutlet var heightConstraint: NSLayoutConstraint?
    @IBOutlet var logoImageView: UIImageView?
    @IBOutlet var closeButton: UIButton?
    
    static let defaulViewOffset: CGFloat = 8.0
    static let animationTime = 0.5
    
    private (set) var formIndex: Int = 0
    private (set) var formID: String?
    var state:UXFViewControllerState = .presenting
    
    internal weak var theme: UXFTheme?
    var progressString: String = ""
    var presentationAnimated = true
    
    var didLoadHandler: ((_ formIndex: Int)->())?
    var didCloseHandler: ((_ formIndex: Int)->(Void))?
    var willCloseHandler: ((_ formIndex: Int)->(Void))?
    var nextHandler: ((_ formIndex: Int, _ info: Dictionary<String, Any>?)->())?
    var backHandler: ((_ formIndex: Int)->())?
    
    var presentDirection: UXFViewPopupDirection = .leftToRight
    var dismissDirection: UXFViewPopupDirection = .upToDown
    var backDirection: UXFViewPopupDirection = .alphaOut
    
    @IBOutlet  var contentView: UIView!
    
    
    convenience init(index: Int = 0, formID: String?) {
        let bundle = Bundle(for: UXFeedback.self)
        self.init(nibName: "UXFViewController", bundle: bundle)
        self.formIndex = index
        self.formID = formID
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
      
        self.backButton?.isHidden = true

        #if DEBUG
            self.backButton?.isHidden = false
        #endif
        
        if self.formIndex > 0 {
            self.logoImageView?.isHidden  = true
        }
        
        if self.progressLabel != nil, self.theme != nil {
           self.progressLabel?.font = UIFont.init(name: self.theme!.fontRegularName,
                                                  size: self.progressLabel!.font.pointSize)
        }
        
        
        let bundle = Bundle(for: UXFeedback.self)

        var closeImage = UIImage.init(named: "close_image", in: bundle, compatibleWith: nil)
        var backImage = UIImage.init(named: "back_arrow", in: bundle, compatibleWith: nil)
        let logoImage =  UIImage.init(named: "logo_small", in: bundle, compatibleWith: nil)
        if let controlColor = theme?.controlColor {
            backImage = backImage?.tint(with: controlColor)
            closeImage = closeImage?.tint(with: controlColor)
        }
        closeButton?.setImage(closeImage, for: .normal)
        backButton?.setImage(backImage, for: .normal)
        logoImageView?.image = logoImage
        
        self.progressLabel?.textColor = theme?.progressColor
        self.progressLabel?.text = self.progressString
        contentView?.layer.cornerRadius = theme?.formRadius ?? 8.0
        contentView?.layer.masksToBounds = false
        contentView?.clipsToBounds = false
        
        contentView?.layer.shadowRadius = 6
        contentView?.layer.shadowOffset = CGSize.init(width: 0, height: 8)
        contentView?.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.24).cgColor
        contentView?.layer.shadowOpacity = 1.0
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UITextField.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide),
                                               name: UITextField.keyboardDidHideNotification,
                                               object: nil)
        
        didLoadHandler?(self.formIndex)
        self.state = .presented
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
      
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            bottomOffset?.constant = UXFViewController.defaulViewOffset + keyboardHeight
            UIView.animate(withDuration: UXFViewController.animationTime){ [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardDidHide(){
        bottomOffset?.constant = UXFViewController.defaulViewOffset
        UIView.animate(withDuration: UXFViewController.animationTime){ [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    //MARK: actions
    
    @IBAction func backButtonTap(_ sender: UIButton){
        state = .outDismiss
        backHandler?(self.formIndex)
    }
    
    @IBAction  func closeButtonDidTap(_ sender: UIButton){
        state = .closeDismiss
        self.dismiss(animated: presentationAnimated, completion: nil)
    }
    
    override open func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.willCloseHandler?(self.formIndex)
        super.dismiss(animated: presentationAnimated) { [weak self] in
            if let index = self?.formIndex{
                self?.didCloseHandler?(index)
            }
            self?.didCloseHandler = nil
            completion?()
        }
  
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        #if DEBUG
        print("deinit " + String(describing: self))
        #endif
    }
}
