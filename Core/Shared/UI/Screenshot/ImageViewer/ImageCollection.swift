//
//  ImageCollection.swift
//  
//
//  Created by Alexander Potemka on 12/02/2019.
//  Copyright © 2019 LLC Andalex. All rights reserved.
//

import UIKit

class ImageCollection: UIView, UIScrollViewDelegate {
    
    var imageViews: [UIImageView] = []
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        return view
    }()
    
    lazy var frontImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var onPageChange: ((String) -> ())?
    
    public var selectedIndex: Int = 0 {
        didSet {
            if onPageChange != nil {
                onPageChange!("\(selectedIndex + 1) \(Consts.Texts.of) \(imageViews.count)")
            }
        }
    }
    
    private func setupSubviews() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rotated(_ :)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        
        addSubview(frontImageView)
        addSubview(scrollView)
        
        frontImageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            frontImageView.topAnchor.constraint(equalTo: self.topAnchor),
            frontImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            frontImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            frontImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    @objc
    private func rotated(_ notification: Notification) {
        let dispatchWorkItem = {
            self.layoutSubviews()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: dispatchWorkItem)
    }
    
    func configure(frame: CGRect, images: [UIImage], currentIndex: Int, onPageChange: @escaping (String) -> () ) {
        self.frame = frame
        frontImageView.isHidden = false
        selectedIndex = currentIndex
        
        for i in 0 ..< images.count {
            imageViews.append(UIImageView(image: images[i]))
        }
        if images.count > 0 {
            frontImageView.image = images[currentIndex]
            frontImageView.frame = frame
        }
        self.onPageChange = onPageChange
        self.layoutIfNeeded()
    }
    
    func updateFrame(frame: CGRect) {
        self.frame = frame
        frontImageView.frame = frame
        self.layoutIfNeeded()
    }
    
    func hideFront() {
        frontImageView.isHidden = true
        
        scrollView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size)
        scrollView.contentSize = CGSize(width: frame.size.width * CGFloat(imageViews.count), height: frame.size.height)
        scrollView.isPagingEnabled = true
        
        scrollView.setContentOffset(CGPoint(x: frame.size.width * CGFloat(selectedIndex), y: 0), animated: false)
        
        for i in 0 ..< imageViews.count {
            imageViews[i].frame = CGRect(x: frame.size.width * CGFloat(i),
                                         y: 0,
                                         width: frame.size.width,
                                         height: frame.size.height)
            imageViews[i].contentMode = .scaleAspectFit
            scrollView.addSubview(imageViews[i])
        }
    }
    
    // MARK: - Scroll
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / UIScreen.main.bounds.width)
        selectedIndex = Int(pageIndex)
    }
}
