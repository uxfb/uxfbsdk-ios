//
//  UXFImageCell.swift
//  UX Feedback SDK Demo
//
//  Created by Alexander Potemka on 01.08.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit

class ScreenshotImageCell: UICollectionViewCell {
    
    private var deleteAction: (() -> ())?
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.layer.cornerRadius = 12
            closeButton.layer.masksToBounds = true
            closeButton.backgroundColor = UIColor.init("#0076C2")
        }
    }
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 16
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor.init("#D3D4D8").cgColor
            imageView.layer.masksToBounds = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func configure(image: UIImage, deleteAction: @escaping () -> ()) {
        self.deleteAction = deleteAction
        imageView.image = image
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        if deleteAction != nil {
            deleteAction!()
        }
    }
}
