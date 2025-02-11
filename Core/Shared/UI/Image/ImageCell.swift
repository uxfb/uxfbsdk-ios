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
        
        guard let sets = field?.uiData["image"] as? Dictionary<String, Any> else {
            return
        }
        var urlString = sets["2x"] as? String
        let scale = UIScreen.main.scale
        switch scale {
        case 2:
            urlString = sets["2x"] as? String
            break
        case 3:
            urlString = sets["3x"] as? String
            break
        default:
            urlString = sets["2x"] as? String
            break
        }
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }
        cellImageView.cacheImage(url: url, withTemplate: false)
    }
}
