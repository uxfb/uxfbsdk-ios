//
//  UIImageView+cache.swift
//  UXFeedbackSDK
//
//  Created by Dmitry Kudryavtsev on 15/06/2019.
//  Copyright © 2019 UXF. All rights reserved.
//


import UIKit
import Foundation

let imageCache: NSCache<AnyObject,AnyObject> = NSCache.init()

extension UIImageView {
    func cacheImage(url: URL){
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url) {
            data, response, error in
            if data != nil {
                DispatchQueue.main.async {
                    let imageToCache = UIImage(data: data!)
                    imageCache.setObject(imageToCache!, forKey: url.absoluteString as AnyObject)
                    self.image = imageToCache
                }
            }
            }.resume()
    }
}
