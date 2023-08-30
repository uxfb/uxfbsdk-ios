//
//  YoHeConsts.swift
//  YoHeSDK
//
//  Created by Alexander Potemka on 21.06.2023.
//  Copyright © 2023 UXF. All rights reserved.
//

import Foundation

internal class Consts {
    static let cryptoKey: String = "YoHe"
    static let version: String = "v1.1.0"
    static let defaultEndpoint: String = "https://public-api.yohe.io"
//    static let defaultEndpoint: String = "https://develop.api.uxfb.space"
    static let apiVersion: String = "v8"
    static let identifier: String  = "biz.andalex.yohe.sdk"
    
    static let bundle: Bundle = Bundle(for: YoHe.self)
    
    class Texts {
         static let close = "Close"
         static let cancel = "Cancel"
         static let selected = "Selected:"
         static let screenshots = "Screenshots:"
         static let of = "of"
         static let screenshotDeleteInfo = "Screenshot will be permanently deleted"
         static let screenshotDeleteFuture = "You can re-download it from the gallery later"
         static let screenshotDeleteQuestion = "Do you want to delete a screenshot?"
         static let noDelete = "Do not delete"
         static let delete = "Delete"
        
         static let screenshotMaxCount = "You have uploaded the maximum number of screenshots"
         static let screenshotMaxCountNext = "To upload new screenshots, delete the ones you don't need"
         static let okay = "I see"
         static let changeSettings = "Change settings"
         static let takeMorePhoto = "Select More Photos"
        
         static let information = "Information"
         static let noPhotoAccess = "No access to device photos"
         static let wantToPhotoAccess = "wants to access your photos"
         static let noOnePhotoAccess = "No photo access has been granted"
        
         static let changeChoice = "Change Choice"
         static let goSettingsAccess = "Go to settings to allow access"
         static let openSettings = "Open Settings"
         static let startScroll = "Start scrolling the screen,\nthen press the button\n«Apply»"
     }
}
