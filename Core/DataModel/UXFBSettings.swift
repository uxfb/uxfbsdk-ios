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
    /// Глобальный таймер задержки показа кампании
    open var globalDelayTimer : Int = 1800
    
    /// Признак закрытия в однократный свайп вниз, если false - форма не закрывается, а сворачивается
    open var closeOnSwipe: Bool = false
    
    /// Включение режима дебага для получения логов
    open var debugEnabled: Bool = false
    
    /// Вывод содержимого полей пройденной кампании в метод ``UXFeedbackCampaignDelegate``
    open var fieldsEventEnabled: Bool = false
    /// Интервал между повторными попытками запросов к серверу
    open var retryTimeout: Double = 300
    /// Количество повторных попыток запросов к серверу
    open var retryCount: Int = 3
    /// Таймаут подключения к серверу
    open var socketTimeout: Double = 5
    
    /// Блокировка основного окна приложения
    open var slideInUiBlocked: Bool = false
    /// Цвет фона под формой slidein-кампании
    open var slideInUiBlackoutColor: String?
    /// Прозрачность фона под формой slidein-кампании
    open var slideInUiBlackoutOpacity: Int?
    /// Блюр фона под формой slidein-кампании
    open var slideInUiBlackoutBlur: Int?
    
    /// Цвет фона под формой popup-кампании
    open var popupUiBlackoutColor: String?
    /// Прозрачность фона под формой popup-кампании
    open var popupUiBlackoutOpacity: Int?
    /// Блюр фона под формой popup-кампании
    open var popupUiBlackoutBlur: Int?
    
    /// URL сервера в преобразованном формате, **Не plain-text!**
    open var endpoint: String?
    
    public override init() {
        super.init()
    }
}
