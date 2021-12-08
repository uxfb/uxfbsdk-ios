//
//  UXFSmilesCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class UXFSmilesCell: UXFBaseCell {
    
    private var animationInProgress: Bool = false
    private var currentValue: Int = -1
    
    override func updateUI() {
        currentValue = Int(field?.answers.first ?? "") ?? -1
        
        let color = (field!.isError && currentValue == -1) ? theme?.errorColorSecondary : UIColor.clear
        
        for tag in 1...5 {
            self.contentView.viewWithTag(tag)?.cornerRadius = 19
            self.contentView.viewWithTag(tag)?.borderColor = color
            self.contentView.viewWithTag(tag)?.borderWidth = 2
            
            if currentValue == -1 {
                self.contentView.viewWithTag(tag)?.alpha = 1
            }
        }
        
        if (field?.isError ?? false) && currentValue == -1 {
            animateSmiles()
        }
    }
    
    func animateSmiles() {
        UIView.animate(withDuration: 0.1) {
            for tag in 1...5 {
                self.contentView.viewWithTag(tag)?.frame.origin.x -= 3
            }
        } completion: { (finished) in
            UIView.animate(withDuration: 0.1) {
                for tag in 1...5 {
                    self.contentView.viewWithTag(tag)?.frame.origin.x += 6
                }
            } completion: { (finished) in
                UIView.animate(withDuration: 0.1) {
                    for tag in 1...5 {
                        self.contentView.viewWithTag(tag)?.frame.origin.x -= 4.5
                    }
                } completion: { (finished) in
                    UIView.animate(withDuration: 0.1) {
                        for tag in 1...5 {
                            self.contentView.viewWithTag(tag)?.frame.origin.x += 3
                        }
                    } completion: { (finished) in
                        UIView.animate(withDuration: 0.1) {
                            for tag in 1...5 {
                                self.contentView.viewWithTag(tag)?.frame.origin.x -= 1.5
                            }
                        }
                    }
                }
            }
        }

    }
    
    @IBAction  func smileTapped(_ sender: UIButton){
        guard !animationInProgress, sender.tag != currentValue+1 else {
            return
        }
        
        animationInProgress = true
        currentValue = sender.tag
        UIView.animate(withDuration: 0.15) {
            sender.alpha = 1
            for tag in 1...5 {
                self.contentView.viewWithTag(tag)?.borderColor = .clear
                
                if tag != self.currentValue {
                    self.contentView.viewWithTag(tag)?.alpha = 0.2
                }
            }
        } completion: { (finished) in
            self.animationInProgress = false
            if self.delegate != nil {
                self.delegate?.fieldChanged(self.field!, answer: [String(self.currentValue - 1)], refresh: true)
            }
        }
    }
}
