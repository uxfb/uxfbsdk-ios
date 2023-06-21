//
//  UXFeedbackDelegate.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit

/// Интерфейс обработчика различных событий от SDK
@objc
public protocol UXFeedbackCampaignDelegate: FeedbackCampaignDelegate {
    /// Событие после загрузки кампаний с сервера
    /// - Parameter success: Признак успеха загрузки
    func campaignDidLoad(success: Bool)
    /// Событие получения ошибки при работе SDK
    /// - Parameter errorString: Текст ошибки
    func campaignDidReceiveError(errorString: String)
    /// Событие после показа формы кампании
    /// - Parameter eventName: Имя переданного в startCampaign события
    func campaignDidShow(eventName: String)
    /// Событие закрытия формы кампании
    /// - Parameter eventName: Имя переданного в startCampaign события
    func campaignDidClose(eventName: String)
    /// Событие прерывания прохождения кампании
    /// - Parameters:
    ///   - eventName: Имя переданного в startCampaign события
    ///   - terminatedPage: Страница, на которой прохождение кампании было прервано
    ///   - totalPages: Общее количество страниц кампании
    func campaignDidTerminate(eventName: String, terminatedPage: Int, totalPages: Int)
    /// Событие отправки результатов кампании на сервер
    /// - Parameter campaignId: Идентификатор кампании
    func campaignDidSend(campaignId: String)
    /// Событие завершения прохождения кампании с получением ответов
    /// - Parameters:
    ///   - campaignId: Идентификатор кампании
    ///   - answers: Массив ответов в формате Ключ: Значение, где ключ - идентификатор блока
    func campaignDidAnswered(campaignId: String, answers: [String: Any])
}


/// Интерфейс обработчика событий лога от SDK
@objc
public protocol UXFeedbackLogDelegate: FeedbackLogDelegate {
    /// Событие получения сообщения лога
    /// - Parameter message: Текст лога
    func logDidReceive(message: String)
}
