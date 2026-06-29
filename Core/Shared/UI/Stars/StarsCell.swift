//
//  UXFStarsCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class StarsCell: BaseCell {
    
    private lazy var star1: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "star_active",
                             in: Consts.bundle,
                             compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        view.tag = 1
        return view
    }()
    
    private lazy var star2: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "star_active",
                             in: Consts.bundle,
                             compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        view.tag = 2
        return view
    }()
    
    private lazy var star3: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "star_active",
                             in: Consts.bundle,
                             compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        view.tag = 3
        return view
    }()
    
    private lazy var star4: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "star_active",
                             in: Consts.bundle,
                             compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        view.tag = 4
        return view
    }()
    
    private lazy var star5: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "star_active",
                             in: Consts.bundle,
                             compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        view.tag = 5
        return view
    }()
    
    private var animationInProgress: Bool = false
    private var currentValue: Int = -1
    
    override func setupSubviews() {
        contentView.addSubview(star1)
        contentView.addSubview(star2)
        contentView.addSubview(star3)
        contentView.addSubview(star4)
        contentView.addSubview(star5)
        
        star1.translatesAutoresizingMaskIntoConstraints = false
        star2.translatesAutoresizingMaskIntoConstraints = false
        star3.translatesAutoresizingMaskIntoConstraints = false
        star4.translatesAutoresizingMaskIntoConstraints = false
        star5.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            star3.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            star3.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            star3.heightAnchor.constraint(equalToConstant: 38),
            star3.widthAnchor.constraint(equalToConstant: 38),
            
            star2.trailingAnchor.constraint(equalTo: star3.leadingAnchor, constant: -20),
            star2.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            star2.heightAnchor.constraint(equalToConstant: 38),
            star2.widthAnchor.constraint(equalToConstant: 38),
            
            star1.trailingAnchor.constraint(equalTo: star2.leadingAnchor, constant: -20),
            star1.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            star1.heightAnchor.constraint(equalToConstant: 38),
            star1.widthAnchor.constraint(equalToConstant: 38),
            
            star4.leadingAnchor.constraint(equalTo: star3.trailingAnchor, constant: 20),
            star4.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            star4.heightAnchor.constraint(equalToConstant: 38),
            star4.widthAnchor.constraint(equalToConstant: 38),
            
            star5.leadingAnchor.constraint(equalTo: star4.trailingAnchor, constant: 20),
            star5.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            star5.heightAnchor.constraint(equalToConstant: 38),
            star5.widthAnchor.constraint(equalToConstant: 38),
        ])
    }
    
    override func updateUI() {
        currentValue = Int(field?.answers.first ?? "") ?? -1
        
        let color = (field!.isError && currentValue == -1) ? theme?.iconDisabledColor : theme?.iconDisabledColor
        
        for tag in 1...5 {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(starTapped(_ :)))
            self.contentView.viewWithTag(tag)?.isUserInteractionEnabled = true
            self.contentView.viewWithTag(tag)?.addGestureRecognizer(tapGesture)
            
            if currentValue == -1 || tag > self.currentValue  {
                (self.contentView.viewWithTag(tag) as? UIImageView)?.tintColor = color
            } else {
                (self.contentView.viewWithTag(tag) as? UIImageView)?.tintColor = theme?.iconStarColor
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
                let imageView = self.contentView.viewWithTag(tag) as? UIImageView
                imageView?.tintColor = self.theme?.iconStarColor
            } else {
                let imageView = self.contentView.viewWithTag(tag) as? UIImageView
                imageView?.tintColor = self.theme?.iconDisabledColor
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
