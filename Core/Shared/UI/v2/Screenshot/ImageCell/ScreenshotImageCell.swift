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
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.layer.cornerRadius = 12
            closeButton.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 16
            imageView.layer.borderWidth = 1
            imageView.layer.masksToBounds = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func configure(image: UIImage, theme: ThemeProtocol?, deleteAction: @escaping () -> ()) {
        self.deleteAction = deleteAction
        self.theme = theme
        imageView.image = image
    }
    
    @IBAction func deletePressed(_ sender: Any) {
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
