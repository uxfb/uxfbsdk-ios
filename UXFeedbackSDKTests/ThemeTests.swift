import XCTest
@testable import UXFeedbackSDK

final class ThemeTypeTests: XCTestCase {

    func testThemeTypeRawValues() {
        XCTAssertEqual(ThemeType.custom.rawValue, 0)
        XCTAssertEqual(ThemeType.light.rawValue, 1)
        XCTAssertEqual(ThemeType.dark.rawValue, 2)
    }

    func testThemeTypeFromRawValue() {
        XCTAssertEqual(ThemeType(rawValue: 0), .custom)
        XCTAssertEqual(ThemeType(rawValue: 1), .light)
        XCTAssertEqual(ThemeType(rawValue: 2), .dark)
        XCTAssertNil(ThemeType(rawValue: 99))
    }
}

final class ThemeTests: XCTestCase {

    func testDefaultThemeInitialization() {
        let theme = Theme()

        XCTAssertEqual(theme.btnBorderRadius, 12)
        XCTAssertEqual(theme.formBorderRadius, 8)
        XCTAssertNotNil(theme.bgColor)
        XCTAssertNotNil(theme.mainColor)
        XCTAssertNotNil(theme.btnBgColor)
        XCTAssertNotNil(theme.fontH1)
        XCTAssertNotNil(theme.fontH2)
        XCTAssertNotNil(theme.fontP1)
        XCTAssertNotNil(theme.fontP2)
        XCTAssertNotNil(theme.fontBtn)
        XCTAssertNotNil(theme.fontCaption)
    }

    func testThemeDecodingWithAllColors() throws {
        let json: [String: Any] = [
            "bgColor": "#FFFFFF",
            "mainColor": "#536CED",
            "iconColor": "#B5B8C2",
            "text01Color": "#232735",
            "text02Color": "#505565",
            "text03Color": "#8B90A0",
            "inputBgColor": "#F8F8FA",
            "inputBorderColor": "#D3D4D8",
            "controlBgColor": "#FFFFFF",
            "controlBgColorActive": "#F8F8FA",
            "controlIconColor": "#FFFFFF",
            "errorColorPrimary": "#F15E61",
            "errorColorSecondary": "#F15E61",
            "btnBgColor": "#536CED",
            "btnBgColorActive": "#2D3CA6",
            "btnTextColor": "#FFFFFF",
            "btnBorderRadius": 20,
            "formBorderRadius": 12,
            "iconStarColor": "#FFCA28",
            "iconSmile1Color": "#FFCA28",
            "iconSmile2Color": "#232735",
            "iconSmile3Color": "#E84047"
        ]

        let data = try JSONSerialization.data(withJSONObject: json)
        let theme = try JSONDecoder().decode(Theme.self, from: data)

        XCTAssertEqual(theme.btnBorderRadius, 20)
        XCTAssertEqual(theme.formBorderRadius, 12)
    }

    func testThemeDecodingWithPartialData() throws {
        let json: [String: Any] = [
            "bgColor": "#FF0000",
            "btnBorderRadius": 8
        ]

        let data = try JSONSerialization.data(withJSONObject: json)
        let theme = try JSONDecoder().decode(Theme.self, from: data)

        XCTAssertEqual(theme.btnBorderRadius, 8)
        XCTAssertEqual(theme.formBorderRadius, 8)
    }

    func testThemeDecodingEmptyJSON() throws {
        let data = "{}".data(using: .utf8)!
        let theme = try JSONDecoder().decode(Theme.self, from: data)

        XCTAssertEqual(theme.btnBorderRadius, 12)
        XCTAssertEqual(theme.formBorderRadius, 8)
    }

    func testThemeConformsToProtocol() {
        let theme = Theme()
        let protocol_: ThemeProtocol = theme

        XCTAssertNotNil(protocol_.bgColor)
        XCTAssertNotNil(protocol_.mainColor)
        XCTAssertNotNil(protocol_.fontH1)
    }

    func testDefaultFontSizes() {
        let theme = Theme()

        XCTAssertEqual(theme.fontH1.pointSize, 22)
        XCTAssertEqual(theme.fontH2.pointSize, 17)
        XCTAssertEqual(theme.fontP1.pointSize, 17)
        XCTAssertEqual(theme.fontP2.pointSize, 14)
        XCTAssertEqual(theme.fontBtn.pointSize, 16)
        XCTAssertEqual(theme.fontCaption.pointSize, 16)
    }
}

final class BlackoutTests: XCTestCase {

    func testDefaultBlackout() {
        let blackout = Blackout()
        XCTAssertEqual(blackout.color, .clear)
        XCTAssertEqual(blackout.opacity, 0)
        XCTAssertEqual(blackout.blur, 0)
    }

    func testConvenienceInit() {
        let blackout = Blackout(color: .black, opacity: 50, blur: 10)
        XCTAssertEqual(blackout.color, .black)
        XCTAssertEqual(blackout.opacity, 50)
        XCTAssertEqual(blackout.blur, 10)
    }
}

// MARK: - UIColor HEX Extension Tests

final class UIColorHexTests: XCTestCase {

    func testHex6Init() {
        let color = UIColor(hex6: 0xFF0000)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)

        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 0.0, accuracy: 0.01)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
    }

    func testColorFromHexString() {
        let color = UIColor("#FF0000")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)

        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 0.0, accuracy: 0.01)
    }

    func testColorFromHex3String() throws {
        let color = try UIColor(rgba_throws: "#FFF")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)

        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(g, 1.0, accuracy: 0.01)
        XCTAssertEqual(b, 1.0, accuracy: 0.01)
    }

    func testColorFromHex8String() throws {
        let color = try UIColor(rgba_throws: "#FF0000FF")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)

        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
    }

    func testInvalidHexStringThrows() {
        XCTAssertThrowsError(try UIColor(rgba_throws: "invalid")) { error in
            XCTAssertTrue(error is UIColorInputError)
        }
    }

    func testMissingHashPrefixThrows() {
        XCTAssertThrowsError(try UIColor(rgba_throws: "FF0000")) { error in
            XCTAssertTrue(error is UIColorInputError)
        }
    }

    func testInvalidLengthThrows() {
        XCTAssertThrowsError(try UIColor(rgba_throws: "#FF00"))
    }

    func testHexStringOutput() throws {
        let color = UIColor(hex6: 0xFF0000)
        let hexString = try color.hexStringThrows(false)
        XCTAssertEqual(hexString, "#FF0000")
    }

    func testHexStringWithAlpha() throws {
        let color = UIColor(hex6: 0xFF0000)
        let hexString = try color.hexStringThrows(true)
        XCTAssertEqual(hexString, "#FF0000FF")
    }

    func testDefaultColorOnInvalidHex() {
        let color = UIColor("invalid", defaultColor: .blue)
        XCTAssertEqual(color, UIColor.blue)
    }

    func testHexStringFallbackEmpty() {
        let color = UIColor(white: 2.0, alpha: 1.0)
        let hexString = color.hexString()
        XCTAssertEqual(hexString, "")
    }
}
