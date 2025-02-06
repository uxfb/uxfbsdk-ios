//
//  UXFSettings.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 15.02.2023.
//  Copyright © 2023 UXF. All rights reserved.
//

import Foundation

protocol SettingsProtocol {
    var globalDelayTimer: Int { get set }
    var closeOnSwipe: Bool { get set }
    var debugEnabled: Bool { get set }
    var fieldsEventEnabled: Bool { get set }
    var retryTimeout: Double { get set }
    var retryCount: Int { get set }
    var socketTimeout: Double { get set }
    var slideInUiBlocked: Bool { get set }
    var slideInUiBlackoutColor: String? { get set }
    var slideInUiBlackoutOpacity: Int { get set }
    var slideInUiBlackoutBlur: Int { get set }
    var popupUiBlackoutColor: String? { get set }
    var popupUiBlackoutOpacity: Int { get set }
    var popupUiBlackoutBlur: Int { get set }
    var endpoint: String? { get set }
    var rotateToggle: Bool { get set }
    var sdkPlatform: String? { get set }
    var sdkPlatformVersion: String? { get set }
}
