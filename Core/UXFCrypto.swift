//
//  UXFCrypto.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 02.02.2022.
//  Copyright © 2022 UXF. All rights reserved.
//

import Foundation

class UXFCrypto: NSObject {
    
    public var uid: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    private let key = "UXFeedback"
    
    private func utf8(_ input: Character) -> UInt8 {
        let utf8 = String(input).utf8
        return utf8[utf8.startIndex]
    }
    
    private func encrypt(_ input: String) -> String {
        var result = ""
        result = xor("\(key)#\(input)")
        result = Data(result.utf8).base64EncodedString()
        
        return result
    }
    
    func decrypt(_ input: String) -> String {
        var result = ""
        guard let data = Data(base64Encoded: input) else {
            return result
        }

        let fullString = xor(String(data: data, encoding: .utf8) ?? "")
        let strArray = fullString.split(separator: "#")
        if strArray.count == 2 {
            result = String(strArray[1])
        }
        return result
    }
    
    private func xor(_ input: String) -> String {
        let key = self.key.map { $0 }
        let length = key.count
        var output = ""
        
        for i in input.enumerated() {
            let byte = [utf8(i.element) ^ utf8(key[i.offset % length])]
            output.append(String(bytes: byte, encoding: .utf8)!)
        }
        
        return output
    }
}
