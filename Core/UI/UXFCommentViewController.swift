//
//  UXFCommentViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 31.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

class UXFCommentViewController: UXFViewController{
    
    @IBOutlet var textInput: UITextField!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var alertLabel: UILabel!
    var isMandatoryField:Bool  = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        alertLabel.text = ""
        //sendButton.isEnabled = !mandatoryField
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(commentDidChanged),
                                               name: UITextField.textDidChangeNotification,
                                               object: nil)
    }
    
    @objc private func commentDidChanged(){
        sendButton.isEnabled = (textInput.text?.count ?? 0 > 0)
    }

    @IBAction func sendButtonTap(_ sender: UIButton){
        if isMandatoryField == false || textInput.text?.count ?? 0 > 0{
             nextHandler?()
        }
        else{
            if isMandatoryField{
                alertLabel.text = "Комментарий обязателен. Без него\nмы не узнаем, как стать лучше"
            }
            else {
                alertLabel.text = ""
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
