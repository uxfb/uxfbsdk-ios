//
//  UXFStatisticManager.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 18/04/2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit
import Reachability

class UXFStatisticManager{
    
    static let uxfOSVersionKey = "OS"
    static let uxfScreenOrientationKey = "orientation"
    static let uxfLanguageKey = "language"
    static let uxfScreenResolutionKey = "resolution"
    static let uxfNetworkTypeKey = "network"
    static let uxfDeviceModelKey = "device"
    
    class func getDeviceInfo() -> (Dictionary<String, String>){
        
        let networkType = Reachability.getNetworkType()
        let info: Dictionary<String, String> =  [ uxfOSVersionKey : "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            uxfLanguageKey : Locale.current.languageCode ?? "ru",
            uxfScreenOrientationKey : UIDevice.current.orientation.isPortrait == true ? "portrait" : "landscape",
            uxfScreenResolutionKey : "\(Int(UIScreen.main.nativeBounds.size.width))x\(Int(UIScreen.main.nativeBounds.size.height))",
            uxfNetworkTypeKey : networkType.trackingId,
            uxfDeviceModelKey : UIDevice.current.model
        ]
        return info
    }
    
}
