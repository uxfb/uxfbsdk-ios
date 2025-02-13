//
//  UXFImageCell.swift
//  UX Feedback SDK Demo
//
//  Created by Alexander Potemka on 01.08.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit

class ScreenshotImageCell: UICollectionViewCell {
  
    private var theme: ThemeProtocol? {
      didSet {
        updateUI()
      }
    }
  
    private var deleteAction: (() -> ())?
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "delete_image",
                                in: Consts.bundle,
                                compatibleWith: nil),
                        for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(deletePressed(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 16
        image.layer.borderWidth = 1
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()

    private func setupSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(closeButton)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ])
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
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

    public func configure(image: UIImage, theme: ThemeProtocol?, deleteAction: @escaping () -> ()) {
        self.deleteAction = deleteAction
        self.theme = theme
        imageView.image = image
    }
    
    @objc
    private func deletePressed(_ sender: Any) {
        if deleteAction != nil {
            deleteAction!()
        }
    }
  
  private func updateUI() {
    imageView.layer.borderColor = theme?.inputBorderColor.cgColor
    closeButton.backgroundColor = theme?.btnBgColor
    closeButton.imageView?.tintColor = theme?.btnTextColor
    closeButton.imageView?.image = closeButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
  }
}
