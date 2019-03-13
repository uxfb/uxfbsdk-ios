//
//  UXFTheme.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit

public struct UXFTheme {
    
    public var colors: UXFTheme.Colors
    
    public var fonts: UXFTheme.Fonts
    
    public var images: UXFTheme.Images
    
    public var statusBarStyle: UIStatusBarStyle?
    
    public struct Colors {
        
        public var title: UIColor?
    }

    public struct Images {
        
        public var enabledEmoticons: [UIImage]
        
        public var disabledEmoticons: [UIImage]?
        
       // public var star: UIImage
        
       // public var starOutline: UIImage
    }
    
    public struct Fonts {
        
        public var titleSize: CGFloat
        
        public var textSize: CGFloat
        
        public var miniSize: CGFloat
        
        public var regular: UIFont?
        
        public var bold: UIFont?
    }
}
