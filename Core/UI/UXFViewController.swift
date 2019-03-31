//
//  UXFViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 22.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import CocoaLumberjack

class UXFViewController: UIViewController{
    
    @IBOutlet var progressLabel: UILabel?
    @IBOutlet var bottomOffset: NSLayoutConstraint?
    
    static let defaulViewOffset: CGFloat = 8.0
    static let animationTime = 0.5
    
    internal var theme: UXFTheme?
    var presentationAnimated = true
    var didCloseHandler: (()->(Void))?
    var nextHandler: (()->())?
    var backHandler: (()->())?
    
    @IBOutlet  var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        backHandler?()
    }
    
    @IBAction  func closeButtonDidTap(_ sender: UIButton){
        close(animated:presentationAnimated)
    }
    
    func remove(animated: Bool, completion: (()->(Void))?){
        self.dismiss(animated: animated, completion: completion)
    }
    
    func close(animated: Bool = false){
        self.remove(animated: presentationAnimated, completion: didCloseHandler)
        didCloseHandler = nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        DDLogDebug(String(describing: self) + "." + #function)
    }
}
