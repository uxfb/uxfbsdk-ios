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
    
    private var leftConstraint: NSLayoutConstraint!
    private var rightConstraint: NSLayoutConstraint!
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 12
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.init("#B5B8C2").cgColor
        label.backgroundColor = .clear
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let manager = PHImageManager.default()
    private let options = PHImageRequestOptions()
    
    private func setupSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        leftConstraint = NSLayoutConstraint(item: imageView,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: contentView,
                                            attribute: .leading,
                                            multiplier: 1,
                                            constant: 0)
        rightConstraint = NSLayoutConstraint(item: contentView,
                                             attribute: .trailing,
                                             relatedBy: .equal,
                                             toItem: imageView,
                                             attribute: .trailing,
                                             multiplier: 1,
                                             constant: 0)
        topConstraint = NSLayoutConstraint(item: imageView,
                                           attribute: .top,
                                           relatedBy: .equal,
                                           toItem: contentView,
                                           attribute: .top,
                                           multiplier: 1,
                                           constant: 0)
        bottomConstraint = NSLayoutConstraint(item: contentView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: imageView,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 0)
        
        NSLayoutConstraint.activate([
            leftConstraint,
            rightConstraint,
            topConstraint,
            bottomConstraint,
            
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            label.heightAnchor.constraint(equalToConstant: 24),
            label.widthAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        options.isSynchronous = false
        setupSubviews()
    }
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
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
            label.textColor = theme?.btnTextColor
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
