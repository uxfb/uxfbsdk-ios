//
//  UXFViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 22.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import CocoaLumberjack

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

class UXFViewController: UIViewController{
    
    @IBOutlet var progressLabel: UILabel?
    @IBOutlet var bottomOffset: NSLayoutConstraint?
    @IBOutlet var heightConstraint: NSLayoutConstraint?
    
    static let defaulViewOffset: CGFloat = 8.0
    static let animationTime = 0.5
    
    var state:UXFViewControllerState = .presenting
    
    internal var theme: UXFTheme?
    var progressString: String = ""
    var presentationAnimated = true
    
    var didLoadHandler: (()->())?
    var didCloseHandler: (()->(Void))?
    var nextHandler: (()->())?
    var backHandler: (()->())?
    
    var presentDirection: UXFViewPopupDirection = .leftToRight
    var dismissDirection: UXFViewPopupDirection = .upToDown
    var backDirection: UXFViewPopupDirection = .alphaOut
    
    @IBOutlet  var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.progressLabel?.text = self.progressString
        contentView?.layer.cornerRadius = 8.0
        contentView?.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.24).cgColor
        contentView?.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView?.layer.shadowRadius = 6
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UITextField.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide),
                                               name: UITextField.keyboardDidHideNotification,
                                               object: nil)
        
        didLoadHandler?()
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
        backHandler?()
    }
    
    @IBAction  func closeButtonDidTap(_ sender: UIButton){
        close(animated:presentationAnimated)
    }
    
    func remove(animated: Bool, completion: (()->(Void))?){
        self.dismiss(animated: animated, completion: completion)
    }
    
    func close(animated: Bool = false){
        state = .closeDismiss
        self.remove(animated: presentationAnimated, completion: didCloseHandler)
        didCloseHandler = nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        DDLogDebug(String(describing: self) + "." + #function)
    }
}
