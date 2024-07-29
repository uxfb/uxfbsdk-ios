//
//  UXFImageSelector.swift
//  UX Feedback SDK Demo
//
//  Created by Alexander Potemka on 01.08.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit
import Photos

class ImageSelector: UIView, PHPhotoLibraryChangeObserver {
    
    var theme: ThemeProtocol?
    
    @IBOutlet weak var permissionView: UIView! {
        didSet {
            permissionView.backgroundColor = Theme().controlBgColor
        }
    }
    
    @IBOutlet weak var permissionLabel: UILabel! {
        didSet {
            permissionLabel.textColor = Theme().text02Color
        }
    }
    
    @IBOutlet weak var permissionButton: UIButton! {
        didSet {
            let color = UIColor.white
            permissionButton.setTitleColor(color, for: .normal)
            permissionButton.setTitleColor(color.withAlphaComponent(0.5), for: .highlighted)
            permissionButton.backgroundColor = Theme().mainColor
            permissionButton.layer.cornerRadius = 4.0
            permissionButton.layer.masksToBounds = true
            
            permissionButton.addAction {
                if #available(iOS 14, *) {
                    DispatchQueue.main.async {
                        
                        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                        
                        let openSettingsAction = UIAlertAction(title: Consts.Texts.changeSettings, style: .default) { alertAction in
                            alert.dismiss(animated: true, completion: nil)
                            guard let url = URL(string: UIApplication.openSettingsURLString),
                                    UIApplication.shared.canOpenURL(url) else {
                                        return
                            }

                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                        let openPhotoAccessAction = UIAlertAction(title: Consts.Texts.takeMorePhoto, style: .default) { alertAction in
                            alert.dismiss(animated: true, completion: nil)
                            
                            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                                while let presentedViewController = topController.presentedViewController {
                                    topController = presentedViewController
                                }
                                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: topController)
                            }
                        }
                        let closeAction = UIAlertAction(title: Consts.Texts.cancel, style: .cancel) { alertAction in
                            alert.dismiss(animated: true, completion: nil)
                        }
                        alert.addAction(openSettingsAction)
                        alert.addAction(openPhotoAccessAction)
                        alert.addAction(closeAction)
                        alert.presentGlobally(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var galleryTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var permissionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = UIColor.init("#232735")
        }
    }
    
    @IBOutlet weak var closeButton: UIButton!
  
    @IBOutlet weak var completeButton: UIButton! {
        didSet {
            completeButton.layer.masksToBounds = true
            completeButton.addShadowAndRoundCorner(cornerRadius: 28)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.allowsMultipleSelection = true
            collectionView.register(UINib(nibName: "GalleryCell",
                                          bundle: Consts.bundle),
                                    forCellWithReuseIdentifier: "GalleryCell")
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = .clear
        }
    }
    
    private var selectedIndexes: [Int] = []
    private var maxCount = 0
    
    var assets : PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
    
    private var completeAction: imagePickerAction?
    
    private func getAssetImage(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        var thumbnail = UIImage()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic

        manager.requestImage(for: asset, targetSize: CGSize(width: 1024, height: 1024), contentMode: .default, options: options, resultHandler: {(result, info) -> Void in
            if let result = result {
                thumbnail = result
            }
        })
        return thumbnail
    }
    
    private func updateUI() {
      backgroundColor = theme?.bgColor
      
      titleLabel.text = "\(Consts.Texts.selected) \(selectedIndexes.count) \(Consts.Texts.of) \(maxCount)"
      titleLabel.textColor = theme?.iconColor
      closeButton.imageView?.tintColor = theme?.iconColor
      closeButton.imageView?.image = closeButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
      completeButton.isEnabled = selectedIndexes.count > 0
      completeButton.backgroundColor = theme?.btnBgColor
      completeButton.setTitleColor(theme?.btnTextColor, for: .normal)
      completeButton.imageView?.tintColor = selectedIndexes.count > 0 ? theme?.btnTextColor : theme?.iconColor
      completeButton.imageView?.image = completeButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
    }
    
    public func configure(frame: CGRect, maxCount: Int, completion: @escaping imagePickerAction) {
        self.frame = frame
        PHPhotoLibrary.shared().register(self)
        
        loadImages()
        
        self.completeAction = completion
        
        self.maxCount = maxCount
        updateUI()
        collectionView.reloadData()
    }
    
    private func loadImages() {
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            processStatus(status)
        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            processStatus(status)
        }
    }
    
    private func processStatus(_ status: PHAuthorizationStatus) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if #available(iOS 14, *) {
                if status == .limited {
                    let text = self.permissionLabel.text
                    let height = text?.height(withConstrainedWidth: self.frame.width - 128, font: .systemFont(ofSize: 12)) ?? 0
                    self.galleryTopConstraint.constant = height + 40
                    self.permissionHeightConstraint.constant = height + 16
                } else {
                    self.galleryTopConstraint.constant = 16
                }
            } else {
                self.galleryTopConstraint.constant = 16
            }
            self.permissionView.isHidden = self.galleryTopConstraint.constant == 16
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func pressHide(_ sender: Any) {
        ImageManager.hide(animated: true)
    }
    
    @IBAction func pressCompletete(_ sender: Any) {
        if completeAction != nil {
            var result: [UIImage] = []
            for index in selectedIndexes {
                result.append(self.getAssetImage(asset: assets[index]))
            }
            completeAction!(result)
        }
        ImageManager.hide(animated: true)
    }
}

extension ImageSelector: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let line: CGFloat = (collectionView.bounds.size.width-4)/3
        let size = CGSize(width: line, height: line)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        var alpha: CGFloat = 1
        if !selectedIndexes.contains(indexPath.row) {
            alpha = selectedIndexes.count >= self.maxCount ? 0.5 : 1
        }
        cell.configure(assets[indexPath.row], index: (selectedIndexes.firstIndex(of: indexPath.row) ?? -1)+1, alpha: alpha, theme: theme)
        cell.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let previousCount = selectedIndexes.count
        if selectedIndexes.contains(indexPath.row) {
            selectedIndexes.remove(at: selectedIndexes.firstIndex(of: indexPath.row) ?? 0)
        } else if selectedIndexes.count < self.maxCount {
            selectedIndexes.append(indexPath.row)
        } else {
            return
        }
        
        if (previousCount >= self.maxCount || selectedIndexes.count >= self.maxCount) && previousCount != selectedIndexes.count {
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        } else {
            self.collectionView.reloadItems(at: [indexPath])
        }
        
        self.updateUI()
    }
    
    //MARK: - Update Images
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        loadImages()
    }
}
