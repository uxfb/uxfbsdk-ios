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
        label.text = ""
        label.attributedText = nil
        return label
    }()
    
    lazy var descriptionLabel: LinkLabel = {
        let label = LinkLabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.attributedText = nil
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
    private var imageHeightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        super.layoutSubviews()
        CATransaction.commit()
    }
    
    private func updateTheme() {
        guard let theme = theme else { return }
        
        label.textColor = theme.text01Color
        descriptionLabel.textColor = theme.text01Color
        self.backgroundColor = theme.bgColor
    }
    
    func configure(field: Field, theme: ThemeProtocol) {
        self.field = field
        self.theme = theme
        updateUI()
    }
    
    func clear() {
        label.attributedText = nil
        descriptionLabel.attributedText = nil
    }
    
    private func getImageConstraint(for size: CGSize) -> CGFloat {
        let kHeight = 240 / size.height
        
        let newWidth = size.width * kHeight
        
        return newWidth
    }
    
    private func breakable(_ constraint: NSLayoutConstraint) -> NSLayoutConstraint {
        constraint.priority = .defaultHigh
        return constraint
    }

    private func setup() {
        addSubview(label)
        addSubview(descriptionLabel)
        addSubview(imageView)

        label.setContentCompressionResistancePriority(.required, for: .vertical)
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8)
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
        
        imageHeightConstraint?.isActive = false
        let imgHeight = HeaderCell.computeImageHeight(field: field, isDefault: isDefault)
        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: imgHeight)
        
        if position == "topHeader" {
            NSLayoutConstraint.activate([
                breakable(descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)),
                label.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -12),
                imageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -8),
                imageHeightConstraint!
            ])
        } else {
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: 16),
                breakable(imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)),
                imageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
                imageHeightConstraint!
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
                        NotificationCenter.default.post(name: .headerImageDidLoad, object: nil)
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
        
        updateTheme()
        
        let required = field.required ?? false
        
        label.attributedText = TextPropertyManager.convert(field.value ?? "",
                                                           theme: theme,
                                                           defaultFont: theme.fontH2,
                                                           textProperties: nil,
                                                           withRequired: required)
        
        if let descriptionData = field.description {
            descriptionLabel.attributedText = TextPropertyManager.convert(descriptionData, theme: theme, defaultFont: theme.fontP1, textProperties: nil, withRequired: false)
        } else {
            descriptionLabel.text = nil
            descriptionLabel.attributedText = nil
        }
        
        if let fieldImage = field.image,
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
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                breakable(descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8))
            ])
        }
    }
}
