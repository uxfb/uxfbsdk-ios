//
//  UIView+Imaga.swift
//  UX Feedback SDK Demo
//
//  Created by Alexander Potemka on 25.05.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit

extension UIView {

    func asImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
}
