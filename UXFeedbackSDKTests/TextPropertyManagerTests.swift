import XCTest
@testable import UXFeedbackSDK

final class TextPropertyManagerTests: XCTestCase {

    private let theme = Theme()

    // MARK: - Basic Conversion

    func testConvertPlainText() {
        let result = TextPropertyManager.convert("Hello World",
                                                  theme: theme,
                                                  defaultFont: theme.fontH1,
                                                  textProperties: nil,
                                                  withRequired: false)

        XCTAssertEqual(result.string, "Hello World")
    }

    func testConvertWithRequired() {
        let result = TextPropertyManager.convert("Field Label",
                                                  theme: theme,
                                                  defaultFont: theme.fontH1,
                                                  textProperties: nil,
                                                  withRequired: true)

        XCTAssertTrue(result.string.hasPrefix("* "))
        XCTAssertTrue(result.string.contains("Field Label"))
    }

    func testConvertWithoutRequired() {
        let result = TextPropertyManager.convert("Field Label",
                                                  theme: theme,
                                                  defaultFont: theme.fontH1,
                                                  textProperties: nil,
                                                  withRequired: false)

        XCTAssertFalse(result.string.hasPrefix("*"))
    }

    // MARK: - Alignment Tags

    func testLeftAlignmentTagRemoved() {
        let result = TextPropertyManager.convert("<left>Left aligned",
                                                  theme: theme,
                                                  defaultFont: theme.fontH1,
                                                  textProperties: nil,
                                                  withRequired: false)

        XCTAssertFalse(result.string.contains("<left>"))
        XCTAssertTrue(result.string.contains("Left aligned"))
    }

    func testCenterAlignmentTagRemoved() {
        let result = TextPropertyManager.convert("<center>Center aligned",
                                                  theme: theme,
                                                  defaultFont: theme.fontH1,
                                                  textProperties: nil,
                                                  withRequired: false)

        XCTAssertFalse(result.string.contains("<center>"))
        XCTAssertTrue(result.string.contains("Center aligned"))
    }

    func testRightAlignmentTagRemoved() {
        let result = TextPropertyManager.convert("<right>Right aligned",
                                                  theme: theme,
                                                  defaultFont: theme.fontH1,
                                                  textProperties: nil,
                                                  withRequired: false)

        XCTAssertFalse(result.string.contains("<right>"))
        XCTAssertTrue(result.string.contains("Right aligned"))
    }

    // MARK: - Style Tags

    func testBoldTagApplied() {
        let result = TextPropertyManager.convert("<str>Bold text<str>",
                                                  theme: theme,
                                                  defaultFont: theme.fontH1,
                                                  textProperties: nil,
                                                  withRequired: false)

        XCTAssertFalse(result.string.contains("<str>"))
        XCTAssertTrue(result.string.contains("Bold text"))
    }

    func testItalicTagApplied() {
        let result = TextPropertyManager.convert("<em>Italic text<em>",
                                                  theme: theme,
                                                  defaultFont: theme.fontH1,
                                                  textProperties: nil,
                                                  withRequired: false)

        XCTAssertFalse(result.string.contains("<em>"))
        XCTAssertTrue(result.string.contains("Italic text"))
    }

    func testStrikethroughTagApplied() {
        let result = TextPropertyManager.convert("<s>Strikethrough<s>",
                                                  theme: theme,
                                                  defaultFont: theme.fontH1,
                                                  textProperties: nil,
                                                  withRequired: false)

        XCTAssertFalse(result.string.contains("<s>"))
        XCTAssertTrue(result.string.contains("Strikethrough"))
    }

    // MARK: - Link Tags

    func testLinkTagParsed() {
        let result = TextPropertyManager.convert("<a>Click here|https://example.com<a>",
                                                  theme: theme,
                                                  defaultFont: theme.fontH1,
                                                  textProperties: nil,
                                                  withRequired: false)

        XCTAssertFalse(result.string.contains("<a>"))
        XCTAssertTrue(result.string.contains("Click here"))
        XCTAssertFalse(result.string.contains("https://example.com"))
    }

    // MARK: - Size Tags

    func testBigSizeTagRemoved() {
        let result = TextPropertyManager.convert("<#><h1>Big heading",
                                                  theme: theme,
                                                  defaultFont: theme.fontH1,
                                                  textProperties: nil,
                                                  withRequired: false)

        XCTAssertFalse(result.string.contains("<#>"))
        XCTAssertFalse(result.string.contains("<h1>"))
        XCTAssertTrue(result.string.contains("Big heading"))
    }

    func testSmallSizeTagRemoved() {
        let result = TextPropertyManager.convert("<##><p>Small text",
                                                  theme: theme,
                                                  defaultFont: theme.fontP1,
                                                  textProperties: nil,
                                                  withRequired: false)

        XCTAssertFalse(result.string.contains("<##>"))
        XCTAssertFalse(result.string.contains("<p>"))
        XCTAssertTrue(result.string.contains("Small text"))
    }

    // MARK: - Combined Tags

    func testCombinedTags() {
        let result = TextPropertyManager.convert("<center><str>Bold<str> and <em>italic<em> text",
                                                  theme: theme,
                                                  defaultFont: theme.fontH1,
                                                  textProperties: nil,
                                                  withRequired: false)

        XCTAssertFalse(result.string.contains("<center>"))
        XCTAssertFalse(result.string.contains("<str>"))
        XCTAssertFalse(result.string.contains("<em>"))
        XCTAssertTrue(result.string.contains("Bold"))
        XCTAssertTrue(result.string.contains("italic"))
    }

    // MARK: - Height Calculation

    func testHeightForAttributedString() {
        let attrString = NSAttributedString(string: "Test text",
                                             attributes: [.font: UIFont.systemFont(ofSize: 14)])
        let height = TextPropertyManager.heightForAttributed(string: attrString, and: 200)

        XCTAssertGreaterThan(height, 0)
    }

    func testHeightForEmptyString() {
        let attrString = NSAttributedString(string: "")
        let height = TextPropertyManager.heightForAttributed(string: attrString, and: 200)

        XCTAssertEqual(height, 0)
    }

    func testHeightIncreasesWithNarrowerWidth() {
        let attrString = NSAttributedString(string: "This is a long text that should wrap across multiple lines when displayed in a narrow container",
                                             attributes: [.font: UIFont.systemFont(ofSize: 14)])

        let wideHeight = TextPropertyManager.heightForAttributed(string: attrString, and: 500)
        let narrowHeight = TextPropertyManager.heightForAttributed(string: attrString, and: 100)

        XCTAssertGreaterThanOrEqual(narrowHeight, wideHeight)
    }

    // MARK: - Custom TextProperties

    func testConvertWithCustomTextProperties() {
        let customProps = TextProperties(
            h1: [TextProperty(name: "#", type: "size", value: "2,0/2,0")],
            h2: nil,
            p: nil
        )

        let result = TextPropertyManager.convert("<#><h1>Large heading",
                                                  theme: theme,
                                                  defaultFont: theme.fontH1,
                                                  textProperties: customProps,
                                                  withRequired: false)

        XCTAssertTrue(result.string.contains("Large heading"))
    }
}
