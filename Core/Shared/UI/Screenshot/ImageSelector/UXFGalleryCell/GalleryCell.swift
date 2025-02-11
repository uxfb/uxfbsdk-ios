//
//  UXFGalleryCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 01.08.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit
import Photos

class GalleryCell: UICollectionViewCell {

    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.layer.cornerRadius = 12
            label.layer.borderWidth = 2
            label.layer.borderColor = UIColor.init("#B5B8C2").cgColor
            label.backgroundColor = .clear
            label.layer.masksToBounds = true
        }
    }
    
    private let manager = PHImageManager.default()
    private let options = PHImageRequestOptions()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        options.isSynchronous = false
    }
    
    public func configure(_ asset: PHAsset, index: Int = 0, alpha: CGFloat = 1, theme: ThemeProtocol?) {
        manager.requestImage(for: asset, targetSize: CGSize(width: 196, height: 196), contentMode: .aspectFill, options: options, resultHandler: {(result, info)->Void in
            
            self.imageView.image = result!
        })
        
        self.contentView.alpha = alpha
        if index > 0 {
            leftConstraint.constant = 8
            rightConstraint.constant = 8
            topConstraint.constant = 8
            bottomConstraint.constant = 8
            
            label.layer.borderWidth = 0
            label.backgroundColor = theme?.btnBgColor
            label.text = "\(index)"
        } else {
            label.text = ""
            leftConstraint.constant = 0
            rightConstraint.constant = 0
            topConstraint.constant = 0
            bottomConstraint.constant = 0
            
            label.layer.borderWidth = 2
            label.layer.borderColor = theme?.iconColor.cgColor
            label.backgroundColor = .clear
        }
    }
}
