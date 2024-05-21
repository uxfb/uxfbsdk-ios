//
//  UXFStatisticManager.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 18/04/2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit

let IS_IPAD = (UIDevice.current.userInterfaceIdiom == .pad)

let uid = UIDevice.current.identifierForVendor?.uuidString ?? ""

class StatisticManager {
    class func getDeviceInfo() -> (Dictionary<String, Any>){
        let networkType = Reachability.getNetworkType()
        var device = "unknown"
        if IS_IPAD {
            device = "tablet"
        }
        else if UIDevice.current.userInterfaceIdiom == .phone {
            device = "mobile"
        }
            
        let info: Dictionary<String, Any> =  [ "os" : "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            "deviceVendor" : "apple",
            "deviceModel" : UIDevice.current.model,
            "language" : Locale.current.languageCode ?? "ru",
            "orientation" : UIDevice.current.orientation.isPortrait == true ? "portrait" : "landscape",
            "width" : Int(UIScreen.main.nativeBounds.size.width),
            "height" : Int(UIScreen.main.nativeBounds.size.height),
            "network" : networkType.trackingId,
            "device" : device
        ]
        return info
    }
    
    class func getTimeUTC() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let utcTimeZoneStr = formatter.string(from: date)
        return utcTimeZoneStr
    }
}
