//
//  UXFImageCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class ImageCell: BaseCell {
    
    private lazy var cellImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    override func setupSubviews() {
        contentView.addSubview(cellImageView)
        
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func updateUI() {
        guard field != nil, theme != nil else {
            return
        }
        
        loadImage()
    }
    
    var canReload = false
    
    @objc
    private func handleTap() {
        if canReload {
            cellImageView.image = nil
        	loadImage()
        }
    }
    
    private func loadImage() {
        guard let image = field?.uiData["image"] as? Dictionary<String, Any> else {
            return
        }
        
        let urlString = image["src"] as? String
        
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }
        
        cellImageView.showSkeleton(baseColor: theme?.skeletonBase, shineColor: theme?.skeletonShine)
        
        cellImageView.cacheImage(url: url, withTemplate: false) { result in
            self.cellImageView.hideSkeleton()
            self.canReload = !result
            if result {
                self.cellImageView.backgroundColor = .clear
                self.cellImageView.contentMode = .scaleAspectFit
            } else {
                DispatchQueue.main.async {
                    let image = UIImage(named: "retry",
                                        in: Consts.bundle,
                                        compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
                    
                    self.cellImageView.contentMode = .center
                    self.cellImageView.backgroundColor = self.theme?.skeletonShine
                    self.cellImageView.image = image
                }
            }
        }
    }
}
