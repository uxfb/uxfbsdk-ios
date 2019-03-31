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
    //@IBOutlet var lertHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        alertLabel.text = ""
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(commentDidChanged),
                                               name: UITextField.textDidChangeNotification,
                                               object: nil)
    }
    
    @objc private func commentDidChanged(){
        sendButton.isEnabled = (textInput.text?.count ?? 0 > 0)
    }

    @IBAction func sendButtonTap(_ sender: UIButton){
        nextHandler?()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
