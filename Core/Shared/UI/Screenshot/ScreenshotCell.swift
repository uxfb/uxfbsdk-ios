//
//  UXFScreenshotCell.swift
//  UX Feedback SDK Demo
//
//  Created by Alexander Potemka on 29.07.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit

class ScreenshotCell: BaseCell {

    var platform: String?
        
    private lazy var takeView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var spaceView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private lazy var takeButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("", for: .normal)
        view.addTarget(self, action: #selector(takeDown(_:)), for: .touchDown)
        view.addTarget(self, action: #selector(takeUpInside(_:)), for: .touchUpInside)
        view.addTarget(self, action: #selector(takeUpOutside(_:)), for: .touchCancel)
        view.addTarget(self, action: #selector(takeUpOutside(_:)), for: .touchDragExit)
        view.addTarget(self, action: #selector(takeUpOutside(_:)), for: .touchDragOutside)
        view.addTarget(self, action: #selector(takeUpOutside(_:)), for: .touchUpOutside)
        return view
    }()
    
    private lazy var takeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private lazy var takeImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "screenshot",
                              in: Consts.bundle,
                              compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        return image
    }()
    
    private lazy var selectView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var selectButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("", for: .normal)
        view.addTarget(self, action: #selector(selectDown(_:)), for: .touchDown)
        view.addTarget(self, action: #selector(selectUpInside(_:)), for: .touchUpInside)
        view.addTarget(self, action: #selector(selectUpOutside(_:)), for: .touchCancel)
        view.addTarget(self, action: #selector(selectUpOutside(_:)), for: .touchDragExit)
        view.addTarget(self, action: #selector(selectUpOutside(_:)), for: .touchDragOutside)
        view.addTarget(self, action: #selector(selectUpOutside(_:)), for: .touchUpOutside)
        return view
    }()
    
    private lazy var selectLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private lazy var selectImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "attach",
                              in: Consts.bundle,
                              compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        return image
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
//        view.distribution = .fillEqually
        view.spacing = 0
        view.layer.masksToBounds = true
        return view
    }()
    
    private var stackViewHeight: NSLayoutConstraint!
    private var collectionViewWidth: NSLayoutConstraint!
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = .init(width: 76, height: 76)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ScreenshotImageCell.self,
                                forCellWithReuseIdentifier: String(describing: ScreenshotImageCell.self))
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private var screenshots: [Screenshot] = []
    
    private var maxCount: Int = 3
    
    private var takeAction: (() -> ())?
    private var selectAction: (() -> ())?
    
    private var axis = NSLayoutConstraint.Axis.horizontal
    
    private var isEnabled: Bool = true
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setScreenshots(_ screenshots: [Screenshot]) {
        self.screenshots = screenshots
        
        collectionViewWidth.constant = CGFloat(screenshots.count * 76 + (screenshots.count - 1) * 16)
        
        collectionView.reloadData()
        
        setEnabledBtns(screenshots.count < maxCount)
        
        countLabel.text = screenshots.count > 0 ? "\(Consts.Texts.screenshots) \(screenshots.count) \(Consts.Texts.of) \(maxCount)" : ""
    }
    
    override func setupSubviews() {
        takeView.addSubview(takeButton)
        takeView.addSubview(takeLabel)
        takeView.addSubview(takeImage)
        selectView.addSubview(selectButton)
        selectView.addSubview(selectLabel)
        selectView.addSubview(selectImage)
        
        
        stackView.addArrangedSubview(takeView)
        stackView.addArrangedSubview(spaceView)
        stackView.addArrangedSubview(selectView)
        
        contentView.addSubview(stackView)
        
        contentView.addSubview(collectionView)
        
        contentView.addSubview(countLabel)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        takeView.translatesAutoresizingMaskIntoConstraints = false
        takeButton.translatesAutoresizingMaskIntoConstraints = false
        takeLabel.translatesAutoresizingMaskIntoConstraints = false
        takeImage.translatesAutoresizingMaskIntoConstraints = false
        
        selectView.translatesAutoresizingMaskIntoConstraints = false
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        selectLabel.translatesAutoresizingMaskIntoConstraints = false
        selectImage.translatesAutoresizingMaskIntoConstraints = false
        spaceView.translatesAutoresizingMaskIntoConstraints = false
        stackViewHeight = NSLayoutConstraint(item: stackView,
                                             attribute: .height,
                                             relatedBy: .greaterThanOrEqual,
                                             toItem: nil,
                                             attribute: .height,
                                             multiplier: 1,
                                             constant: 48)
        
        collectionViewWidth = NSLayoutConstraint(item: collectionView,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .width,
                                                 multiplier: 1,
                                                 constant: 192)
        
        NSLayoutConstraint.activate([
            spaceView.widthAnchor.constraint(equalToConstant: 1),
            spaceView.heightAnchor.constraint(equalToConstant: 1),
            
            takeView.widthAnchor.constraint(equalTo: selectView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackViewHeight,
            
            countLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            countLabel.heightAnchor.constraint(equalToConstant: 32),
            
            collectionView.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 16),
            collectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 76),
            collectionViewWidth,
            
            takeButton.topAnchor.constraint(equalTo: takeView.topAnchor),
            takeButton.leadingAnchor.constraint(equalTo: takeView.leadingAnchor),
            takeButton.trailingAnchor.constraint(equalTo: takeView.trailingAnchor),
            takeButton.bottomAnchor.constraint(equalTo: takeView.bottomAnchor),
            
            takeImage.leadingAnchor.constraint(equalTo: takeView.leadingAnchor, constant: 12),
            takeImage.heightAnchor.constraint(equalToConstant: 24),
            takeImage.widthAnchor.constraint(equalToConstant: 24),
            takeImage.centerYAnchor.constraint(equalTo: takeView.centerYAnchor),
            
            takeLabel.leadingAnchor.constraint(equalTo: takeImage.trailingAnchor, constant: 12),
            takeLabel.trailingAnchor.constraint(equalTo: takeView.trailingAnchor, constant: -12),
            takeLabel.topAnchor.constraint(equalTo: takeView.topAnchor, constant: 0),
            takeLabel.bottomAnchor.constraint(equalTo: takeView.bottomAnchor, constant: 0),
            
            selectButton.topAnchor.constraint(equalTo: selectView.topAnchor),
            selectButton.leadingAnchor.constraint(equalTo: selectView.leadingAnchor),
            selectButton.trailingAnchor.constraint(equalTo: selectView.trailingAnchor),
            selectButton.bottomAnchor.constraint(equalTo: selectView.bottomAnchor),
            
            selectImage.leadingAnchor.constraint(equalTo: selectView.leadingAnchor, constant: 12),
            selectImage.heightAnchor.constraint(equalToConstant: 24),
            selectImage.widthAnchor.constraint(equalToConstant: 24),
            selectImage.centerYAnchor.constraint(equalTo: selectView.centerYAnchor),
            
            selectLabel.leadingAnchor.constraint(equalTo: selectImage.trailingAnchor, constant: 12),
            selectLabel.trailingAnchor.constraint(equalTo: selectView.trailingAnchor, constant: -12),
            selectLabel.topAnchor.constraint(equalTo: selectView.topAnchor, constant: 0),
            selectLabel.bottomAnchor.constraint(equalTo: selectView.bottomAnchor, constant: 0)
        ])
        
        self.contentView.layoutIfNeeded()
    }
    
    override func updateUI() {
        
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = theme?.borderDisabled.cgColor ?? UIColor.clear.cgColor
        stackView.layer.cornerRadius = theme?.btnBorderRadius ?? .zero
        
        spaceView.backgroundColor = theme?.borderDisabled
        
        countLabel.font = theme?.fontP2
        countLabel.textColor = theme?.text03Color
        
        takeView.backgroundColor = .clear //theme?.controlBgColor
        takeImage.tintColor = theme?.iconColor
        takeLabel.textColor = theme?.text01Color
        takeLabel.font = theme?.fontP2
        
        selectView.backgroundColor = .clear//theme?.controlBgColor
        selectImage.tintColor = theme?.iconColor
        selectLabel.textColor = theme?.text01Color
        selectLabel.font = theme?.fontP2
        
        let data = field?.uiData
        
        if let buttons = data?["buttons"] as? [String: String] {
            if let takeButton = buttons["create"] {
                takeLabel.text = takeButton
                takeView.isHidden = false
            } else {
                takeView.isHidden = true
            }
            
            if let selectButton = buttons["upload"] {
                selectLabel.text = selectButton
                selectView.isHidden = false
            } else {
                selectView.isHidden = true
            }
        }
    }
    
    public func setActions(take: @escaping (() -> ()), select: @escaping (() -> ()), campaignType: CampaignType) {
        var takeText = ""
        var selectText = ""
        
        if let buttons = field?.uiData["buttons"] as? [String: String] {
            if let takeButton = buttons["create"] {
                takeText = takeButton
            }
            
            if let selectButton = buttons["upload"] {
                selectText = selectButton
            }
        }
        
        self.takeAction = take
        self.selectAction = select
        var height: CGFloat = 0
        switch campaignType {
        case .popup:
            self.axis = .vertical
                let lWidth = (UIScreen.main.bounds.width - 204)/2
                height += takeLabel.isHidden ? 0 : takeText.height(withConstrainedWidth: lWidth,
                                                                   font: theme?.fontP2 ?? .systemFont(ofSize: 14, weight: .regular)) + 8
            height += selectLabel.isHidden ? 0 : selectText.height(withConstrainedWidth: lWidth,
                                                                   font: theme?.fontP2 ?? .systemFont(ofSize: 14, weight: .regular)) + 8
            stackView.spacing = 8
        case .slidein:
            self.axis = .horizontal
                let lWidth = (UIScreen.main.bounds.width - 156)/2
                let takeHeight = takeText.height(withConstrainedWidth: lWidth,
                                                 font: theme?.fontP2 ?? .systemFont(ofSize: 14, weight: .regular)) + 8
                let selectHeight = takeText.height(withConstrainedWidth: lWidth,
                                                   font: theme?.fontP2 ?? .systemFont(ofSize: 14, weight: .regular)) + 8
            height += max(takeHeight, selectHeight, 48)
            stackView.spacing = 0
        }
        
        self.stackView.axis = axis
        self.stackViewHeight.constant = height
    }
    
    //MARK :- Actions
    
    private func takeSetHighlight(_ isHighlighted: Bool) {
        takeImage.tintColor = isHighlighted ? theme?.btnBgColor : theme?.iconColor
        takeView.backgroundColor = isHighlighted ? theme?.controlBgColorActive : .clear
    }
    
    private func selectSetHighlight(_ isHighlighted: Bool) {
        selectImage.tintColor = isHighlighted ? theme?.btnBgColor : theme?.iconColor
        selectView.backgroundColor = isHighlighted ? theme?.controlBgColorActive : .clear
    }
    
    private func setEnabledBtns(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        selectImage.tintColor = isEnabled ? theme?.iconColor : theme?.iconColor
        takeImage.tintColor = isEnabled ? theme?.iconColor : theme?.iconColor
        selectLabel.textColor = isEnabled ? theme?.text01Color : theme?.text01Color
        takeLabel.textColor = isEnabled ? theme?.text01Color : theme?.text01Color
    }

    @objc
    private func takeDown(_ sender: Any) {
        if !isEnabled {
            return
        }
        takeSetHighlight(true)
    }
    
    @objc
    private func takeUpInside(_ sender: Any) {
        if !isEnabled {
            showMaxCount()
            return
        }
        if takeAction != nil {
            takeAction!()
        }
        
        takeSetHighlight(false)
    }
    
    @objc
    private func takeUpOutside(_ sender: Any) {
        if !isEnabled {
            return
        }
        takeSetHighlight(false)
    }
    
    @objc
    private func selectDown(_ sender: Any) {
        if !isEnabled {
            return
        }
        selectSetHighlight(true)
    }
    
    @objc
    private func selectUpInside(_ sender: Any) {
        if !isEnabled {
            showMaxCount()
            return
        }
        if selectAction != nil {
            selectAction!()
        }
        selectSetHighlight(false)
    }
    
    @objc
    private func selectUpOutside(_ sender: Any) {
        if !isEnabled {
            return
        }
        selectSetHighlight(false)
    }
    
    private func showDeleteConfirmation(index: Int) {
        let screenshot = screenshots[index]
        let message = screenshot.type == .screenshot ? Consts.Texts.screenshotDeleteInfo : Consts.Texts.screenshotDeleteFuture
        let alert = UIAlertController(title: Consts.Texts.screenshotDeleteQuestion, message: message, preferredStyle: .alert)
        let noDeleteAction = UIAlertAction(title: Consts.Texts.noDelete, style: .default) { alertAction in
            alert.dismissGlobally(animated: true)
        }
        
        let deleteAction = UIAlertAction(title: Consts.Texts.delete, style: .default) { alertAction in
            self.screenshots.remove(at: index)
//            self.delegate?.fieldChanged(field, answer: [], refresh: true)
//            self.delegate?.screenshotChanged(screenshots: self.screenshots)
            
            self.delegate?.screenshotChanged(self.field!, screenshots: self.screenshots)
            
            alert.dismissGlobally(animated: true)
        }
        alert.addAction(noDeleteAction)
        alert.addAction(deleteAction)
        showAlert(alert)
    }
    
    private func showMaxCount() {
        let alert = UIAlertController(title: Consts.Texts.screenshotMaxCount, message: Consts.Texts.screenshotMaxCountNext, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Consts.Texts.okay, style: .default) { alertAction in
            alert.dismissGlobally(animated: true)
        }

        alert.addAction(okAction)
        showAlert(alert)
    }
    
    private func showAlert(_ alert: UIAlertController) {
        alert.presentGlobally(animated: true, completion: nil)
    }
}

extension ScreenshotCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ScreenshotImageCell.self),
                                                      for: indexPath) as! ScreenshotImageCell
        
        cell.configure(image: screenshots[indexPath.row].image, theme: theme) {
            self.showDeleteConfirmation(index: indexPath.row)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return screenshots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: 76, height: 76)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let myCell = collectionView.cellForItem(at: indexPath) as! ScreenshotImageCell
        let globalPoint = myCell.imageView.superview?.convert(myCell.imageView.frame.origin, to: nil) ?? .zero
        
        let images = screenshots.map { $0.image }
        ImageManager.showImageFullScreen(images: images, tappedIndex: indexPath.row, startPoint: globalPoint, startSize: myCell.imageView.frame.size) { } closeAction: { }
    }
}
