//
//  HeaderView.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 17.11.2025.
//  Copyright © 2025 UXF. All rights reserved.
//

import UIKit

internal
class HeaderView: UIView {
    private var field: Field?
    
    private var theme: ThemeProtocol?
    
    lazy var label: LinkLabel = {
        let label = LinkLabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var alignment: String = "left"
    private var position: String = "topHeader"
    private var isDefault: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func updateTheme() {
        guard let theme = theme else { return }
        
        label.textColor = theme.text01Color
    }
    
    func configure(field: Field, theme: ThemeProtocol) {
        self.field = field
        self.theme = theme
        updateUI()
    }
    
    private func getImageConstraint(for size: CGSize) -> CGFloat {
        let kHeight = 240 / size.height
        
        let newWidth = size.width * kHeight
        
        return newWidth
    }
    
    private func setup() {
        addSubview(label)
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    private func updateWidthConstraints() {
        guard let image = imageView.image else {
            return
        }
        
        let width = self.getImageConstraint(for: image.size )
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(lessThanOrEqualToConstant: width)
        ])
    }
    
    private func updateImageConstraints() {
        switch alignment {
            case "left":
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                    imageView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
                ])
                
                
            case "right":
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
                    imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
                ])
                
            case "center":
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                    imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
                ])
                
            default:
                break
        }
        
        if position == "topHeader" {
            NSLayoutConstraint.activate([
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
                imageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -8),
                imageView.heightAnchor.constraint(equalToConstant: isDefault ? 100 : 240)
            ])
        } else {
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: 16),
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
                imageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
                imageView.heightAnchor.constraint(equalToConstant: isDefault ? 100 : 240)
            ])
        }
        
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
        }
    }
    
    private func updateImage(url: URL) {
        if !isDefault {
            let tapGesture = GestureRecognizer {
                let globalPoint = self.imageView.superview?.convert(self.imageView.frame.origin, to: nil) ?? .zero
                ImageManager.showImageFullScreen(images: [self.imageView.image ?? UIImage()], tappedIndex: 0, startPoint: globalPoint, startSize: self.imageView.frame.size, withNav: false) { } closeAction: { }
            }
            self.imageView.gestureRecognizers?.removeAll()
            self.imageView.addGestureRecognizer(tapGesture)
            self.imageView.isUserInteractionEnabled = true
        }
        
        let imageFromCache = ImageCache.shared.object(forKey: url.absoluteString as NSString)
        
        if imageFromCache == nil {
            DispatchQueue.main.async {
                self.imageView.showSkeleton(baseColor: self.theme?.skeletonBase, shineColor: self.theme?.skeletonShine)
            }
            imageView.loadImageWithResult(url: url, withTemplate: false) { loadedImage in
                DispatchQueue.main.async {
                    self.imageView.hideSkeleton()
                }
                
                DispatchQueue.main.async {
                    if let loadedImage = loadedImage {
                        self.imageView.image = loadedImage
                        self.updateWidthConstraints()
                    }
                }
            }
        } else {
            imageView.image = imageFromCache
            self.updateWidthConstraints()
        }
    }
    
    private func updateUI() {
        guard let field = field, let theme = theme else { return }
        
        self.backgroundColor = theme.bgColor
        
        let required = (field.uiData["required"] as? Bool) ?? false
        
        label.attributedText = TextPropertyManager.convert(field.value ?? "",
                                                           theme: theme,
                                                           defaultFont: theme.fontH2,
                                                           textProperties: nil,
                                                           withRequired: required)
        
        if let imageData = field.uiData["image"] as? Dictionary<String, Any>,
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
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
            ])
        }
    }
}
