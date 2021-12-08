//
//  ImageCollection.swift
//  StayClean
//
//  Created by Alexander Potemka on 12/02/2019.
//  Copyright © 2019 LLC Andalex. All rights reserved.
//

import UIKit

class UXFImageCollection: UIView, UIScrollViewDelegate {
    
    var imageViews: [UIImageView] = []
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
            
        }
    }
    
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var frontImageView: UIImageView!
    
    var onPageChange: ((String) -> ())?
    
    public var selectedIndex: Int = 0 {
        didSet {
            if onPageChange != nil {
                onPageChange!("\(selectedIndex + 1) из \(imageViews.count)")
            }
        }
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
