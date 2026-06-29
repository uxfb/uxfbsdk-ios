//
//  UXFHeaderCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class HeaderCell: BaseCell {
    
    private lazy var label: LinkLabel = {
        let label = LinkLabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: LinkLabel = {
        let label = LinkLabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var headerImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var alignment: String = "left"
    private var position: String = "topHeader"
    private var isDefault: Bool = false
    private var imageHeightConstraint: NSLayoutConstraint?
    
    override func setupSubviews() {
        contentView.addSubview(label)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(headerImageView)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func updateWidthConstraints() {
        guard let image = headerImageView.image else {
            return
        }
        
        let width = self.getImageConstraint(for: image.size )
        
        NSLayoutConstraint.activate([
            headerImageView.widthAnchor.constraint(lessThanOrEqualToConstant: width)
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
                    headerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    headerImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
                ])
                
                
            case "right":
                NSLayoutConstraint.activate([
                    headerImageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16),
                    headerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
                ])
                
            case "center":
                NSLayoutConstraint.activate([
                    headerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    headerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
                ])
                
            default:
                break
        }
        
        imageHeightConstraint?.isActive = false
        let imgHeight = Self.computeImageHeight(field: field, isDefault: isDefault)
        imageHeightConstraint = headerImageView.heightAnchor.constraint(equalToConstant: imgHeight)
        
        if position == "topHeader" {
            NSLayoutConstraint.activate([
                descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
                label.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -12),
                headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                headerImageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -8),
                imageHeightConstraint!
            ])
        } else {
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
                descriptionLabel.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 8),
                descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
                headerImageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
                imageHeightConstraint!
            ])
        }
        
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
        }
    }
    
    static func computeImageHeight(field: Field?, isDefault: Bool) -> CGFloat {
        let maxHeight: CGFloat = isDefault ? 100 : 240
        guard !isDefault, let fieldImage = field?.image else { return maxHeight }
        let urlString = fieldImage.src ?? fieldImage.threeX
        guard let urlString = urlString,
              let cachedImage = ImageCache.shared.object(forKey: urlString as NSString) else {
            return maxHeight
        }
        return min(cachedImage.size.height, maxHeight)
    }
    
    private func updateImage(url: URL) {
        if !isDefault {
            let tapGesture = GestureRecognizer {
                let globalPoint = self.headerImageView.superview?.convert(self.headerImageView.frame.origin, to: nil) ?? .zero
                ImageManager.showImageFullScreen(images: [self.headerImageView.image ?? UIImage()], tappedIndex: 0, startPoint: globalPoint, startSize: self.headerImageView.frame.size, withNav: false) { } closeAction: { }
            }
            self.headerImageView.gestureRecognizers?.removeAll()
            self.headerImageView.addGestureRecognizer(tapGesture)
            self.headerImageView.isUserInteractionEnabled = true
        }
        
        let imageFromCache = ImageCache.shared.object(forKey: url.absoluteString as NSString)
        
        if imageFromCache == nil {
            DispatchQueue.main.async {
                self.headerImageView.showSkeleton(baseColor: self.theme?.skeletonBase, shineColor: self.theme?.skeletonShine)
            }
            headerImageView.loadImageWithResult(url: url, withTemplate: false) { loadedImage in
                DispatchQueue.main.async {
                    self.headerImageView.hideSkeleton()
                }
                
                DispatchQueue.main.async {
                    if let loadedImage = loadedImage {
                        self.headerImageView.image = loadedImage
                        self.updateWidthConstraints()
                        NotificationCenter.default.post(name: .headerImageDidLoad, object: nil)
                    }
                }
            }
        } else {
            headerImageView.image = imageFromCache
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
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        
        label.textColor = theme?.text01Color
        label.attributedText = TextPropertyManager.convert(field?.value ?? "",
                                                           theme: theme!,
                                                           defaultFont: theme!.fontH1,
                                                           textProperties: nil,
                                                           withRequired: false)
        
        descriptionLabel.textColor = theme?.text01Color
        if let descriptionData = field?.description, let theme = theme {
            descriptionLabel.attributedText = TextPropertyManager.convert(descriptionData,
                                                                          theme: theme,
                                                                          defaultFont: theme.fontP1,
                                                                          textProperties: nil,
                                                                          withRequired: false)
        } else {
            descriptionLabel.attributedText = nil
            descriptionLabel.text = nil
        }
        
        if let fieldImage = self.field?.image,
           let position = fieldImage.position,
           let alignment = fieldImage.alignment,
           let src = fieldImage.src,
           let url = URL(string: src) {
            let isDefault = (fieldImage.type ?? "default") == "default"
            self.isDefault = isDefault
            self.position = position
            self.alignment = alignment
            self.updateImageConstraints()
            self.updateImage(url: url)
        } else {
            self.headerImageView.image = nil
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                descriptionLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
                descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])
        }
    }
}


extension Notification.Name {
    static let headerImageDidLoad = Notification.Name("headerImageDidLoad")
}

internal extension UIView {
    func removeAllConstraints() {
        var _superview = self.superview
        
        while let superview = _superview {
            for constraint in superview.constraints {
                
                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }
                
                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }
            
            _superview = superview.superview
        }
        
        self.removeConstraints(self.constraints)
        self.translatesAutoresizingMaskIntoConstraints = true
    }
}
