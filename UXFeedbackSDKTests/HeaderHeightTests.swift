import XCTest
@testable import UXFeedbackSDK

final class HeaderHeightTests: XCTestCase {

    private let theme = Theme()

    override func tearDown() {
        ImageCache.shared.removeAllObjects()
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeField(value: String = "Title",
                           description: String? = nil,
                           image: [String: Any]? = nil,
                           required: Bool? = nil) -> Field {
        var dict: [String: Any] = [
            "id": "h1",
            "type": "header",
            "value": value
        ]
        if let description = description {
            dict["description"] = description
        }
        if let image = image {
            dict["image"] = image
        }
        if let required = required {
            dict["required"] = required
        }
        return try! Field(from: dict)
    }

    private func makeImage(size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { context in
            UIColor.gray.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    private func titleHeight(_ field: Field, width: CGFloat, font: UIFont, withRequired: Bool = false) -> CGFloat {
        let attributed = TextPropertyManager.convert(field.value ?? "",
                                                     theme: theme,
                                                     defaultFont: font,
                                                     textProperties: nil,
                                                     withRequired: withRequired)
        return TextPropertyManager.heightForAttributed(string: attributed, and: width)
    }

    private func descriptionHeight(_ field: Field, width: CGFloat) -> CGFloat {
        guard let description = field.description, !description.isEmpty else { return 0 }
        let attributed = TextPropertyManager.convert(description,
                                                     theme: theme,
                                                     defaultFont: theme.fontP1,
                                                     textProperties: nil,
                                                     withRequired: false)
        return TextPropertyManager.heightForAttributed(string: attributed, and: width)
    }

    // MARK: - HeaderCell.computeImageHeight

    func testComputeImageHeightDefaultType() {
        let field = makeField(image: ["type": "default", "position": "topHeader", "alignment": "left", "src": "https://example.com/a.png"])

        let height = HeaderCell.computeImageHeight(field: field, isDefault: true)

        XCTAssertEqual(height, 100)
    }

    func testComputeImageHeightCustomTypeWithoutCache() {
        let field = makeField(image: ["type": "custom", "position": "topHeader", "alignment": "left", "src": "https://example.com/no-cache.png"])

        let height = HeaderCell.computeImageHeight(field: field, isDefault: false)

        XCTAssertEqual(height, 240)
    }

    func testComputeImageHeightCustomTypeWithSmallCachedImage() {
        let src = "https://example.com/small.png"
        let field = makeField(image: ["type": "custom", "position": "topHeader", "alignment": "left", "src": src])
        ImageCache.shared.setObject(makeImage(size: CGSize(width: 100, height: 60)), forKey: src as NSString)

        let height = HeaderCell.computeImageHeight(field: field, isDefault: false)

        XCTAssertEqual(height, 60)
    }

    func testComputeImageHeightCustomTypeWithTallCachedImage() {
        let src = "https://example.com/tall.png"
        let field = makeField(image: ["type": "custom", "position": "topHeader", "alignment": "left", "src": src])
        ImageCache.shared.setObject(makeImage(size: CGSize(width: 100, height: 500)), forKey: src as NSString)

        let height = HeaderCell.computeImageHeight(field: field, isDefault: false)

        XCTAssertEqual(height, 240)
    }

    func testComputeImageHeightNilField() {
        XCTAssertEqual(HeaderCell.computeImageHeight(field: nil, isDefault: false), 240)
        XCTAssertEqual(HeaderCell.computeImageHeight(field: nil, isDefault: true), 100)
    }

    // MARK: - DataManager.headerBlockHeight: text only

    func testHeaderBlockHeightTitleOnly() {
        let field = makeField(value: "Simple title")
        let width: CGFloat = 343

        let height = DataManager.headerBlockHeight(field: field,
                                                   theme: theme,
                                                   contentWidth: width,
                                                   titleFont: theme.fontH1,
                                                   withRequired: false)

        let expected = titleHeight(field, width: width, font: theme.fontH1) + 24
        XCTAssertEqual(height, expected)
    }

    func testHeaderBlockHeightWithDescription() {
        let field = makeField(value: "Title", description: "Some longer description text explaining the question")
        let width: CGFloat = 343

        let height = DataManager.headerBlockHeight(field: field,
                                                   theme: theme,
                                                   contentWidth: width,
                                                   titleFont: theme.fontH2,
                                                   withRequired: false)

        let expected = titleHeight(field, width: width, font: theme.fontH2)
            + descriptionHeight(field, width: width)
            + 24
        XCTAssertEqual(height, expected)
    }

    func testHeaderBlockHeightWithRequiredMarker() {
        let field = makeField(value: "Title", required: true)
        let width: CGFloat = 343

        let height = DataManager.headerBlockHeight(field: field,
                                                   theme: theme,
                                                   contentWidth: width,
                                                   titleFont: theme.fontH2,
                                                   withRequired: true)

        let expected = titleHeight(field, width: width, font: theme.fontH2, withRequired: true) + 24
        XCTAssertEqual(height, expected)
    }

    // MARK: - DataManager.headerBlockHeight: with image

    func testHeaderBlockHeightWithTopHeaderImage() {
        let field = makeField(value: "Title",
                              image: ["type": "default", "position": "topHeader", "alignment": "left", "src": "https://example.com/a.png"])
        let width: CGFloat = 343

        let height = DataManager.headerBlockHeight(field: field,
                                                   theme: theme,
                                                   contentWidth: width,
                                                   titleFont: theme.fontH1,
                                                   withRequired: false)

        // topHeader: 8(top) + 8(gap) + 8(gap) + 16(bottom) = 40 = 24 + 16
        let expected = titleHeight(field, width: width, font: theme.fontH1) + 100 + 16 + 24
        XCTAssertEqual(height, expected)
    }

    func testHeaderBlockHeightWithBottomImage() {
        let field = makeField(value: "Title",
                              image: ["type": "default", "position": "bottom", "alignment": "left", "src": "https://example.com/a.png"])
        let width: CGFloat = 343

        let height = DataManager.headerBlockHeight(field: field,
                                                   theme: theme,
                                                   contentWidth: width,
                                                   titleFont: theme.fontH1,
                                                   withRequired: false)

        // снизу: 16(top) + 8 + 8 + 8(bottom) = 40 = 24 + 16
        let expected = titleHeight(field, width: width, font: theme.fontH1) + 100 + 16 + 24
        XCTAssertEqual(height, expected)
    }

    func testHeaderBlockHeightWithCachedCustomImage() {
        let src = "https://example.com/cached.png"
        let field = makeField(value: "Title",
                              image: ["type": "custom", "position": "topHeader", "alignment": "left", "src": src])
        ImageCache.shared.setObject(makeImage(size: CGSize(width: 200, height: 120)), forKey: src as NSString)
        let width: CGFloat = 343

        let height = DataManager.headerBlockHeight(field: field,
                                                   theme: theme,
                                                   contentWidth: width,
                                                   titleFont: theme.fontH1,
                                                   withRequired: false)

        let expected = titleHeight(field, width: width, font: theme.fontH1) + 120 + 16 + 24
        XCTAssertEqual(height, expected)
    }

    // MARK: - Width sensitivity (регрессия обрезки текста)

    func testHeaderBlockHeightGrowsOnNarrowWidth() {
        let field = makeField(value: "Насколько легко вам было пользоваться нашим мобильным приложением сегодня?")

        let wide = DataManager.headerBlockHeight(field: field,
                                                 theme: theme,
                                                 contentWidth: 600,
                                                 titleFont: theme.fontH1,
                                                 withRequired: false)
        let narrow = DataManager.headerBlockHeight(field: field,
                                                   theme: theme,
                                                   contentWidth: 250,
                                                   titleFont: theme.fontH1,
                                                   withRequired: false)

        XCTAssertGreaterThan(narrow, wide, "Высота должна расти при сужении контейнера — иначе текст обрезается")
    }

    func testHeaderBlockHeightUsesPassedWidthNotScreenWidth() {
        let field = makeField(value: "Длинный заголовок опроса, который переносится на несколько строк на узких контейнерах")
        let screenWidth = UIScreen.main.bounds.width

        let atScreenWidth = DataManager.headerBlockHeight(field: field,
                                                          theme: theme,
                                                          contentWidth: screenWidth,
                                                          titleFont: theme.fontH1,
                                                          withRequired: false)
        let atHalfWidth = DataManager.headerBlockHeight(field: field,
                                                        theme: theme,
                                                        contentWidth: screenWidth / 2,
                                                        titleFont: theme.fontH1,
                                                        withRequired: false)

        XCTAssertGreaterThan(atHalfWidth, atScreenWidth,
                             "Расчёт должен зависеть от переданной ширины контейнера, а не от ширины экрана")
    }

    // MARK: - Соответствие расчёта реальной раскладке HeaderView

    func testHeaderCellLabelsNotCompressedOnHeightMismatch() {
        let src = "https://example.com/compress.png"
        let image = UIGraphicsImageRenderer(size: CGSize(width: 120, height: 80)).image { ctx in
            UIColor.blue.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 120, height: 80))
        }
        ImageCache.shared.setObject(image, forKey: src as NSString)

        let field = makeField(value: "Заголовок опроса в несколько слов",
                              description: "Описание блока, которое тоже занимает какое-то место",
                              image: ["type": "custom", "position": "topHeader", "alignment": "center", "src": src])
        let width: CGFloat = 375
        let computedHeight = DataManager.headerBlockHeight(field: field,
                                                           theme: theme,
                                                           contentWidth: width - 32,
                                                           titleFont: theme.fontH1,
                                                           withRequired: false)

        for cellHeight in [computedHeight, computedHeight - 6] {
            let cell = HeaderCell(style: .default, reuseIdentifier: nil)
            cell.frame = CGRect(x: 0, y: 0, width: width, height: cellHeight)
            let delegate = DataManager(CampaignViewController(), campaign: nil)
            cell.configureWith(field, theme: theme, delegate: delegate)
            cell.layoutIfNeeded()

            let labels = cell.contentView.subviews.compactMap { $0 as? LinkLabel }
            XCTAssertEqual(labels.count, 2)
            for label in labels {
                guard let text = label.attributedText, text.length > 0 else { continue }
                let required = label.sizeThatFits(CGSize(width: width - 32, height: .greatestFiniteMagnitude)).height
                XCTAssertGreaterThanOrEqual(label.frame.height + 1, required,
                                            "Лейбл сжат при высоте ячейки \(cellHeight) — текст будет обрезан")
            }
        }
    }

    func testSectionHeaderHeightHasTwelvePointBottomGap() {
        let width: CGFloat = 343
        let titleFont = theme.fontH2

        // без описания: 8(top) + title + 12(bottom)
        let noDesc = makeField(value: "Насколько легко пользоваться нашим сайтом?")
        let titleH = TextPropertyManager.heightForAttributed(
            string: TextPropertyManager.convert(noDesc.value!, theme: theme, defaultFont: titleFont,
                                                 textProperties: nil, withRequired: false),
            and: width)
        XCTAssertEqual(
            DataManager.sectionHeaderHeight(field: noDesc, theme: theme, contentWidth: width,
                                            titleFont: titleFont, withRequired: false),
            8 + titleH + 12)

        // с описанием: 8(top) + title + 8(gap) + desc + 12(bottom)
        let withDesc = makeField(value: "Насколько легко пользоваться нашим сайтом?",
                                 description: "Дополнительное описание для вопроса в несколько строк")
        let descH = TextPropertyManager.heightForAttributed(
            string: TextPropertyManager.convert(withDesc.description!, theme: theme, defaultFont: theme.fontP1,
                                                 textProperties: nil, withRequired: false),
            and: width)
        XCTAssertEqual(
            DataManager.sectionHeaderHeight(field: withDesc, theme: theme, contentWidth: width,
                                            titleFont: titleFont, withRequired: false),
            8 + titleH + 8 + descH + 12)
    }

    func testHeaderBlockHeightFitsActualLabelsAtVariousWidths() {
        let field = makeField(value: "Насколько легко вам было пользоваться нашим мобильным приложением сегодня?",
                              description: "Оцените по шкале от 1 до 10, где 10 — очень легко, а 1 — очень сложно")

        // Ширины таблицы: iPhone SE, iPhone 15, iPad Split View, iPad
        for tableWidth in [320.0, 393.0, 507.0, 768.0] as [CGFloat] {
            let contentWidth = tableWidth - 32

            let computed = DataManager.headerBlockHeight(field: field,
                                                         theme: theme,
                                                         contentWidth: contentWidth,
                                                         titleFont: theme.fontH2,
                                                         withRequired: false)

            // Реально требуемая высота лейблов при той же ширине, что и в констрейнтах (16+16)
            let titleLabel = UILabel()
            titleLabel.numberOfLines = 0
            titleLabel.attributedText = TextPropertyManager.convert(field.value!,
                                                                    theme: theme,
                                                                    defaultFont: theme.fontH2,
                                                                    textProperties: nil,
                                                                    withRequired: false)
            let descriptionLabel = UILabel()
            descriptionLabel.numberOfLines = 0
            descriptionLabel.attributedText = TextPropertyManager.convert(field.description!,
                                                                          theme: theme,
                                                                          defaultFont: theme.fontP1,
                                                                          textProperties: nil,
                                                                          withRequired: false)
            let fitSize = CGSize(width: contentWidth, height: .greatestFiniteMagnitude)
            let requiredHeight = ceil(titleLabel.sizeThatFits(fitSize).height)
                + ceil(descriptionLabel.sizeThatFits(fitSize).height)
                + 24

            XCTAssertGreaterThanOrEqual(computed, requiredHeight,
                                        "При ширине таблицы \(tableWidth) рассчитанная высота меньше требуемой — текст будет обрезан")
        }
    }
}
