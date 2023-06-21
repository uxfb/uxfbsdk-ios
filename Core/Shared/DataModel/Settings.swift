//
//  UXFSettings.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 15.02.2023.
//  Copyright © 2023 UXF. All rights reserved.
//

/// Класс настроек SDK. Для создания экземпляра настроек по умолчанию необходимо вызвать метод ``init()``
@objcMembers
open class Settings: NSObject {
    open var globalDelayTimer: Int = 1800
    open var closeOnSwipe: Bool = false
    open var debugEnabled: Bool = false
    open var fieldsEventEnabled: Bool = false
    open var retryTimeout: Double = 300
    open var retryCount: Int = 3
    open var socketTimeout: Double = 5
    open var slideInUiBlocked: Bool = false
    open var slideInUiBlackoutColor: String?
    open var slideInUiBlackoutOpacity: Int?
    open var slideInUiBlackoutBlur: Int?
    open var popupUiBlackoutColor: String?
    open var popupUiBlackoutOpacity: Int?
    open var popupUiBlackoutBlur: Int?
    open var endpoint: String?
    
    public override init() {
        super.init()
    }
}
