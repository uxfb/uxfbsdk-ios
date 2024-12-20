//
//  UXFStarsCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class StarsCell: BaseCell {
    
    private var animationInProgress: Bool = false
    private var currentValue: Int = -1
    
    override func updateUI() {
        currentValue = Int(field?.answers.first ?? "") ?? -1
        
        let color = (field!.isError && currentValue == -1) ? theme?.iconColor : theme?.iconColor
        
        for tag in 1...5 {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(starTapped(_ :)))
            self.contentView.viewWithTag(tag)?.isUserInteractionEnabled = true
            self.contentView.viewWithTag(tag)?.addGestureRecognizer(tapGesture)
            
            if currentValue == -1 || tag > self.currentValue  {
                (self.contentView.viewWithTag(tag) as? UIImageView)?.image = UIImage(named: "star_unactive",
                                                                                     in: Consts.bundle,
                                                                                     compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                (self.contentView.viewWithTag(tag) as? UIImageView)?.tintColor = color
            } else {
                (self.contentView.viewWithTag(tag) as? UIImageView)?.image = UIImage(named: "star_active",
                                                                                     in: Consts.bundle,
                                                                                     compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                (self.contentView.viewWithTag(tag) as? UIImageView)?.tintColor = theme?.iconRating
            }
        }
        
        if (field?.isError ?? false) && currentValue == -1 {
            animateStarsError()
        }
    }
    
    func animateStarsError() {
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
    
    private func animateStar(tag: Int, completion: @escaping () -> Void) {
        UIView.transition(with: self.contentView.viewWithTag(tag) as! UIImageView, duration: 0.0025, options: [.transitionCrossDissolve]) {
            if tag <= self.currentValue {
                (self.contentView.viewWithTag(tag) as? UIImageView)?.tintColor = self.theme?.iconRating
                (self.contentView.viewWithTag(tag) as? UIImageView)?.image = UIImage(named: "star_active",
                                                                                     in: Consts.bundle,
                                                                                     compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            } else {
                (self.contentView.viewWithTag(tag) as? UIImageView)?.tintColor = self.theme?.iconColor
                (self.contentView.viewWithTag(tag) as? UIImageView)?.image = UIImage(named: "star_unactive",
                                                                                     in: Consts.bundle,
                                                                                     compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            }
        } completion: { finished in
            completion()
        }
    }
    
    private func animateStars(reversed: Bool, completion: @escaping () -> Void) {
        if reversed {
            self.animateStar(tag: 5) {
                self.animateStar(tag: 4) {
                    self.animateStar(tag: 3) {
                        self.animateStar(tag: 2) {
                            self.animateStar(tag: 1) {
                                completion()
                            }
                        }
                    }
                }
            }
        } else {
            self.animateStar(tag: 1) {
                self.animateStar(tag: 2) {
                    self.animateStar(tag: 3) {
                        self.animateStar(tag: 4) {
                            self.animateStar(tag: 5) {
                                completion()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc
    private func starTapped(_ sender: UITapGestureRecognizer){
        guard !animationInProgress,
              let tag = sender.view?.tag,
              tag != currentValue  else {
            return
        }
        let oldValue = currentValue
        animationInProgress = true
        currentValue = sender.view?.tag ?? -1
        
        animateStars(reversed: oldValue > currentValue) {
            self.animationInProgress = false
            if self.delegate != nil {
                self.delegate?.fieldChanged(self.field!, answer: [String(self.currentValue)], refresh: true)
            }
        }
    }
}
