//
//  UXFeedbackConsts.swift
//  YoHeSDK
//
//  Created by Alexander Potemka on 21.06.2023.
//  Copyright © 2023 UXF. All rights reserved.
//

import Foundation

internal class Consts {
    static let version: String = "v2.0.1"
    static let cryptoKey: String = "UXFeedback"
    static let defaultEndpoint: String = "https://public-api.uxfeedback.ru"
    static let apiVersion: String = "v8"
//    static let defaultEndpoint: String = "https://develop.api.uxfb.space"
    static let identifier: String  = "biz.andalex.yohe.sdk"
    
    static let bundle: Bundle = Bundle(for: UXFeedback.self)
    
    class Texts {
        static let close = "Закрыть"
        static let cancel = "Отмена"
        static let selected = "Выбрано:"
        static let screenshots = "Скриншоты:"
        static let of = "из"
        static let screenshotDeleteInfo = "Скриншот будет удален, без возможности восстановления"
        static let screenshotDeleteFuture = "В дальнейшем вы сможете загрузить его повторно из галереи"
        static let screenshotDeleteQuestion = "Удалить скриншот?"
        static let noDelete = "Не удалять"
        static let delete = "Удалить"
        
        static let screenshotMaxCount = "Вы загрузили максимальное количество скриншотов"
        static let screenshotMaxCountNext = "Для загрузки новых скриншотов, удалите ненужные"
        static let okay = "Понятно"
        static let changeSettings = "Изменить настройки"
        static let takeMorePhoto = "Выбрать больше фото"
        
        static let information = "Информация"
        static let noPhotoAccess = "Нет доступа к фотографиям устройства"
        static let wantToPhotoAccess = "хочет получить доступ к вашим фотографиям"
        static let noOnePhotoAccess = "Доступ не предоставлен ни к одной фотографии"
        
        static let changeChoice = "Изменить выбор"
        static let goSettingsAccess = "Перейдите в настройки, чтобы разрешить доступ"
        static let openSettings = "Открыть настройки"
    }
}
