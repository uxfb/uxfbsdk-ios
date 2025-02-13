//
//  UXFeedbackConsts.swift
//  YoHeSDK
//
//  Created by Alexander Potemka on 21.06.2023.
//  Copyright © 2023 UXF. All rights reserved.
//

import Foundation

internal class Consts {
    static let os: String = "iOS"
    static let version: String = "2.10.0"
    static let cryptoKey: String = "UXFeedback"
    static let defaultHref: String = "https://uxfeedback.ru?utm_campaign=default&utm_medium=app"
    static let defaultEndpoint: String = "https://public-api.uxfeedback.ru"
//    static let defaultEndpoint: String = "https://develop.api.uxfb.dev"
//    static let defaultEndpoint: String = "https://epic-dev-5216-stars.api.uxfb.dev"

    static let apiVersion: String = "v13"
    static let identifier: String  = "biz.andalex.uxfeedback.sdk"
    
    static let bundle: Bundle = Bundle(for: UXFeedback.self)
    
    class Texts {
        static let manage = "Управлять"
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
        static let startScroll = "Начните скроллить экран,\nа потом нажмите на кнопку\n«Применить»"
    }
}
