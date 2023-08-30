//
//  UXFScreenshotCell.swift
//  UX Feedback SDK Demo
//
//  Created by Alexander Potemka on 29.07.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit

class ScreenshotCell: BaseCell {

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var stackViewHeight: NSLayoutConstraint!
    
    @IBOutlet var collectionViewWidth: NSLayoutConstraint!
    
    @IBOutlet var takeView: UIView!  {
        didSet {
            takeView.isHidden = true
        }
    }
    @IBOutlet var takeLabel: UILabel!
    @IBOutlet var takeImage: UIImageView! {
        didSet {
            takeImage.image = takeImage.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet var selectView: UIView! {
        didSet {
            selectView.isHidden = true
        }
    }
    @IBOutlet var selectLabel: UILabel!
    @IBOutlet var selectImage: UIImageView! {
        didSet {
            selectImage.image = selectImage.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet var countLabel: UILabel!
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(UINib(nibName: "ScreenshotImageCell",
                                          bundle: Consts.bundle),
                                    forCellWithReuseIdentifier: "ScreenshotImageCell")
        }
    }
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
    
    override func updateUI() {
        countLabel.font = theme?.fontP2
        countLabel.textColor = theme?.text01Color
        
        takeView.backgroundColor = theme?.controlBgColor
        takeImage.tintColor = theme?.iconColor
        takeLabel.textColor = theme?.text01Color
        takeLabel.font = theme?.fontP2
        
        selectView.backgroundColor = theme?.controlBgColor
        selectImage.tintColor = theme?.iconColor
        selectLabel.textColor = theme?.text01Color
        selectLabel.font = theme?.fontP2
        
        let data = field?.uiData
        
        if let buttons = data?["buttons"] as? [String: String] {
            if let takeButton = buttons["create"] {
                takeLabel.text = takeButton
                takeView.isHidden = false
            }
            
            if let selectButton = buttons["upload"] {
                selectLabel.text = selectButton
                selectView.isHidden = false
            }
        }
    }
    
    public func setActions(take: @escaping (() -> ()), select: @escaping (() -> ()), campaignType: CampaignType) {
        self.takeAction = take
        self.selectAction = select
        var height: CGFloat = 0
        switch campaignType {
        case .popup:
            self.axis = .vertical
            height += takeLabel.isHidden ? 0 : 40
            height += selectLabel.isHidden ? 0 : 40
        case .slidein:
            self.axis = .horizontal
            height += 48
        }
        
        self.stackView.axis = axis
        self.stackViewHeight.constant = height
    }
    
    //MARK :- Actions
    
    private func takeSetHighlight(_ isHighlighted: Bool) {
        takeImage.tintColor = isHighlighted ? theme?.iconColor : theme?.text03Color
        takeView.backgroundColor = isHighlighted ? theme?.controlBgColorActive : theme?.controlBgColor
    }
    
    private func selectSetHighlight(_ isHighlighted: Bool) {
        selectImage.tintColor = isHighlighted ? theme?.iconColor : theme?.text03Color
        selectView.backgroundColor = isHighlighted ? theme?.controlBgColorActive : theme?.controlBgColor
    }
    
    private func setEnabledBtns(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        selectImage.tintColor = isEnabled ? theme?.text03Color : theme?.iconColor
        takeImage.tintColor = isEnabled ? theme?.text03Color : theme?.iconColor
        selectLabel.textColor = isEnabled ? theme?.text01Color : theme?.text03Color
        takeLabel.textColor = isEnabled ? theme?.text01Color : theme?.text03Color
    }

    
    @IBAction func takeDown(_ sender: Any) {
        if !isEnabled {
            return
        }
        takeSetHighlight(true)
    }
    
    @IBAction func takeUpInside(_ sender: Any) {
        if !isEnabled {
            showMaxCount()
            return
        }
        if takeAction != nil {
            takeAction!()
        }
        
        takeSetHighlight(false)
    }
    
    @IBAction func takeUpOutside(_ sender: Any) {
        if !isEnabled {
            return
        }
        takeSetHighlight(false)
    }
    
    @IBAction func selectDown(_ sender: Any) {
        if !isEnabled {
            return
        }
        selectSetHighlight(true)
    }
    
    @IBAction func selectUpInside(_ sender: Any) {
        if !isEnabled {
            showMaxCount()
            return
        }
        if selectAction != nil {
            selectAction!()
        }
        selectSetHighlight(false)
    }
    
    @IBAction func selectUpOutside(_ sender: Any) {
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
            alert.dismiss(animated: true, completion: nil)
        }
        
        let deleteAction = UIAlertAction(title: Consts.Texts.delete, style: .default) { alertAction in
            self.screenshots.remove(at: index)
//            self.delegate?.fieldChanged(field, answer: [], refresh: true)
//            self.delegate?.screenshotChanged(screenshots: self.screenshots)
            
            self.delegate?.screenshotChanged(self.field!, screenshots: self.screenshots)
            
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(noDeleteAction)
        alert.addAction(deleteAction)
        showAlert(alert)
    }
    
    private func showMaxCount() {
        let alert = UIAlertController(title: Consts.Texts.screenshotMaxCount, message: Consts.Texts.screenshotMaxCountNext, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Consts.Texts.okay, style: .default) { alertAction in
            alert.dismiss(animated: true, completion: nil)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScreenshotImageCell", for: indexPath) as! ScreenshotImageCell
        
        cell.configure(image: screenshots[indexPath.row].image) {
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
