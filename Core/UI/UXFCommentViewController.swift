//
//  UXFCommentViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 31.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

class UXFCommentViewController: UXFViewController{
    
    @IBOutlet var textInput: UXFTextField!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var skipButton: UIButton!
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var sendButtonCenterConstraint: NSLayoutConstraint!
    @IBOutlet var sendButtonTrailingConstraint: NSLayoutConstraint!
    
    var isMandatoryField:Bool  = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        alertLabel.text = ""
        //sendButton.isEnabled = !mandatoryField
        
        skipButton.isHidden = isMandatoryField
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(commentDidChanged),
                                               name: UITextField.textDidChangeNotification,
                                               object: nil)
    }
    
    @objc private func commentDidChanged(){
        //sendButton.isEnabled = (textInput.text?.count ?? 0 > 0)
        textInput.inputState = textInput.text?.count ?? 0 > 0 ? .input : .normal
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        sendButtonCenterConstraint.isActive = isMandatoryField
        sendButtonTrailingConstraint.isActive = !isMandatoryField
    }

    @IBAction func sendButtonTap(_ sender: UIButton){
        if isMandatoryField == false || textInput.text?.count ?? 0 > 0{
             nextHandler?()
        }
        else{
            if isMandatoryField{
                textInput.inputState = .alert
                alertLabel.text = "Комментарий обязателен. Без него\nмы не узнаем, как стать лучше"
            }
            else {
                alertLabel.text = ""
            }
        }
    }
    
    @IBAction func skipButtonTap(_ sender: UIButton){
        nextHandler?()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
