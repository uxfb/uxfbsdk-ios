//
//  UXFSmilesCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class SmilesCell: BaseCell {
    
    private lazy var smile1: UIButton = {
        let view = UIButton(type: .custom)
        
        view.setImage(UIImage(named: "angry",
                              in: Consts.bundle,
                              compatibleWith: nil),
                      for: .normal)
        view.addTarget(self, action: #selector(smileTapped(_:)), for: .touchUpInside)
        view.tag = 1
        return view
    }()
    
    private lazy var smile2: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "mad",
                              in: Consts.bundle,
                              compatibleWith: nil),
                      for: .normal)
        view.addTarget(self, action: #selector(smileTapped(_:)), for: .touchUpInside)
        view.tag = 2
        return view
    }()
    
    private lazy var smile3: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "confused",
                              in: Consts.bundle,
                              compatibleWith: nil),
                      for: .normal)
        view.addTarget(self, action: #selector(smileTapped(_:)), for: .touchUpInside)
        view.tag = 3
        return view
    }()
    
    private lazy var smile4: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "happy",
                              in: Consts.bundle,
                              compatibleWith: nil),
                      for: .normal)
        view.addTarget(self, action: #selector(smileTapped(_:)), for: .touchUpInside)
        view.tag = 4
        return view
    }()
    
    private lazy var smile5: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "in-love",
                              in: Consts.bundle,
                              compatibleWith: nil),
                      for: .normal)
        view.addTarget(self, action: #selector(smileTapped(_:)), for: .touchUpInside)
        view.tag = 5
        return view
    }()
    
    private var animationInProgress: Bool = false
    private var currentValue: Int = -1
    
    override func setupSubviews() {
        contentView.addSubview(smile1)
        contentView.addSubview(smile2)
        contentView.addSubview(smile3)
        contentView.addSubview(smile4)
        contentView.addSubview(smile5)
        
        smile1.translatesAutoresizingMaskIntoConstraints = false
        smile2.translatesAutoresizingMaskIntoConstraints = false
        smile3.translatesAutoresizingMaskIntoConstraints = false
        smile4.translatesAutoresizingMaskIntoConstraints = false
        smile5.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            smile3.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            smile3.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            smile3.heightAnchor.constraint(equalToConstant: 38),
            smile3.widthAnchor.constraint(equalToConstant: 38),
            
            smile2.trailingAnchor.constraint(equalTo: smile3.leadingAnchor, constant: -20),
            smile2.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            smile2.heightAnchor.constraint(equalToConstant: 38),
            smile2.widthAnchor.constraint(equalToConstant: 38),
            
            smile1.trailingAnchor.constraint(equalTo: smile2.leadingAnchor, constant: -20),
            smile1.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            smile1.heightAnchor.constraint(equalToConstant: 38),
            smile1.widthAnchor.constraint(equalToConstant: 38),
            
            smile4.leadingAnchor.constraint(equalTo: smile3.trailingAnchor, constant: 20),
            smile4.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            smile4.heightAnchor.constraint(equalToConstant: 38),
            smile4.widthAnchor.constraint(equalToConstant: 38),
            
            smile5.leadingAnchor.constraint(equalTo: smile4.trailingAnchor, constant: 20),
            smile5.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            smile5.heightAnchor.constraint(equalToConstant: 38),
            smile5.widthAnchor.constraint(equalToConstant: 38),
        ])
    }
    
    override func updateUI() {
        currentValue = Int(field?.answers.first ?? "") ?? -1

        for tag in 1...5 {
            self.contentView.viewWithTag(tag)?.cornerRadius = 19

            if currentValue == -1 {
                self.contentView.viewWithTag(tag)?.alpha = 1
            } else {
                self.contentView.viewWithTag(tag)?.alpha = tag != (currentValue + 1) ? 0.2 : 1
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
    
    @objc
    private func smileTapped(_ sender: UIButton) {
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
