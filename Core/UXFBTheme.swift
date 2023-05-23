//
//  UXFBTheme.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation

enum UXFBThemeType: Int {
    case custom = 0                    
    case light = 1
    case dark = 2
}

class UXFBBlackout: NSObject {
    var color: UIColor = .clear
    var opacity: Int = 0
    var blur: Int = 0
    
    convenience init(color: UIColor, opacity: Int, blur: Int) {
        self.init()
        self.color = color
        self.opacity = opacity
        self.blur = blur
    }
}

/// Класс темы SDK. Для создания экземпляра настроек по умолчанию необходимо вызвать метод ``init()``.  **ВАЖНО**: все цвета задаются в формате HEX с решеткой в начале, например #ABC123
@objcMembers
open class UXFBTheme: NSObject, Decodable {
    /// Цвет текста счетчика страниц, плейсхолдеров, чекбоксов и радиокнопок в нормальном состоянии
    open var text03Color: UIColor =  UIColor.init("#8B90A0")
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
    
    private var _fontH1: UIFont = .systemFont(ofSize: 22,
                                              weight: .semibold)
    /// Шрифт заголовка формы. По умолчанию System:Semibold:22
    open var fontH1: UIFont {
        get{
            return _fontH1
        }
        set{
            _fontH1 = newValue
        }
    }
    
    private var _fontH2: UIFont = .systemFont(ofSize: 17,
                                              weight: .semibold)
    /// Шрифт заголовка блока. По умолчанию System:Semibold:17
    open var fontH2: UIFont {
        get{
            return _fontH2
        }
        set{
            _fontH2 = newValue
        }
    }
    
    private var _fontP1: UIFont = .systemFont(ofSize: 17,
                                              weight: .regular)
    /// Шрифт всех элементов формы. По умолчанию System:Regular:17
    open var fontP1: UIFont {
        get{
            return _fontP1
        }
        set{
            _fontP1 = newValue
        }
    }
    
    private var _fontP2: UIFont = .systemFont(ofSize: 14,
                                              weight: .regular)
    /// Шрифт подписей к блокам. По умолчанию System:Regular:14
    open var fontP2: UIFont {
        get{
            return _fontP2
        }
        set{
            _fontP2 = newValue
        }
    }
    
    private var _fontBtn: UIFont = .systemFont(ofSize: 16,
                                             weight: .semibold)
    /// Шрифт кнопок. По умолчанию System:Semibold:16
    open var fontBtn: UIFont {
        get{
            return _fontBtn
        }
        set{
            _fontBtn = newValue
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case bgColor
        case iconColor
        case mainColor
        case btnBgColor
        case text01Color
        case text02Color
        case text03Color
        case btnTextColor
        case inputBgColor
        case controlBgColor
        case btnBorderRadius
        case btnBgColorActive
        case controlIconColor
        case formBorderRadius
        case inputBorderColor
        case errorColorSecondary
        case errorColorPrimary
        case controlBgColorActive
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let radius: CGFloat =  try? container.decode(CGFloat.self, forKey: .btnBorderRadius) {
            self.btnBorderRadius = radius
        }
        if let radius: CGFloat =  try? container.decode(CGFloat.self, forKey: .formBorderRadius) {
            self.formBorderRadius = radius
        }
        if let text03ColorString = try? container.decode(String.self, forKey: .text03Color){
           self.text03Color = UIColor.init(text03ColorString)
        }
        if let iconColorString = try? container.decode(String.self, forKey: .iconColor){
            self.iconColor = UIColor.init(iconColorString)
        }
        if let btnBgColorActiveString = try? container.decode(String.self, forKey: .btnBgColorActive){
            self.btnBgColorActive = UIColor.init(btnBgColorActiveString)
        }
        if let errorColorSecondaryString = try? container.decode(String.self, forKey: .errorColorSecondary){
            self.errorColorSecondary = UIColor.init(errorColorSecondaryString)
        }
        if let errorColorPrimaryString = try? container.decode(String.self, forKey: .errorColorPrimary){
            self.errorColorPrimary = UIColor.init(errorColorPrimaryString)
        }
        if let mainColorString = try? container.decode(String.self, forKey: .mainColor){
            self.mainColor = UIColor.init(mainColorString)
        }
        if let controlBgColorActiveString = try? container.decode(String.self, forKey: .controlBgColorActive){
            self.controlBgColorActive = UIColor.init(controlBgColorActiveString)
        }
        if let inputBgColorString = try? container.decode(String.self, forKey: .inputBgColor){
            self.inputBgColor = UIColor.init(inputBgColorString)
        }
        if let controlBgColorString = try? container.decode(String.self, forKey: .controlBgColor){
            self.controlBgColor = UIColor.init(controlBgColorString)
        }
        if let controlIconColorString = try? container.decode(String.self, forKey: .controlIconColor){
            self.controlIconColor = UIColor.init(controlIconColorString)
        }
        if let btnBgColorString = try? container.decode(String.self, forKey: .btnBgColor){
            self.btnBgColor = UIColor.init(btnBgColorString)
        }
        if let text02ColorString = try? container.decode(String.self, forKey: .text02Color){
            self.text02Color = UIColor.init(text02ColorString)
        }
        if let btnTextColorString = try? container.decode(String.self, forKey: .btnTextColor){
            self.btnTextColor = UIColor.init(btnTextColorString)
        }
        if let bgColorString = try? container.decode(String.self, forKey: .bgColor){
            self.bgColor = UIColor.init(bgColorString)
        }
    }
    
    public override init() {
        super.init()
    }
}
