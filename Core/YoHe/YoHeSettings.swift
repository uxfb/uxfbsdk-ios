//
//  UXFSettings.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 15.02.2023.
//  Copyright © 2023 UXF. All rights reserved.
//

/// SDK settings class. To create an instance of the default settings, you need to call the ``init()`` method
@objcMembers
open class YoHeSettings: NSObject, SettingsProtocol {
     /// Global campaign display delay timer
     open var globalDelayTimer : Int = 1800
    
     /// Sign of closing in a single swipe down, if false - the form is not closed, but collapsed
     open var closeOnSwipe: Bool = false
    
     /// Enable debug mode to get logs
     open var debugEnabled: Bool = false
    
     /// Displaying the contents of the completed campaign fields to the ``YoHoCampaignDelegate`` method
     open var fieldsEventEnabled: Bool = false
     /// Interval between retries of requests to the server
     open var retryTimeout: Double = 300
     /// Number of retries of requests to the server
     open var retryCount: Int = 3
     /// Server connection timeout
     open var socketTimeout: Double = 5
    
     /// Lock the main application window
     open var slideInUiBlocked: Bool = false
     /// Background color under the slidein campaign form
     open var slideInUiBlackoutColor: String?
     /// Background transparency under the slidein campaign form
     open var slideInUiBlackoutOpacity: Int?
     /// Blur the background below the slidein campaign form
     open var slideInUiBlackoutBlur: Int?
    
     /// Background color under the popup campaign form
     open var popupUiBlackoutColor: String?
     /// Background transparency under the popup campaign form
     open var popupUiBlackoutOpacity: Int?
     /// Blur the background below the popup campaign form
     open var popupUiBlackoutBlur: Int?
    
     /// Server URL in converted format, **Not plain-text!**
     open var endpoint: String?
    
    /// Enabling auto-rotation when changing device orientation
     open var rotateToggle: Bool = true
}
