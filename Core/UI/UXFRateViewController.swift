//
//  UXFRateViewController.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 21.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//


import UIKit
import CoreGraphics

class UXFRateViewController: UXFViewController {
    
    @IBOutlet var rateView: UIStackView!
    @IBOutlet var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (theme != nil) {
            let smilesCount = theme!.smiles.count
            for buttonIndex in 0..<smilesCount{
                let layoutButtonsView = self.rateView as UIView
                var buttonWidth = layoutButtonsView.bounds.size.width/CGFloat(smilesCount)
                let buttonHeight = self.rateView.bounds.size.height
                if buttonWidth > buttonHeight{
                    buttonWidth = buttonHeight
                }
                let button = UXFButton.init(frame: CGRect.init(x: 0,
                                                               y: 0,
                                                               width: buttonWidth,
                                                               height: buttonHeight))
                theme?.getSmile(index: buttonIndex, completion: { (image) in
                    button.setImage(image, for: UIControl.State.normal)
                })
                
                button.tag = buttonIndex
                button.addTarget(self, action: #selector(rateButtonTap), for: .touchUpInside)
                self.rateView.addArrangedSubview(button)
            }
        }
      
    }
    
    @objc func rateButtonTap(_ sender: UIButton){
        nextHandler?()
    }

}
