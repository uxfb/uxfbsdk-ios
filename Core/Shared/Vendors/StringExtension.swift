//
//  StringExtension.swift
//  HEXColor-iOS
//
//  Created by Sergey Pugach on 2/2/18.
//  Copyright © 2018 P.D.Q. All rights reserved.
//

import Foundation


extension String {
    /**
     Convert argb string to rgba string.
     */
    public var argb2rgba: String? {
        guard self.hasPrefix("#") else {
            return nil
        }
        
        let hexString: String = String(self[self.index(self.startIndex, offsetBy: 1)...])
        switch hexString.count {
        case 4:
            return "#\(String(hexString[self.index(self.startIndex, offsetBy: 1)...]))\(String(hexString[..<self.index(self.startIndex, offsetBy: 1)]))"
        case 8:
            return "#\(String(hexString[self.index(self.startIndex, offsetBy: 2)...]))\(String(hexString[..<self.index(self.startIndex, offsetBy: 2)]))"
        default:
            return nil
        }
    }
    
    static var randomImageName: String {
        let length: Int = 32
        let letters = "-_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
