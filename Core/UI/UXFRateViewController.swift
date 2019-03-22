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
        let buttonsCount = 5
        for smile in _theme.smiles {
            let button = UXFButton.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
            button.imageView?.image = nil
            self.rateView.addSubview(button)
        }
       
    }

    
    func rateButtonTap(_ sender: UIButton){
        
    }

}
