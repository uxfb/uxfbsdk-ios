//
//  UXFRateViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 21.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//


import UIKit

class UXFRateViewController: UXFViewController {
    
    @IBOutlet var rateView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (_theme != nil) {
            var buttonIndex = 0
            for smile in _theme!.smiles {
                let button = UXFButton.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
                button.imageView?.image = nil
                button.tag = buttonIndex
                button.backgroundColor = UIColor.lightGray
                button.addTarget(self, action: #selector(rateButtonTap), for: .touchUpInside)
                self.rateView.addSubview(button)
                buttonIndex += 1
            }
        }
      
    }

    
    @objc func rateButtonTap(_ sender: UIButton){
        
    }

}
