//
//  UIImageView+cache.swift
//  UXFeedbackSDK
//
//  Created by Dmitry Kudryavtsev on 15/06/2019.
//  Copyright © 2019 UXF. All rights reserved.
//


import UIKit
import Foundation

internal class ImageCache {
    private init() {
        ImageCache.shared.countLimit = 20
        ImageCache.shared.totalCostLimit = 30 * 1024 * 1024 // 30 MB
    }

    static let shared = NSCache<NSString, UIImage>()
    
    func clearCache() {
        ImageCache.shared.removeAllObjects()
    }
}

extension UIImageView {
    func cacheImage(url: URL, withTemplate: Bool, completion: ((Bool) -> Void)? = nil){
        if let imageFromCache = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
            self.image = imageFromCache
            completion?(true)
            return
        }
        URLSession.shared.dataTask(with: url) {
            data, response, error in
            if data != nil {
                DispatchQueue.main.async {
                    if let imageToCache = UIImage(data: data!) {
                        ImageCache.shared.setObject(imageToCache, forKey: (url.absoluteString as AnyObject) as! NSString)
                        if withTemplate {
                            self.image = imageToCache.withRenderingMode(.alwaysTemplate)
                        } else {
                            self.image = imageToCache.withRenderingMode(.alwaysOriginal)
                        }
                        completion?(true)
                    } else {
                        completion?(false)
                    }
                }
            } else {
                completion?(false)
            }
            }.resume()
    }
    
    func loadImageWithResult(url: URL, withTemplate: Bool, completion: ((UIImage?) -> Void)? = nil){
        if let imageFromCache = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
            completion?(imageFromCache)
            return
        }
        URLSession.shared.dataTask(with: url) {
            data, response, error in
            if data != nil {
                if let imageToCache = UIImage(data: data!) {
                    ImageCache.shared.setObject(imageToCache, forKey: url.absoluteString as NSString)
                    completion?(imageToCache)
                } else {
                    completion?(nil)
                }
            } else {
                completion?(nil)
            }
            }.resume()
    }
}
