//
//  UXFBTheme.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation

/// Класс темы SDK. Для создания экземпляра настроек по умолчанию необходимо вызвать метод ``init()``.  **ВАЖНО**: все цвета задаются в формате HEX с решеткой в начале, например #ABC123
@objcMembers
open class UXFBTheme: NSObject, ThemeProtocol {
    
    /// Цвет текста счетчика страниц, плейсхолдеров, чекбоксов и радиокнопок в нормальном состоянии
    open var text03Color: UIColor = UIColor.init("#8B90A0")
    /// Цвет бордера инпутов в нормальном состоянии
    open var inputBorderColor: UIColor =  UIColor.init("#D3D4D8")
    /// Цвет иконки кнопки закрытия, полоски NPS/рейтинга, обводки чекбокса и радиокнопки в нормальном состоянии
    open var iconColor: UIColor =  UIColor.init("#B5B8C2")
    /// Цвет кнопки в состоянии highlighted
    open var btnBgColorActive: UIColor =  UIColor.init("#1983C8")
    /// Радиус скругления кнопки
    open var btnBorderRadius: CGFloat = 4
    /// Цвет бордера инпута в состонии ошибки
    open var errorColorSecondary: UIColor =  UIColor.init("#F4A0A3")
    /// Цвет подписи текста ошибки к блоку, цвет NPS/рейтинга в состонии ошибки
    open var errorColorPrimary: UIColor =  UIColor.init("#E84047")
    /// Основной цвет - курсор в инпуте и внутренней обводки инпута в фокусе, иконок активного чекбокса и радиокнопок
    open var mainColor: UIColor =  UIColor.init("#0076C2")
    /// Цвет фона чекбокса, радиокнопки и кнопки скриншота в выбранном состоянии
    open var controlBgColorActive: UIColor =  UIColor.init("#DBF1FF")
    /// Радиус скругления формы
    open var formBorderRadius: CGFloat = 8
    /// Цвет фона инпута
    open var inputBgColor: UIColor =  UIColor.init("#F3F3F3")
    /// Цвет текста заголовка и контента всех блоков
    open var text01Color: UIColor =  UIColor.init("#232735")
    /// Цвет фона чекбокса, радиокнопки и кнопки скриншота в нормальном состоянии
    open var controlBgColor: UIColor =  UIColor.init("#F3F3F3")
    /// Цвет иконки чекбокса, радиокнопки и ползунка NPS/рейтинга
    open var controlIconColor: UIColor =  UIColor.init("#FFFFFF")
    /// Цвет фона кнопок
    open var btnBgColor: UIColor =  UIColor.init("#0076C2")
    /// Цвет блока отображения текстовой информации
    open var text02Color: UIColor =  UIColor.init("#505565")
    /// Цвет текста кнопок
    open var btnTextColor: UIColor =  UIColor.init("#FFFFFF")
    /// Цвет фона формы
    open var bgColor: UIColor =  UIColor.init("#FFFFFF")
    /// Цвет звезд
    open var iconRating: UIColor = UIColor.init("#FECA00")
    
    /// Цвета смайлов
    open var iconRating2: UIColor = UIColor.init("#FECA00") //желтый
    open var iconRating3: UIColor = UIColor.init("#232735") //черный
    open var iconRating4: UIColor = UIColor.init("#E84047") //красный
    
    /// Шрифт заголовка формы. По умолчанию System:Semibold:22
    open var fontH1: UIFont = .systemFont(ofSize: 22,
                                              weight: .semibold)
    
    /// Шрифт заголовка блока. По умолчанию System:Semibold:17
    open var fontH2: UIFont = .systemFont(ofSize: 17,
                                              weight: .semibold)
    
    /// Шрифт всех элементов формы. По умолчанию System:Regular:17
    open var fontP1: UIFont = .systemFont(ofSize: 17,
                                              weight: .regular)
    
    /// Шрифт подписей к блокам. По умолчанию System:Regular:14
    open var fontP2: UIFont = .systemFont(ofSize: 14,
                                              weight: .regular)
    
    /// Шрифт кнопок. По умолчанию System:Semibold:16
    open var fontBtn: UIFont = .systemFont(ofSize: 16,
                                             weight: .semibold)
    
    /// Инициализация объекта темы
    public override init() {
        super.init()
    }
}
