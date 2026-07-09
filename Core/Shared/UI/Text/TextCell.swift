//
//  UXFTextCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class TextCell: BaseCell {
    private lazy var label: LinkLabel = {
        let label = LinkLabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var textImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var alignment: String = "left"
    private var position: String = "topHeader"
    private var isDefault: Bool = false
    
    override func setupSubviews() {
        contentView.addSubview(label)
        contentView.addSubview(textImageView)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        textImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func updateWidthConstraints() {
        guard let image = textImageView.image else {
            return
        }
        
        let width = self.getImageConstraint(for: image.size)
        
        NSLayoutConstraint.activate([
            textImageView.widthAnchor.constraint(lessThanOrEqualToConstant: width)
        ])
    }
    
    private func getImageConstraint(for size: CGSize) -> CGFloat {
        let kHeight = (isDefault ? 100 : 240) / size.height
        let newWidth = size.width * kHeight
        return newWidth
    }
    
    private func updateImageConstraints() {
        switch alignment {
            case "left":
                NSLayoutConstraint.activate([
                    textImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    textImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
                ])
                
            case "right":
                NSLayoutConstraint.activate([
                    textImageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16),
                    textImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
                ])
                
            case "center":
                NSLayoutConstraint.activate([
                    textImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    textImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
                ])
                
            default:
                break
        }
        
        if position == "topHeader" {
            NSLayoutConstraint.activate([
                textImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                textImageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -8),
                label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                textImageView.heightAnchor.constraint(equalToConstant: isDefault ? 100 : 240)
            ])
        } else {
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.topAnchor),
                textImageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
                textImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
                textImageView.heightAnchor.constraint(equalToConstant: isDefault ? 100 : 240)
            ])
        }
        
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
        }
    }
    
    private func updateImage(url: URL) {
        if !isDefault {
            let tapGesture = GestureRecognizer {
                let globalPoint = self.textImageView.superview?.convert(self.textImageView.frame.origin, to: nil) ?? .zero
                ImageManager.showImageFullScreen(images: [self.textImageView.image ?? UIImage()], tappedIndex: 0, startPoint: globalPoint, startSize: self.textImageView.frame.size, withNav: false) { } closeAction: { }
            }
            self.textImageView.gestureRecognizers?.removeAll()
            self.textImageView.addGestureRecognizer(tapGesture)
            self.textImageView.isUserInteractionEnabled = true
        }
        
        let imageFromCache = ImageCache.shared.object(forKey: url.absoluteString as NSString)
        
        if imageFromCache == nil {
            DispatchQueue.main.async {
                self.textImageView.showSkeleton(baseColor: self.theme?.skeletonBase, shineColor: self.theme?.skeletonShine)
            }
            textImageView.loadImageWithResult(url: url, withTemplate: false) { loadedImage in
                DispatchQueue.main.async {
                    self.textImageView.hideSkeleton()
                }
                
                DispatchQueue.main.async {
                    if let loadedImage = loadedImage {
                        self.textImageView.image = loadedImage
                        self.updateWidthConstraints()
                    }
                }
            }
        } else {
            textImageView.image = imageFromCache
            self.updateWidthConstraints()
        }
    }
    
    override func updateUI() {
        contentView.removeAllConstraints()
        guard field != nil, theme != nil else {
            return
        }
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        label.textColor = theme?.text02Color
        let value = field?.value ?? ""
        label.attributedText = TextPropertyManager.convert(value,
                                                           theme: theme!,
                                                           defaultFont: theme!.fontP1,
                                                           textProperties: nil, withRequired: false)
        
        if let imageData = self.field?.uiData["image"] as? Dictionary<String, Any>,
           let position = imageData["position"] as? String,
           let alignment = imageData["alignment"] as? String,
           let src = imageData["src"] as? String,
           let url = URL(string: src) {
            let isDefault = ((imageData["type"] as? String) ?? "default") == "default"
            self.isDefault = isDefault
            self.position = position
            self.alignment = alignment
            self.updateImageConstraints()
            self.updateImage(url: url)
        } else {
            self.textImageView.image = nil
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.topAnchor),
                label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
    }
}
