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
    
    lazy var permissionView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme().controlBgColor
        return view
    }()
    
    lazy var permissionLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme().text02Color
        label.text = "Вы предоставили доступ только к некоторым фото. Выберите больше или откройте доступ ко всем фото."
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var permissionButton: UIButton = {
        let button = UIButton(type: .custom)
        let color = UIColor.white
        button.setTitle(Consts.Texts.manage, for: .normal)
        button.setTitleColor(color, for: .normal)
        button.setTitleColor(color.withAlphaComponent(0.5), for: .highlighted)
        button.backgroundColor = Theme().mainColor
        button.layer.cornerRadius = 4.0
        button.layer.masksToBounds = true
        
        button.addAction {
            if #available(iOS 14, *) {
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    
                    let openSettingsAction = UIAlertAction(title: Consts.Texts.changeSettings, style: .default) { alertAction in
                        alert.dismissGlobally(animated: true)
                        guard let url = URL(string: UIApplication.openSettingsURLString),
                              UIApplication.shared.canOpenURL(url) else {
                            return
                        }
                        
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    let openPhotoAccessAction = UIAlertAction(title: Consts.Texts.takeMorePhoto, style: .default) { alertAction in
                        alert.dismissGlobally(animated: true)
                        
                        if var topController = UIApplication.shared.keyWindow?.rootViewController {
                            while let presentedViewController = topController.presentedViewController {
                                topController = presentedViewController
                            }
                            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: topController)
                        }
                    }
                    let closeAction = UIAlertAction(title: Consts.Texts.cancel, style: .cancel) { alertAction in
                        alert.dismissGlobally(animated: true)
                    }
                    alert.addAction(openSettingsAction)
                    alert.addAction(openPhotoAccessAction)
                    alert.addAction(closeAction)
                    alert.presentGlobally(animated: true, completion: nil)
                }
            }
        }
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init("#232735")
        label.textAlignment = .center
        return label
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "close", in: Consts.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(pressHide(_:)), for: .touchUpInside)
        button.imageView?.tintColor = .black.withAlphaComponent(0.6)
        return button
    }()
  
    lazy var completeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.masksToBounds = true
        button.addShadowAndRoundCorner(cornerRadius: 28)
        button.setImage(UIImage(named: "check", in: Consts.bundle, compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(pressCompletete(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = .init(width: 128, height: 128)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.allowsMultipleSelection = true
        collectionView.register(GalleryCell.self,
                                forCellWithReuseIdentifier: String(describing: GalleryCell.self))
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private var topSpaceCollectionView: NSLayoutConstraint!
    
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
    
    private func createViews() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rotated(_ :)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        
        self.addSubview(collectionView)
        self.addSubview(titleLabel)
        self.addSubview(completeButton)
        self.addSubview(closeButton)
        permissionView.addSubview(permissionLabel)
        permissionView.addSubview(permissionButton)
        self.addSubview(permissionView)
        
        createConstraints()
    }
    
    private func createConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        permissionLabel.translatesAutoresizingMaskIntoConstraints = false
        permissionButton.translatesAutoresizingMaskIntoConstraints = false
        permissionView.translatesAutoresizingMaskIntoConstraints = false
        
        topSpaceCollectionView = NSLayoutConstraint(item: collectionView,
                                                    attribute: .top,
                                                    relatedBy: .equal,
                                                    toItem: titleLabel,
                                                    attribute: .bottom,
                                                    multiplier: 1,
                                                    constant: 16)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.heightAnchor.constraint(equalToConstant: 18),
            
            closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            closeButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            
            permissionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            permissionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            permissionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            permissionButton.centerYAnchor.constraint(equalTo: permissionView.centerYAnchor),
            permissionButton.trailingAnchor.constraint(equalTo: permissionView.trailingAnchor, constant: -8),
            permissionButton.heightAnchor.constraint(equalToConstant: 28),
            permissionButton.widthAnchor.constraint(equalToConstant: 104),
            
            permissionLabel.leadingAnchor.constraint(equalTo: permissionView.leadingAnchor, constant: 8),
            permissionLabel.trailingAnchor.constraint(equalTo: permissionButton.leadingAnchor, constant: -8),
            permissionLabel.topAnchor.constraint(equalTo: permissionView.topAnchor, constant: 8),
            permissionLabel.bottomAnchor.constraint(equalTo: permissionView.bottomAnchor, constant: -8),
            
            topSpaceCollectionView,
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            
            completeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            completeButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            completeButton.heightAnchor.constraint(equalToConstant: 56),
            completeButton.widthAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        createViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createViews()
    }
    
    private func updateUI() {
      backgroundColor = theme?.bgColor
      
      titleLabel.text = "\(Consts.Texts.selected) \(selectedIndexes.count) \(Consts.Texts.of) \(maxCount)"
      titleLabel.textColor = theme?.iconColor
      closeButton.imageView?.tintColor = theme?.iconColor
      completeButton.isEnabled = selectedIndexes.count > 0
      completeButton.backgroundColor = theme?.btnBgColor
      completeButton.setTitleColor(theme?.btnTextColor, for: .normal)
      completeButton.imageView?.tintColor = selectedIndexes.count > 0 ? theme?.btnTextColor : theme?.iconColor
      completeButton.imageView?.image = completeButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
    }
    
    @objc
    private func rotated(_ notification: Notification) {
        let dispatchWorkItem = {
            self.collectionView.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: dispatchWorkItem)
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
        var isGranted = false
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if #available(iOS 14, *) {
                if status == .limited {
                    isGranted = false
                } else {
                    isGranted = true
                }
            } else {
                isGranted = true
            }
            self.permissionView.isHidden = isGranted
            self.topSpaceCollectionView.constant = isGranted ? 16 : self.permissionLabel.intrinsicContentSize.height + 16 + 16
            self.layoutIfNeeded()
        }
    }
    
    @objc
    private func pressHide(_ sender: Any) {
        ImageManager.hide(animated: true)
    }
    
    @objc
    private func pressCompletete(_ sender: Any) {
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
