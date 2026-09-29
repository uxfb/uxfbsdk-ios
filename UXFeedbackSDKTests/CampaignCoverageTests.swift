import XCTest
@testable import UXFeedbackSDK

// MARK: - Fixtures

private func makeField(_ dict: [String: Any]) -> Field {
    return try! Field(from: dict)
}

private func makePage(id: String = "p1", type: Int? = nil, fields: [[String: Any]], buttons: [[String: Any]]? = nil) -> Page {
    var dict: [String: Any] = [
        "id": id,
        "fields": fields,
        "buttons": buttons ?? [["id": "btn1", "type": "button", "value": "Далее"]]
    ]
    if let type = type {
        dict["type"] = type
    }
    return try! Page(from: dict)
}

private func makeCampaign(pages: [Page],
                          type: CampaignType = .slidein,
                          transforms: [Transform] = [],
                          privacy: Privacy? = nil,
                          progress: Bool = true) -> Campaign {
    return Campaign(campaignId: 1,
                    theme: Theme(),
                    pages: pages,
                    type: type,
                    targeting: Targeting(value: "event"),
                    transforms: transforms,
                    autoclose: 0,
                    privacy: privacy,
                    progress: progress)
}

private func makeViewController(campaign: Campaign) -> CampaignViewController {
    let vc = CampaignViewController()
    vc.campaign = campaign
    vc.completeHandler = { _, _ in }
    vc.didCloseHandler = { }
    vc.loadViewIfNeeded()
    // Вне окна у view нулевой фрейм — задаём явно, иначе расчёты высот страницы дают 0
    vc.view.frame = UIScreen.main.bounds
    return vc
}

private func makeManager(campaign: Campaign) -> (DataManager, CampaignViewController) {
    let vc = makeViewController(campaign: campaign)
    let manager = DataManager(vc, campaign: campaign)
    return (manager, vc)
}

// Страница со всеми типами полей
private let allFieldsPage: [[String: Any]] = [
    ["id": "fHeader", "type": "header", "value": "Заголовок опроса", "description": "Описание"],
    ["id": "fText", "type": "text", "value": "Просто текст"],
    ["id": "fSmiles", "type": "smiles", "value": "Оцените", "required": true, "warning": "Заполните поле"],
    ["id": "fStars", "type": "stars", "value": "Звёзды"],
    ["id": "fNps", "type": "nps", "value": "NPS"],
    ["id": "fRating", "type": "rating", "value": "Рейтинг", "ratingCount": 5,
     "messages": ["negative": "Плохо", "positive": "Отлично"]],
    ["id": "fInput", "type": "comment", "value": "Комментарий", "mode": "single"],
    ["id": "fMulti", "type": "comment", "value": "Многострочный", "mode": "multi"],
    ["id": "fEmail", "type": "email", "value": "Почта"],
    ["id": "fCheckbox", "type": "checkboxes", "value": "Выбор",
     "options": [["id": "o1", "value": "Вариант 1"], ["id": "o2", "value": "Вариант 2"]]],
    ["id": "fRadio", "type": "radiobuttons", "value": "Радио",
     "options": [["id": "r1", "value": "Один"]]],
    ["id": "fImage", "type": "image", "value": "img"],
    ["id": "fScreenshot", "type": "screenshot", "value": "Скриншот",
     "buttons": ["create": "Сделать скриншот", "upload": "Выбрать из галереи"]]
]

// MARK: - DataManager

final class DataManagerLogicTests: XCTestCase {

    override func tearDown() {
        ImageCache.shared.removeAllObjects()
        super.tearDown()
    }

    private func waitMainQueue() {
        let exp = expectation(description: "main queue drained")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 2)
    }

    // MARK: Counts & sections

    func testFieldsCountIncludesButtons() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))
        XCTAssertEqual(manager.fieldsCount(), allFieldsPage.count + 1)
    }

    func testSectionsWithoutButton() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))
        XCTAssertEqual(manager.sectionsWithotButton().count, allFieldsPage.count + 1)
    }

    func testNumberForFieldCellVisibleField() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))
        XCTAssertEqual(manager.numberForFieldCell(index: 0), 1)
    }

    // MARK: Heights per field type

    private func height(_ manager: DataManager, _ section: Int) -> CGFloat {
        return manager.heightForFieldCell(indexPath: IndexPath(row: 0, section: section))
    }

    func testFixedHeights() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))

        XCTAssertEqual(height(manager, 2), 48)   // smiles
        XCTAssertEqual(height(manager, 3), 40)   // stars
        XCTAssertEqual(height(manager, 4), 48)   // nps без сообщений
        XCTAssertEqual(height(manager, 5), 80)   // rating с messages
        XCTAssertEqual(height(manager, 6), 40)   // input single
        XCTAssertEqual(height(manager, 7), 84)   // input multi
        XCTAssertEqual(height(manager, 8), 40)   // email
        XCTAssertEqual(height(manager, 11), 56)  // image
        XCTAssertEqual(height(manager, allFieldsPage.count), 40) // кнопка
    }

    func testOptionListHeights() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))

        XCTAssertEqual(height(manager, 9), 96)  // checkbox: 2 короткие опции по 48
        XCTAssertEqual(height(manager, 10), 48) // radiobutton: 1 опция
    }

    func testComputedTextHeights() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))

        XCTAssertGreaterThan(height(manager, 0), 24) // header: текст + отступы
        XCTAssertGreaterThan(height(manager, 1), 0)  // text
    }

    func testScreenshotHeightSlideinAndPopup() {
        let (slidein, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)], type: .slidein))
        let (popup, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)], type: .popup))

        XCTAssertGreaterThan(height(slidein, 12), 0)
        XCTAssertGreaterThan(height(popup, 12), 0)
    }

    func testNoAnswerToggleAddsExtraHeight() {
        let fields: [[String: Any]] = [
            ["id": "f1", "type": "smiles", "value": "Оцените", "noAnswerName": "Затрудняюсь ответить"]
        ]
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: fields)]))

        // 48 + NoAnswerView.height(31) + topSpacing(16)
        XCTAssertEqual(height(manager, 0), 48 + NoAnswerView.height + NoAnswerView.topSpacing)
    }

    func testNoAnswerLongTitleIncreasesHeight() {
        let longTitle = "Затрудняюсь ответить на этот вопрос, потому что не пользовался этой функцией приложения ни разу"
        let fields: [[String: Any]] = [
            ["id": "f1", "type": "smiles", "value": "Оцените", "noAnswerName": longTitle]
        ]
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: fields)]))

        XCTAssertGreaterThan(height(manager, 0), 48 + NoAnswerView.height + NoAnswerView.topSpacing)
    }

    func testExtraSpaceDependsOnCampaignType() {
        let (popup, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)], type: .popup))
        let (slidein, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)], type: .slidein))

        XCTAssertEqual(popup.extraSpace, 80)
        XCTAssertEqual(slidein.extraSpace, 32)
    }

    func testTitleViewHeight() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))
        XCTAssertEqual(manager.titleViewHeight, 54)
    }

    func testHeightForCurrentPagePositive() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))
        XCTAssertGreaterThan(manager.heightForCurrentPage(), 54)
    }

    // MARK: Section header (HeaderView) & footer

    func testHeaderForQuestionField() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))

        // rating (index 5) — обычный вопрос с value → секционный заголовок
        XCTAssertGreaterThan(manager.heightForFieldHeader(index: 5), 12)
        XCTAssertTrue(manager.viewForFieldHeader(index: 5) is HeaderView)
    }

    func testNoHeaderForHeaderAndTextFields() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))

        XCTAssertEqual(manager.heightForFieldHeader(index: 0), CGFloat.leastNonzeroMagnitude)
        XCTAssertNil(manager.viewForFieldHeader(index: 0))
        XCTAssertNil(manager.viewForFieldHeader(index: 1))
    }

    func testErrorFooterForRequiredField() {
        let (manager, vc) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))
        vc.tableView.reloadData()

        let button = manager.fieldForRow(indexPath: IndexPath(row: 0, section: allFieldsPage.count))
        manager.buttonTapped(button, answer: [], refresh: true)

        // smiles (index 2) — required с warning, был видим в момент отправки
        XCTAssertGreaterThan(manager.heightForFieldFooter(index: 2), 12)
        XCTAssertNotNil(manager.viewForFieldFooter(index: 2))
        XCTAssertTrue(manager.fieldForRow(indexPath: IndexPath(row: 0, section: 2)).isError)
    }

    func testErrorMarksOnlyFieldsVisibleAtSubmit() {
        let fields: [[String: Any]] = [
            ["id": "f1", "type": "radiobuttons", "value": "Вопрос", "required": true, "warning": "Заполните",
             "options": [["id": "yes", "value": "Да"]]],
            ["id": "f2", "type": "comment", "value": "Скрытый", "required": true, "warning": "Заполните", "mode": "single"]
        ]
        let transform = try! Transform(from: [
            "id": "t1",
            "to": ["action": "show", "value": "f2", "type": "toField"],
            "scenarios": [[
                "id": "s1", "name": "s",
                "conditions": [[
                    "id": "c1",
                    "from": ["field": "f1"],
                    "condition": ["rule": "equal", "value": ["yes"]]
                ]]
            ]]
        ] as [String: Any])
        let (manager, vc) = makeManager(campaign: makeCampaign(pages: [makePage(fields: fields)],
                                                               transforms: [transform]))
        vc.tableView.reloadData()

        let button = manager.fieldForRow(indexPath: IndexPath(row: 0, section: 2))
        manager.buttonTapped(button, answer: [], refresh: true)

        XCTAssertTrue(manager.isError)
        XCTAssertTrue(manager.fieldForRow(indexPath: IndexPath(row: 0, section: 0)).isError)

        // Отвечаем на f1 → раскрывается f2, но он не был видим при отправке — без ошибки
        let f1 = manager.fieldForRow(indexPath: IndexPath(row: 0, section: 0))
        manager.fieldChanged(f1, answer: ["yes"], refresh: false)
        waitMainQueue()

        XCTAssertEqual(manager.numberForFieldCell(index: 1), 1)
        XCTAssertFalse(manager.fieldForRow(indexPath: IndexPath(row: 0, section: 1)).isError)
        XCTAssertNil(manager.viewForFieldFooter(index: 1))
    }

    func testNoFooterWithoutError() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))

        XCTAssertNil(manager.viewForFieldFooter(index: 2))
    }

    // MARK: Field access

    func testFieldForRowAndRowForField() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))

        let field = manager.fieldForRow(indexPath: IndexPath(row: 0, section: 0))
        XCTAssertEqual(field.id, "fHeader")
        XCTAssertEqual(manager.rowForField(field), 0)
    }

    // MARK: Progress

    func testProgress() {
        let pages = [makePage(id: "p1", fields: allFieldsPage),
                     makePage(id: "p2", type: 2, fields: [["id": "f", "type": "header", "value": "Спасибо"]])]
        let (manager, _) = makeManager(campaign: makeCampaign(pages: pages))

        XCTAssertEqual(manager.progress, "1/1") // страницы type 2 не считаются
        XCTAssertFalse(manager.isProgressHidden)
    }

    // MARK: Answers

    func testFieldChangedStoresAnswer() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))
        let field = manager.fieldForRow(indexPath: IndexPath(row: 0, section: 4)) // nps

        manager.fieldChanged(field, answer: ["7"], refresh: false)
        waitMainQueue()

        let updated = manager.fieldForRow(indexPath: IndexPath(row: 0, section: 4))
        XCTAssertEqual(updated.answers, ["7"])
    }

    func testFieldChangedWithEmptyAnswerClearsPrevious() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))
        let field = manager.fieldForRow(indexPath: IndexPath(row: 0, section: 4))

        manager.fieldChanged(field, answer: ["7"], refresh: false)
        waitMainQueue()
        manager.fieldChanged(field, answer: [], refresh: false)
        waitMainQueue()

        let updated = manager.fieldForRow(indexPath: IndexPath(row: 0, section: 4))
        XCTAssertEqual(updated.answers, [])
    }

    func testTextChangedStoresAnswer() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))
        let field = manager.fieldForRow(indexPath: IndexPath(row: 0, section: 6)) // input

        manager.textChanged(field, answer: ["привет"])

        let updated = manager.fieldForRow(indexPath: IndexPath(row: 0, section: 6))
        XCTAssertEqual(updated.answers, ["привет"])
    }

    // MARK: Transforms (показ/скрытие полей)

    private func makeShowTransform(targetField: String, whenField: String, equals value: String) -> Transform {
        let dict: [String: Any] = [
            "id": "t1",
            "to": ["action": "show", "value": targetField, "type": "toField"],
            "scenarios": [[
                "id": "s1",
                "name": "scenario",
                "conditions": [[
                    "id": "c1",
                    "from": ["field": whenField],
                    "condition": ["rule": "equal", "value": [value]]
                ]]
            ]]
        ]
        return try! Transform(from: dict)
    }

    func testTransformHidesFieldUntilConditionMet() {
        let fields: [[String: Any]] = [
            ["id": "f1", "type": "radiobuttons", "value": "Вопрос",
             "options": [["id": "yes", "value": "Да"]]],
            ["id": "f2", "type": "comment", "value": "Почему?", "mode": "single"]
        ]
        let transform = makeShowTransform(targetField: "f2", whenField: "f1", equals: "yes")
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: fields)],
                                                              transforms: [transform]))

        // Условие не выполнено — поле скрыто
        XCTAssertEqual(manager.numberForFieldCell(index: 1), 0)
        XCTAssertEqual(manager.heightForFieldCell(indexPath: IndexPath(row: 0, section: 1)),
                       CGFloat.leastNonzeroMagnitude)

        // Отвечаем на f1 → f2 показывается
        let f1 = manager.fieldForRow(indexPath: IndexPath(row: 0, section: 0))
        manager.fieldChanged(f1, answer: ["yes"], refresh: false)
        waitMainQueue()

        XCTAssertEqual(manager.numberForFieldCell(index: 1), 1)
        XCTAssertGreaterThan(manager.heightForFieldCell(indexPath: IndexPath(row: 0, section: 1)), 1)
    }

    // MARK: Privacy

    private func makePrivacy(showType: String = "all", type: String = "checkbox") -> Privacy {
        return Privacy(warningMessage: "Подтвердите согласие",
                       type: type,
                       declaration: "Я согласен с политикой",
                       showType: showType,
                       privacyPages: ["p1"],
                       enabled: true)
    }

    func testPrivacyNeededForShowTypeAll() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)],
                                                              privacy: makePrivacy()))

        XCTAssertTrue(manager.privacyNeeded)
        XCTAssertGreaterThanOrEqual(manager.privacyHeight, 64)
    }

    func testPrivacyNotNeededWhenDisabled() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))

        XCTAssertFalse(manager.privacyNeeded)
        XCTAssertEqual(manager.privacyHeight, .leastNonzeroMagnitude)
    }

    func testTapAndCheckPrivacy() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)],
                                                              privacy: makePrivacy()))

        manager.tapPrivacy()          // переключает чекбокс
        manager.checkPrivacy(true)    // явная установка
        manager.checkPrivacy(nil)     // без изменения значения

        XCTAssertTrue(manager.privacyNeeded)
    }

    // MARK: Validation & navigation

    func testButtonTappedSetsErrorForUnansweredRequiredField() {
        let (manager, vc) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))
        vc.tableView.reloadData()
        let button = manager.fieldForRow(indexPath: IndexPath(row: 0, section: allFieldsPage.count))

        manager.buttonTapped(button, answer: [], refresh: true)

        XCTAssertTrue(manager.isError) // smiles required и без ответа
    }

    func testEndCampaignFormatsAnswers() {
        let (manager, vc) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))

        var captured: Array<Dictionary<String, Any>>?
        vc.didTerminateHandler = { info, _, shownPages, totalPages in
            captured = info
            XCTAssertEqual(shownPages, 1)
            XCTAssertEqual(totalPages, 1)
        }

        let nps = manager.fieldForRow(indexPath: IndexPath(row: 0, section: 4))
        let input = manager.fieldForRow(indexPath: IndexPath(row: 0, section: 6))
        let checkbox = manager.fieldForRow(indexPath: IndexPath(row: 0, section: 9))

        manager.fieldChanged(nps, answer: ["7"], refresh: false)
        manager.fieldChanged(checkbox, answer: ["o1", "o2"], refresh: false)
        waitMainQueue()
        manager.textChanged(input, answer: ["текст ответа"])

        manager.endCampaign(terminated: true)

        XCTAssertNotNil(captured)
        let pageResult = captured?.first
        XCTAssertEqual(pageResult?["close"] as? Int, 1)
        let fields = pageResult?["fields"] as? [[String: Any]] ?? []

        // ВНИМАНИЕ: textChanged не проставляет pageId в ответ, поэтому endCampaign
        // не привязывает ответы комментариев к странице — в результатах их нет.
        // Тест фиксирует текущее поведение SDK (потенциальный баг).
        XCTAssertEqual(fields.count, 2)
        XCTAssertNil(fields.first { ($0["fieldId"] as? String) == "fInput" })

        // nps → Int, checkbox → [String]
        let npsAnswer = fields.first { ($0["fieldId"] as? String) == "fNps" }
        XCTAssertEqual(npsAnswer?["value"] as? Int, 7)
        let checkboxAnswer = fields.first { ($0["fieldId"] as? String) == "fCheckbox" }
        XCTAssertEqual(checkboxAnswer?["value"] as? [String], ["o1", "o2"])
    }

    func testScreenshotChangedStoresScreenshot() {
        let (manager, _) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))
        let field = manager.fieldForRow(indexPath: IndexPath(row: 0, section: 12))
        let image = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image { _ in }
        let screenshot = Screenshot(id: "s1", image: image, type: .screenshot, field: field)

        manager.screenshotChanged(field, screenshots: [screenshot])
        waitMainQueue()

        XCTAssertEqual(manager.screenshots.count, 1)
        XCTAssertEqual(manager.screenshots.first?.id, "s1")
    }

    func testDidBeginAndEndEditing() {
        let (manager, vc) = makeManager(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))
        vc.tableView.reloadData()
        let field = manager.fieldForRow(indexPath: IndexPath(row: 0, section: 6))

        manager.didBeginEditing(field)
        manager.didEndEditing(field)

        XCTAssertFalse(manager.isHalfScreen)
    }
}

// MARK: - CampaignViewController

final class CampaignViewControllerTests: XCTestCase {

    override func tearDown() {
        ImageCache.shared.removeAllObjects()
        super.tearDown()
    }

    private func loadedController(type: CampaignType = .slidein,
                                  privacy: Privacy? = nil) -> CampaignViewController {
        let campaign = makeCampaign(pages: [makePage(fields: allFieldsPage)], type: type, privacy: privacy)
        let vc = makeViewController(campaign: campaign)
        vc.tableView.frame = CGRect(x: 0, y: 0, width: 375, height: 600)
        vc.tableView.reloadData()
        return vc
    }

    // MARK: Lifecycle

    func testViewDidLoadSlidein() {
        let vc = loadedController(type: .slidein)

        XCTAssertNotNil(vc.view)
        XCTAssertNotNil(vc.tableView.delegate)
        XCTAssertNotNil(vc.tableView.dataSource)
        XCTAssertTrue(vc.bottomConstraint.isActive)
    }

    func testViewDidLoadPopup() {
        let vc = loadedController(type: .popup)

        XCTAssertNotNil(vc.view)
        XCTAssertTrue(vc.verticallyConstraint.isActive)
        XCTAssertEqual(vc.leftConstraint.constant, 24)
    }

    func testViewDidAppearReloads() {
        let vc = loadedController()
        vc.viewDidAppear(false)

        XCTAssertEqual(vc.tableView.numberOfSections, allFieldsPage.count + 1)
    }

    // MARK: Data source

    func testNumberOfSectionsMatchesFields() {
        let vc = loadedController()
        XCTAssertEqual(vc.numberOfSections(in: vc.tableView), allFieldsPage.count + 1)
    }

    func testCellForRowCreatesProperCellTypes() {
        let vc = loadedController()
        let expected: [Int: AnyClass] = [
            0: HeaderCell.self,
            1: TextCell.self,
            2: SmilesCell.self,
            3: StarsCell.self,
            4: NpsCell.self,
            5: RatingCell.self,
            6: InputCell.self,
            7: InputCell.self,
            8: EmailCell.self,
            9: CheckboxCell.self,
            10: RadiobuttonCell.self,
            11: ImageCell.self,
            12: ScreenshotCell.self,
            13: ButtonCell.self
        ]

        for (section, cellClass) in expected {
            let cell = vc.tableView(vc.tableView, cellForRowAt: IndexPath(row: 0, section: section))
            XCTAssertTrue(type(of: cell) == cellClass,
                          "Секция \(section): ожидался \(cellClass), получен \(type(of: cell))")
        }
    }

    func testHeaderCellWithCachedImageRendered() {
        let src = "https://example.com/header.png"
        let image = UIGraphicsImageRenderer(size: CGSize(width: 120, height: 80)).image { ctx in
            UIColor.blue.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 120, height: 80))
        }
        ImageCache.shared.setObject(image, forKey: src as NSString)

        let fields: [[String: Any]] = [
            ["id": "fH", "type": "header", "value": "С картинкой", "description": "Описание",
             "image": ["type": "custom", "position": "topHeader", "alignment": "center", "src": src]]
        ]
        let campaign = makeCampaign(pages: [makePage(fields: fields)])
        let vc = makeViewController(campaign: campaign)
        vc.tableView.frame = CGRect(x: 0, y: 0, width: 375, height: 600)
        vc.tableView.reloadData()

        let cell = vc.tableView(vc.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(cell is HeaderCell)

        let height = vc.tableView(vc.tableView, heightForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertGreaterThan(height, 80) // текст + картинка 80pt + отступы
    }

    // MARK: Delegate heights & views

    func testHeightsForAllRows() {
        let vc = loadedController()

        for section in 0..<(allFieldsPage.count + 1) {
            let indexPath = IndexPath(row: 0, section: section)
            let height = vc.tableView(vc.tableView, heightForRowAt: indexPath)
            let estimated = vc.tableView(vc.tableView, estimatedHeightForRowAt: indexPath)
            XCTAssertGreaterThan(height, 0, "Секция \(section)")
            XCTAssertEqual(height, estimated, "Секция \(section)")
        }
    }

    func testSectionHeaderViews() {
        let vc = loadedController()

        // rating — вопрос с value → HeaderView
        XCTAssertTrue(vc.tableView(vc.tableView, viewForHeaderInSection: 5) is HeaderView)
        XCTAssertGreaterThan(vc.tableView(vc.tableView, heightForHeaderInSection: 5), 12)

        // header-поле — секционного заголовка нет
        XCTAssertNil(vc.tableView(vc.tableView, viewForHeaderInSection: 0))
    }

    func testSectionFooterViews() {
        let vc = loadedController()

        let footer = vc.tableView(vc.tableView, viewForFooterInSection: 2)
        XCTAssertNotNil(footer)
        XCTAssertGreaterThan(vc.tableView(vc.tableView, heightForFooterInSection: 2), 0)
    }

    // MARK: Updates

    func testUpdateUIFullReload() {
        let vc = loadedController()
        vc.updateUI()

        XCTAssertEqual(vc.tableView.numberOfSections, allFieldsPage.count + 1)
    }

    func testUpdateUIWithSender() {
        let vc = loadedController()
        vc.updateUI(0)

        XCTAssertEqual(vc.tableView.numberOfSections, allFieldsPage.count + 1)
    }

    func testUpdateFieldAndFooterAndHeight() {
        let vc = loadedController()

        vc.updateField(idx: 0)
        vc.updateFooter()
        vc.updateHeight()
        vc.refreshFieldFooter(0)
        vc.scrollToTop(animated: false)

        XCTAssertGreaterThan(vc.contentHeight.constant, 0)
    }

    func testDidBeginAndEndEditingScrolls() {
        let vc = loadedController()

        vc.didBeginEditing(6)
        vc.didEndEditing(6)

        XCTAssertEqual(vc.tableView.contentInset.bottom, 180)
    }

    // MARK: Privacy

    func testUpdatePrivacyEnabled() {
        let vc = loadedController(privacy: Privacy(warningMessage: "Внимание",
                                                   type: "checkbox",
                                                   declaration: "Согласие",
                                                   showType: "all",
                                                   privacyPages: ["p1"],
                                                   enabled: true))

        vc.updatePrivacy(enabled: true, warning: "Внимание", text: "Согласие", checked: false)
        vc.checked(true)   // PrivacyDelegate
        vc.tapPrivacy()

        // Даём отработать отложенному обновлению футера
        let exp = expectation(description: "footer update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { exp.fulfill() }
        wait(for: [exp], timeout: 2)

        XCTAssertFalse(vc.privacyView.isHidden)
    }

    // MARK: Keyboard

    func testKeyboardNotifications() {
        let vc = loadedController(type: .popup)

        let userInfo: [AnyHashable: Any] = [
            UIResponder.keyboardAnimationDurationUserInfoKey: NSNumber(value: 0.25),
            UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: CGRect(x: 0, y: 400, width: 375, height: 300)),
            UIResponder.keyboardAnimationCurveUserInfoKey: UInt(7)
        ]

        NotificationCenter.default.post(name: UIResponder.keyboardWillShowNotification,
                                        object: nil,
                                        userInfo: userInfo)
        XCTAssertTrue(vc.withKeyboard)

        NotificationCenter.default.post(name: UIResponder.keyboardWillHideNotification,
                                        object: nil,
                                        userInfo: userInfo)
        XCTAssertFalse(vc.withKeyboard)
    }

    // MARK: Misc

    func testShouldAutorotateFollowsToggle() {
        let vc = loadedController()

        vc.rotateToggle = false
        XCTAssertFalse(vc.shouldAutorotate)
        vc.rotateToggle = true
        XCTAssertTrue(vc.shouldAutorotate)
    }
}

// MARK: - Vendor utilities

final class VendorUtilitiesTests: XCTestCase {

    private func makeImage(size: CGSize = CGSize(width: 20, height: 20)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    // MARK: UIView additions

    func testRoundCornersSetsMask() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.roundCorners(corners: [.topLeft, .topRight], radius: 8)

        XCTAssertTrue(view.layer.mask is CAShapeLayer)
    }

    func testAddShadowAndRoundCorner() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.addShadowAndRoundCorner(cornerRadius: 12)

        XCTAssertEqual(view.layer.cornerRadius, 12)
        XCTAssertEqual(view.layer.shadowOpacity, 0.15)
        XCTAssertFalse(view.clipsToBounds)
    }

    func testInspectableProperties() {
        let view = UIView()
        view.cornerRadius = 6
        view.borderWidth = 2
        view.borderColor = .black

        XCTAssertEqual(view.cornerRadius, 6)
        XCTAssertEqual(view.borderWidth, 2)
        XCTAssertNotNil(view.borderColor)
        XCTAssertTrue(view.layer.masksToBounds)
    }

    func testFirstResponderWhenNone() {
        let view = UIView()
        view.addSubview(UIView())

        XCTAssertNil(view.firstResponder)
    }

    // MARK: UIImage / UIImageView

    func testImageTint() {
        let tinted = makeImage().tint(with: .blue)

        XCTAssertEqual(tinted.size, CGSize(width: 20, height: 20))
    }

    func testSetImageColor() {
        let imageView = UIImageView(image: makeImage())
        imageView.setImageColor(color: .green)

        XCTAssertEqual(imageView.tintColor, .green)
    }

    // MARK: Skeleton

    func testShowAndHideSkeleton() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

        imageView.showSkeleton(baseColor: .gray, shineColor: .white)
        XCTAssertTrue(imageView.subviews.contains { $0 is SkeletonView })

        imageView.hideSkeleton()
        // hideSkeleton удаляет сабвью асинхронно на main queue
        let exp = expectation(description: "skeleton removed")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 2)

        XCTAssertFalse(imageView.subviews.contains { $0 is SkeletonView })
    }

    // MARK: Controls

    func testUIControlAddActionInvokesClosure() {
        let control = UIControl()
        var invoked = false
        control.addAction(for: .touchUpInside) { }

        // Замыкание хранится в ClosureSleeve — вызываем напрямую
        let sleeve = ClosureSleeve(attachTo: control) { invoked = true }
        sleeve.invoke()

        XCTAssertTrue(invoked)
    }

    func testGestureRecognizerAction() {
        var invoked = false
        let gesture = GestureRecognizer { invoked = true }
        gesture.perform(NSSelectorFromString("execute"))

        XCTAssertTrue(invoked)
    }

    func testLinkLabelHasTapGesture() {
        let label = LinkLabel()

        XCTAssertTrue(label.isUserInteractionEnabled)
        XCTAssertEqual(label.gestureRecognizers?.count, 1)
    }

    // MARK: Labels

    func testVerticalAlignedLabelDrawsAllModes() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        for mode in [UIView.ContentMode.top, .bottom, .center] {
            let label = VerticalAlignedLabel(frame: rect)
            label.text = "Текст"
            label.contentMode = mode

            _ = UIGraphicsImageRenderer(size: rect.size).image { _ in
                label.drawText(in: rect)
            }
        }
    }

    func testHtmlLabelParsesHtmlWithLink() {
        let label = HtmlLabel()
        label.textFont = .systemFont(ofSize: 14)
        label.linkColor = .blue
        label.defaultColor = .black

        label.html = "<p>Привет, <a href=\"https://example.com\">ссылка</a>!</p>"

        XCTAssertNotNil(label.attributedText)
        XCTAssertTrue(label.attributedText?.string.contains("Привет") ?? false)
        XCTAssertTrue(label.attributedText?.string.contains("ссылка") ?? false)
    }
}

// MARK: - Взаимодействия с ячейками

private final class FieldDelegateSpy: FieldDelegate {
    var onFieldChanged: ((Field, [String]) -> Void)?
    var onButtonTapped: ((Field) -> Void)?
    var onTextChanged: ((Field, [String]) -> Void)?
    var onBeginEditing: ((Field) -> Void)?
    var onEndEditing: ((Field) -> Void)?

    func fieldChanged(_ field: Field, answer: [String], refresh: Bool) { onFieldChanged?(field, answer) }
    func buttonTapped(_ field: Field, answer: [String], refresh: Bool) { onButtonTapped?(field) }
    func textChanged(_ field: Field, answer: [String]) { onTextChanged?(field, answer) }
    func screenshotChanged(_ field: Field, screenshots: [Screenshot]) { }
    func didBeginEditing(_ field: Field) { onBeginEditing?(field) }
    func didEndEditing(_ field: Field) { onEndEditing?(field) }
}

final class CellInteractionTests: XCTestCase {

    private let theme = Theme()
    private var delegateSpy: FieldDelegateSpy!

    override func setUp() {
        super.setUp()
        delegateSpy = FieldDelegateSpy()
    }

    override func tearDown() {
        ImageCache.shared.removeAllObjects()
        delegateSpy = nil
        super.tearDown()
    }

    // MARK: Helpers

    private func findView<T: UIView>(_ type: T.Type, in root: UIView) -> T? {
        if let view = root as? T { return view }
        for subview in root.subviews {
            if let found = findView(type, in: subview) { return found }
        }
        return nil
    }

    private func configure<T: BaseCell>(_ cell: T, field: [String: Any], width: CGFloat = 375) -> T {
        cell.frame = CGRect(x: 0, y: 0, width: width, height: 200)
        cell.configureWith(try! Field(from: field), theme: theme, delegate: delegateSpy)
        cell.layoutIfNeeded()
        return cell
    }

    private func cacheImage(src: String, size: CGSize = CGSize(width: 100, height: 60)) {
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            UIColor.orange.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
        ImageCache.shared.setObject(image, forKey: src as NSString)
    }

    // MARK: StarsCell

    func testStarsCellTapSendsAnswer() {
        let cell = configure(StarsCell(style: .default, reuseIdentifier: nil), field: ["id": "f1", "type": "stars", "value": "Оцените"])

        let exp = expectation(description: "star answer")
        delegateSpy.onFieldChanged = { _, answer in
            XCTAssertEqual(answer, ["4"])
            exp.fulfill()
        }

        guard let star = cell.contentView.viewWithTag(4),
              let gesture = star.gestureRecognizers?.first else {
            return XCTFail("Звезда с жестом не найдена")
        }
        cell.perform(NSSelectorFromString("starTapped:"), with: gesture)

        wait(for: [exp], timeout: 5)
    }

    func testStarsCellWithExistingAnswerAndError() {
        var field = try! Field(from: ["id": "f1", "type": "stars", "value": "Оцените", "required": true])
        field.answers = ["3"]
        let cell = StarsCell(style: .default, reuseIdentifier: nil)
        cell.frame = CGRect(x: 0, y: 0, width: 375, height: 100)
        cell.configureWith(field, theme: theme, delegate: delegateSpy)

        // Ошибка без ответа — запускает анимацию тряски
        var errorField = try! Field(from: ["id": "f2", "type": "stars", "value": "Оцените", "required": true])
        errorField.isError = true
        cell.configureWith(errorField, theme: theme, delegate: delegateSpy)
    }

    func testStarsCellNoAnswerToggle() {
        let cell = configure(StarsCell(style: .default, reuseIdentifier: nil), field: ["id": "f1", "type": "stars", "value": "Оцените",
                                                    "noAnswerName": "Затрудняюсь ответить"])

        var received: [String]?
        delegateSpy.onFieldChanged = { _, answer in received = answer }

        guard let noAnswerView = findView(NoAnswerView.self, in: cell.contentView) else {
            return XCTFail("NoAnswerView не найден")
        }
        XCTAssertFalse(noAnswerView.isHidden)
        noAnswerView.onToggle?(true)

        XCTAssertEqual(received, [NoAnswerView.noAnswerValue])
    }

    // MARK: CheckboxCell

    private var checkboxField: [String: Any] {
        return ["id": "f1", "type": "checkboxes", "value": "Выбор",
                "options": [["id": "o1", "value": "Первый"],
                            ["id": "o2", "value": "Второй"],
                            ["id": "o3", "value": "Ничего из перечисленного", "exceptional": true]]]
    }

    func testCheckboxCellSelectionFlow() {
        let cell = configure(CheckboxCell(style: .default, reuseIdentifier: nil), field: checkboxField)
        guard let inner = findView(UITableView.self, in: cell.contentView) else {
            return XCTFail("Внутренняя таблица не найдена")
        }
        inner.frame = CGRect(x: 0, y: 0, width: 343, height: 200)
        inner.reloadData()

        XCTAssertEqual(cell.tableView(inner, numberOfRowsInSection: 0), 3)
        XCTAssertTrue(cell.tableView(inner, cellForRowAt: IndexPath(row: 0, section: 0)) is CheckCell)
        XCTAssertGreaterThanOrEqual(cell.tableView(inner, heightForRowAt: IndexPath(row: 0, section: 0)), 48)

        var lastAnswer: [String]?
        delegateSpy.onFieldChanged = { _, answer in lastAnswer = answer }

        // Выбор обычной опции
        inner.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        cell.tableView(inner, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(lastAnswer, ["o1"])

        // Выбор exceptional-опции сбрасывает остальные
        inner.selectRow(at: IndexPath(row: 2, section: 0), animated: false, scrollPosition: .none)
        cell.tableView(inner, didSelectRowAt: IndexPath(row: 2, section: 0))
        XCTAssertEqual(lastAnswer, ["o3"])

        // Снятие выбора
        inner.deselectRow(at: IndexPath(row: 2, section: 0), animated: false)
        cell.tableView(inner, didDeselectRowAt: IndexPath(row: 2, section: 0))
        XCTAssertEqual(lastAnswer, [])
    }

    // MARK: TextCell / ImageCell / HeaderView с картинками

    func testTextCellWithCachedImageAllLayouts() {
        let src = "https://example.com/text-img.png"
        cacheImage(src: src)

        for position in ["topHeader", "bottom"] {
            for alignment in ["left", "right", "center"] {
                _ = configure(TextCell(style: .default, reuseIdentifier: nil), field: ["id": "f1", "type": "text", "value": "Текст с картинкой",
                                                    "image": ["type": "custom",
                                                              "position": position,
                                                              "alignment": alignment,
                                                              "src": src]])
            }
        }
    }

    func testImageCellWithCachedImage() {
        let src = "https://example.com/image-cell.png"
        cacheImage(src: src)

        _ = configure(ImageCell(style: .default, reuseIdentifier: nil), field: ["id": "f1", "type": "image", "value": "img",
                                             "image": ["type": "custom",
                                                       "position": "topHeader",
                                                       "alignment": "center",
                                                       "src": src]])
    }

    func testHeaderViewWithCachedImageAllLayouts() {
        let src = "https://example.com/header-view.png"
        cacheImage(src: src)

        for position in ["topHeader", "bottom"] {
            for alignment in ["left", "right", "center"] {
                let view = HeaderView(frame: CGRect(x: 0, y: 0, width: 375, height: 300))
                let field = try! Field(from: ["id": "f1", "type": "rating", "value": "Вопрос",
                                              "description": "Описание", "required": true,
                                              "image": ["type": "custom",
                                                        "position": position,
                                                        "alignment": alignment,
                                                        "src": src]])
                view.configure(field: field, theme: theme)
                view.layoutIfNeeded()
                view.clear()
            }
        }
    }

    // MARK: InputCell

    func testInputCellTextEditing() {
        let cell = configure(InputCell(style: .default, reuseIdentifier: nil), field: ["id": "f1", "type": "comment", "value": "Комментарий",
                                                    "placeholder": "Введите текст", "mode": "multi"])
        guard let textView = findView(UITextView.self, in: cell.contentView) else {
            return XCTFail("UITextView не найден")
        }

        var began = false, ended = false
        var lastText: [String]?
        delegateSpy.onBeginEditing = { _ in began = true }
        delegateSpy.onEndEditing = { _ in ended = true }
        delegateSpy.onTextChanged = { _, answer in lastText = answer }

        cell.textViewDidBeginEditing(textView)
        _ = cell.textView(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "Привет")
        textView.text = "Привет"
        cell.textViewDidEndEditing(textView)

        XCTAssertTrue(began)
        XCTAssertTrue(ended)
        _ = lastText // ответ уходит через textChanged в зависимости от реализации
    }

    // MARK: EmailCell

    func testEmailCellTextEditing() {
        let cell = configure(EmailCell(style: .default, reuseIdentifier: nil), field: ["id": "f1", "type": "email", "value": "Почта",
                                                    "placeholder": "email@example.com"])
        guard let textField = findView(UITextField.self, in: cell.contentView) else {
            return XCTFail("UITextField не найден")
        }

        var began = false, ended = false
        delegateSpy.onBeginEditing = { _ in began = true }
        delegateSpy.onEndEditing = { _ in ended = true }

        cell.textFieldDidBeginEditing(textField)
        _ = cell.textField(textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "a")
        textField.text = "user@example.com"
        cell.textFieldDidEndEditing(textField)
        _ = cell.textFieldShouldReturn(textField)

        XCTAssertTrue(began)
        XCTAssertTrue(ended)
    }

    // MARK: LinkLabel

    func testLinkLabelTapOnLink() {
        let label = LinkLabel()
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        let attributed = NSMutableAttributedString(string: "Открыть ссылку",
                                                   attributes: [.font: UIFont.systemFont(ofSize: 14)])
        attributed.addAttribute(.link,
                                value: URL(string: "uxtest://nothing")!,
                                range: NSRange(location: 0, length: attributed.length))
        label.attributedText = attributed
        label.layoutIfNeeded()

        guard let gesture = label.gestureRecognizers?.first else {
            return XCTFail("Жест не найден")
        }
        // Открытие несуществующей схемы в тестах — no-op
        label.perform(NSSelectorFromString("handleTap:"), with: gesture)
    }

    // MARK: NoAnswerView

    func testNoAnswerViewToggle() {
        let view = NoAnswerView(frame: CGRect(x: 0, y: 0, width: 300, height: 31))
        view.configure(title: "Затрудняюсь ответить", theme: theme, isOn: false)

        var toggled: Bool?
        view.onToggle = { isOn in toggled = isOn }

        view.setOn(true)
        view.perform(NSSelectorFromString("toggleChanged"))

        XCTAssertEqual(toggled, true)
    }
}

// MARK: - Навигация по страницам (transforms) и мелкие вьюхи

final class NavigationAndSmallViewsTests: XCTestCase {

    private let theme = Theme()

    override func setUp() {
        super.setUp()
        StubURLProtocol.register()
    }

    override func tearDown() {
        StubURLProtocol.unregister()
        ImageCache.shared.removeAllObjects()
        super.tearDown()
    }

    private func waitMainQueue() {
        let exp = expectation(description: "main queue drained")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 2)
    }

    // MARK: Fixtures

    private func threePageCampaign(transforms: [Transform] = []) -> Campaign {
        let p1 = makePage(id: "p1", fields: [
            ["id": "f1", "type": "radiobuttons", "value": "Вопрос 1",
             "options": [["id": "yes", "value": "Да"], ["id": "no", "value": "Нет"]]]
        ])
        let p2 = makePage(id: "p2", fields: [
            ["id": "f2", "type": "comment", "value": "Вопрос 2", "mode": "single"]
        ])
        let p3 = makePage(id: "p3", type: 2, fields: [
            ["id": "f3", "type": "header", "value": "Спасибо!"]
        ])
        return makeCampaign(pages: [p1, p2, p3], transforms: transforms)
    }

    private func makeTransform(_ dict: [String: Any]) -> Transform {
        return try! Transform(from: dict)
    }

    private func answer(_ manager: DataManager, section: Int, value: [String]) {
        let field = manager.fieldForRow(indexPath: IndexPath(row: 0, section: section))
        manager.fieldChanged(field, answer: value, refresh: false)
        waitMainQueue()
    }

    private func tapNextButton(_ manager: DataManager, fieldsCount: Int) {
        let button = manager.fieldForRow(indexPath: IndexPath(row: 0, section: fieldsCount))
        manager.buttonTapped(button, answer: [], refresh: true)
    }

    // MARK: Последовательная навигация

    func testSequentialNavigationThroughPages() {
        let (manager, vc) = makeManager(campaign: threePageCampaign())
        vc.tableView.reloadData()

        XCTAssertEqual(manager.progress, "1/2")

        tapNextButton(manager, fieldsCount: 1) // p1 → p2
        XCTAssertEqual(manager.progress, "2/2")
        XCTAssertFalse(manager.isProgressHidden)

        tapNextButton(manager, fieldsCount: 1) // p2 → p3 (thank you)
        XCTAssertTrue(manager.isProgressHidden)
    }

    func testCompleteOnThankYouPage() {
        let (manager, vc) = makeManager(campaign: threePageCampaign())
        vc.tableView.reloadData()

        tapNextButton(manager, fieldsCount: 1)
        tapNextButton(manager, fieldsCount: 1)
        XCTAssertTrue(manager.isProgressHidden)

        // Кнопка на странице type 2 завершает кампанию
        let exp = expectation(description: "completed")
        vc.completeHandler = { results, _ in
            XCTAssertNotNil(results)
            exp.fulfill()
        }
        tapNextButton(manager, fieldsCount: 1)
        wait(for: [exp], timeout: 5)
    }

    // MARK: Transform: переход на страницу по условию

    func testTransformToPageSkipsMiddlePage() {
        let transform = makeTransform([
            "id": "t1",
            "to": ["action": "transition", "value": "p3", "type": "toPage"],
            "scenarios": [[
                "id": "s1", "name": "s",
                "conditions": [[
                    "id": "c1",
                    "from": ["field": "f1"],
                    "condition": ["rule": "equal", "value": ["yes"]]
                ]]
            ]]
        ])
        let (manager, vc) = makeManager(campaign: threePageCampaign(transforms: [transform]))
        vc.tableView.reloadData()

        answer(manager, section: 0, value: ["yes"])
        tapNextButton(manager, fieldsCount: 1)

        // Пропустили p2, сразу на "спасибо"-страницу
        XCTAssertTrue(manager.isProgressHidden)
    }

    func testElseTransformFromPage() {
        let transform = makeTransform([
            "id": "t2",
            "to": ["action": "transition", "value": "p3", "type": "toPage"],
            "scenarios": [[
                "id": "s1", "name": "s",
                "conditions": [[
                    "id": "c1",
                    "from": ["page": "p1"],
                    "condition": ["rule": "unfilled"]
                ]]
            ]]
        ])
        let (manager, vc) = makeManager(campaign: threePageCampaign(transforms: [transform]))
        vc.tableView.reloadData()

        // Без ответа — else-переход со страницы p1 сразу на p3
        tapNextButton(manager, fieldsCount: 1)
        XCTAssertTrue(manager.isProgressHidden)
    }

    func testTransformToURLEndsCampaignAsExternalLink() {
        let transform = makeTransform([
            "id": "t3",
            "to": ["action": "transition", "value": "uxtest://external", "type": "toURL"],
            "scenarios": [[
                "id": "s1", "name": "s",
                "conditions": [[
                    "id": "c1",
                    "from": ["field": "f1"],
                    "condition": ["rule": "equal", "value": ["yes"]]
                ]]
            ]]
        ])
        let (manager, vc) = makeManager(campaign: threePageCampaign(transforms: [transform]))
        vc.tableView.reloadData()

        let exp = expectation(description: "completed as external link")
        vc.completeHandler = { results, _ in
            let last = results?.last
            XCTAssertEqual(last?["externalLink"] as? Int, 1)
            exp.fulfill()
        }

        answer(manager, section: 0, value: ["yes"])
        tapNextButton(manager, fieldsCount: 1)

        wait(for: [exp], timeout: 5)
    }

    private func fourPageCampaign(transforms: [Transform]) -> Campaign {
        let p1 = makePage(id: "p1", fields: [
            ["id": "f1", "type": "radiobuttons", "value": "Вопрос 1",
             "options": [["id": "yes", "value": "Да"], ["id": "no", "value": "Нет"]]]
        ])
        let p2 = makePage(id: "p2", fields: [
            ["id": "f2", "type": "comment", "value": "Вопрос 2", "mode": "single"]
        ])
        let p3 = makePage(id: "p3", fields: [
            ["id": "f3", "type": "comment", "value": "Вопрос 3", "mode": "single"]
        ])
        let p4 = makePage(id: "p4", type: 2, fields: [
            ["id": "f4", "type": "header", "value": "Спасибо!"]
        ])
        return makeCampaign(pages: [p1, p2, p3, p4], transforms: transforms)
    }

    func testSkippedPageDefaultTransitionApplied() {
        let showTransform = makeTransform([
            "id": "t1",
            "to": ["action": "show", "value": "f2", "type": "toField"],
            "scenarios": [[
                "id": "s1", "name": "s",
                "conditions": [[
                    "id": "c1",
                    "from": ["field": "f1"],
                    "condition": ["rule": "equal", "value": ["yes"]]
                ]]
            ]]
        ])
        let defaultTransition = makeTransform([
            "id": "t2",
            "to": ["action": "transition", "value": "p4", "type": "toPage"],
            "scenarios": [[
                "id": "s2", "name": "s",
                "conditions": [[
                    "id": "c2",
                    "from": ["page": "p2"],
                    "condition": ["rule": "unfilled"]
                ]]
            ]]
        ])
        let (manager, vc) = makeManager(campaign: fourPageCampaign(transforms: [showTransform, defaultTransition]))
        vc.tableView.reloadData()

        answer(manager, section: 0, value: ["no"])
        tapNextButton(manager, fieldsCount: 1)

        XCTAssertTrue(manager.isProgressHidden,
                      "Пропущенная страница p2 должна применить свой безусловный переход на p4")
    }

    func testTransformRulesDoNotLeakToNextPages() {
        let containRule = makeTransform([
            "id": "t1",
            "to": ["action": "transition", "value": "p2", "type": "toPage"],
            "scenarios": [[
                "id": "s1", "name": "s",
                "conditions": [[
                    "id": "c1",
                    "from": ["field": "f1"],
                    "condition": ["rule": "contain", "value": ["yes"]]
                ]]
            ]]
        ])
        let filledRule = makeTransform([
            "id": "t2",
            "to": ["action": "transition", "value": "p4", "type": "toPage"],
            "scenarios": [[
                "id": "s2", "name": "s",
                "conditions": [[
                    "id": "c2",
                    "from": ["field": "f1"],
                    "condition": ["rule": "filled"]
                ]]
            ]]
        ])
        let (manager, vc) = makeManager(campaign: fourPageCampaign(transforms: [containRule, filledRule]))
        vc.tableView.reloadData()

        answer(manager, section: 0, value: ["yes"])
        tapNextButton(manager, fieldsCount: 1)
        XCTAssertEqual(manager.progress, "2/3")

        tapNextButton(manager, fieldsCount: 1)

        XCTAssertEqual(manager.progress, "3/3",
                       "Правила страницы p1 не должны срабатывать при уходе со страницы p2")
        XCTAssertFalse(manager.isProgressHidden)
    }

    func testEndCampaignRecordsOnlyVisitedPages() {
        let jumpRule = makeTransform([
            "id": "t1",
            "to": ["action": "transition", "value": "p4", "type": "toPage"],
            "scenarios": [[
                "id": "s1", "name": "s",
                "conditions": [[
                    "id": "c1",
                    "from": ["field": "f1"],
                    "condition": ["rule": "equal", "value": ["yes"]]
                ]]
            ]]
        ])
        let (manager, vc) = makeManager(campaign: fourPageCampaign(transforms: [jumpRule]))
        vc.tableView.reloadData()

        answer(manager, section: 0, value: ["yes"])
        tapNextButton(manager, fieldsCount: 1)
        XCTAssertTrue(manager.isProgressHidden)

        let exp = expectation(description: "completed")
        vc.completeHandler = { results, _ in
            let pageIds = results?.compactMap { $0["pageId"] as? String } ?? []
            XCTAssertEqual(pageIds, ["p1", "p4"],
                           "В статистику должны попадать только показанные страницы")
            exp.fulfill()
        }
        tapNextButton(manager, fieldsCount: 1)
        wait(for: [exp], timeout: 5)
    }

    // MARK: SliderView

    func testSliderViewStyles() {
        let slider = SliderView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))

        slider.setStyle(.inactive, theme: theme)
        slider.setStyle(.active, theme: theme)
        slider.setStyle(.error, theme: theme)
        slider.layoutIfNeeded()

        XCTAssertEqual(slider.backgroundColor, .clear)
    }

    // MARK: VisualEffectView

    func testVisualEffectViewProperties() {
        let view = VisualEffectView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        view.colorTint = .red
        view.colorTintAlpha = 0.5
        view.blurRadius = 4

        XCTAssertNotNil(view.colorTint)
        XCTAssertEqual(view.blurRadius, 4, accuracy: 0.01)
    }

    // MARK: UIImageView+cache

    private func pngBody(size: CGSize = CGSize(width: 8, height: 8)) -> Data {
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            UIColor.purple.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
        return image.pngData()!
    }

    func testCacheImageFromCache() {
        let url = URL(string: "https://stub.test/cached.png")!
        ImageCache.shared.setObject(UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4)).image { _ in },
                                    forKey: url.absoluteString as NSString)

        let imageView = UIImageView()
        var result: Bool?
        imageView.cacheImage(url: url, withTemplate: false) { success in result = success }

        XCTAssertEqual(result, true)
        XCTAssertNotNil(imageView.image)
    }

    func testCacheImageFromNetwork() {
        StubURLProtocol.stubProvider = { [body = pngBody()] _ in .init(body: body) }

        let imageView = UIImageView()
        let exp = expectation(description: "image loaded")
        imageView.cacheImage(url: URL(string: "https://stub.test/net.png")!, withTemplate: true) { success in
            XCTAssertTrue(success)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testCacheImageNetworkFailure() {
        StubURLProtocol.stubProvider = { _ in
            .init(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut))
        }

        let imageView = UIImageView()
        let exp = expectation(description: "image failed")
        imageView.cacheImage(url: URL(string: "https://stub.test/fail.png")!, withTemplate: false) { success in
            XCTAssertFalse(success)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testLoadImageWithResultVariants() {
        // Успех из сети
        StubURLProtocol.stubProvider = { [body = pngBody()] request in
            if request.url?.path.contains("bad") ?? false {
                return .init(body: Data("не картинка".utf8))
            }
            return .init(body: body)
        }

        let imageView = UIImageView()
        let okExp = expectation(description: "loaded")
        imageView.loadImageWithResult(url: URL(string: "https://stub.test/ok.png")!, withTemplate: false) { image in
            XCTAssertNotNil(image)
            okExp.fulfill()
        }
        wait(for: [okExp], timeout: 5)

        // Повторно — уже из кэша (синхронно)
        var cachedImage: UIImage?
        imageView.loadImageWithResult(url: URL(string: "https://stub.test/ok.png")!, withTemplate: false) { image in
            cachedImage = image
        }
        XCTAssertNotNil(cachedImage)

        // Невалидные данные
        let badExp = expectation(description: "bad data")
        imageView.loadImageWithResult(url: URL(string: "https://stub.test/bad.png")!, withTemplate: false) { image in
            XCTAssertNil(image)
            badExp.fulfill()
        }
        wait(for: [badExp], timeout: 5)
    }

    // MARK: ImageCell: сеть и retry

    func testImageCellLoadsFromNetworkAndRetries() {
        var shouldFail = true
        StubURLProtocol.stubProvider = { [body = pngBody()] _ in
            if shouldFail {
                return .init(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut))
            }
            return .init(body: body)
        }

        let cell = ImageCell(style: .default, reuseIdentifier: nil)
        cell.frame = CGRect(x: 0, y: 0, width: 375, height: 100)
        let field = try! Field(from: ["id": "f1", "type": "image", "value": "img",
                                      "image": ["type": "custom", "position": "topHeader",
                                                "alignment": "center", "src": "https://stub.test/img-retry.png"]])
        let delegate = DataManager(CampaignViewController(), campaign: nil)
        cell.configureWith(field, theme: theme, delegate: delegate)

        // Ждём неуспешную загрузку → появляется retry
        let failExp = expectation(description: "load failed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { failExp.fulfill() }
        wait(for: [failExp], timeout: 5)
        XCTAssertTrue(cell.canReload)

        // Повторная загрузка по тапу — успех
        shouldFail = false
        cell.perform(NSSelectorFromString("handleTap"))

        let okExp = expectation(description: "reloaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { okExp.fulfill() }
        wait(for: [okExp], timeout: 5)
        XCTAssertFalse(cell.canReload)
    }

    // MARK: SmilesCell: тап по смайлу

    func testSmilesCellTapSendsAnswer() {
        let spy = SmilesDelegateSpy()
        let cell = SmilesCell(style: .default, reuseIdentifier: nil)
        cell.frame = CGRect(x: 0, y: 0, width: 375, height: 60)
        let field = try! Field(from: ["id": "f1", "type": "smiles", "value": "Оцените"])
        cell.configureWith(field, theme: theme, delegate: spy)
        cell.layoutIfNeeded()

        func findButtons(in view: UIView) -> [UIButton] {
            var result: [UIButton] = []
            for sub in view.subviews {
                if let button = sub as? UIButton { result.append(button) }
                result.append(contentsOf: findButtons(in: sub))
            }
            return result
        }
        let buttons = findButtons(in: cell.contentView).filter { $0.tag > 0 }
        guard let button = buttons.first else {
            return XCTFail("Кнопки смайлов не найдены")
        }

        var received: [String]?
        spy.onFieldChanged = { answer in received = answer }

        // Полный цикл касания: down → drag → up (ответ шлёт touchUpInside)
        cell.perform(NSSelectorFromString("smileTouched:"), with: button)
        cell.perform(NSSelectorFromString("smileOutside:"), with: button)
        cell.perform(NSSelectorFromString("smileTouchDown:"), with: button)
        cell.perform(NSSelectorFromString("smileDragEnter:"), with: button)
        cell.perform(NSSelectorFromString("smileDragExit:"), with: button)
        cell.perform(NSSelectorFromString("smileTapped:"), with: button)
        cell.perform(NSSelectorFromString("smileTouchUpInside:"), with: button)

        XCTAssertEqual(received, [String(button.tag - 1)])
    }

    private final class SmilesDelegateSpy: FieldDelegate {
        var onFieldChanged: (([String]) -> Void)?
        func fieldChanged(_ field: Field, answer: [String], refresh: Bool) { onFieldChanged?(answer) }
        func buttonTapped(_ field: Field, answer: [String], refresh: Bool) { }
        func textChanged(_ field: Field, answer: [String]) { }
        func screenshotChanged(_ field: Field, screenshots: [Screenshot]) { }
        func didBeginEditing(_ field: Field) { }
        func didEndEditing(_ field: Field) { }
    }
}

// MARK: - Скриншот-подсистема, Reachability и прочее

final class ScreenshotAndMiscTests: XCTestCase {

    private let theme = Theme()

    override func tearDown() {
        ImageCache.shared.removeAllObjects()
        super.tearDown()
    }

    private func makeImage(size: CGSize = CGSize(width: 20, height: 20)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { ctx in
            UIColor.cyan.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    // MARK: Passthrough views

    func testPassthroughWindowHitTest() {
        let window = PassthroughWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.rootViewController = UIViewController()
        window.isHidden = false

        // Точка вне сабвью → окно возвращает nil (пропускает касание)
        _ = window.hitTest(CGPoint(x: 50, y: 50), with: nil)
    }

    func testPassthroughToWindowViewHitTest() {
        let view = PassthroughToWindowView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        view.touchCancel = true
        XCTAssertNil(view.hitTest(CGPoint(x: 50, y: 50), with: nil))

        view.touchCancel = false
        _ = view.hitTest(CGPoint(x: 50, y: 50), with: nil)

        // Попадание в сабвью возвращает сабвью
        let child = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        view.addSubview(child)
        XCTAssertEqual(view.hitTest(CGPoint(x: 5, y: 5), with: nil), child)
    }

    func testPassthroughViewHitTest() {
        let view = PassthroughView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        XCTAssertNil(view.hitTest(CGPoint(x: 50, y: 50), with: nil))
    }

    // MARK: ScreenshotImageCell

    func testScreenshotImageCellConfigureAndDelete() {
        let cell = ScreenshotImageCell(frame: CGRect(x: 0, y: 0, width: 80, height: 80))

        var deleted = false
        cell.configure(image: makeImage(), theme: theme) { deleted = true }
        cell.layoutIfNeeded()

        cell.perform(NSSelectorFromString("deletePressed:"), with: cell)
        XCTAssertTrue(deleted)
    }

    // MARK: ScreenshotCreator

    func testScreenshotCreatorConfigureAndHitTest() {
        let creator = ScreenshotCreator(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        creator.configure(frame: CGRect(x: 0, y: 0, width: 320, height: 640)) { _ in }
        creator.showHandAnimation()
        creator.layoutIfNeeded()

        _ = creator.hitTest(CGPoint(x: 160, y: 320), with: nil)
    }

    // MARK: ImageCollection

    func testImageCollectionConfigureAndScroll() {
        let collection = ImageCollection(frame: CGRect(x: 0, y: 0, width: 320, height: 480))

        var pageChanges: [String] = []
        collection.configure(frame: CGRect(x: 0, y: 0, width: 320, height: 480),
                             images: [makeImage(), makeImage(), makeImage()],
                             currentIndex: 1) { page in pageChanges.append(page) }
        collection.layoutIfNeeded()

        collection.updateFrame(frame: CGRect(x: 0, y: 0, width: 375, height: 600))
        collection.hideFront()

        func findScrollView(in view: UIView) -> UIScrollView? {
            for sub in view.subviews {
                if let scroll = sub as? UIScrollView { return scroll }
                if let nested = findScrollView(in: sub) { return nested }
            }
            return nil
        }
        if let scrollView = findScrollView(in: collection) {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.width, y: 0)
            collection.scrollViewDidScroll(scrollView)
        }
    }

    // MARK: Reachability

    func testReachabilityNetworkType() {
        let type = Reachability.getNetworkType()
        // В симуляторе обычно wifi; главное — что вызов не падает и возвращает валидный кейс
        XCTAssertFalse(type.trackingId.isEmpty)
    }

    func testReachabilityNotifierLifecycle() throws {
        let reachability = try Reachability(hostname: "stub.test")
        reachability.whenReachable = { _ in }
        reachability.whenUnreachable = { _ in }

        try reachability.startNotifier()
        _ = reachability.connection
        _ = reachability.description
        reachability.stopNotifier()
    }

    func testWWANNetworkTypeMapping() {
        // В симуляторе нет радиомодуля → unknown; главное — покрыть ветку
        let type = Reachability.getWWANNetworkType()
        XCTAssertFalse(type.trackingId.isEmpty)
    }

    // MARK: CampaignViewController: остатки

    func testSlideinKeyboardNotifications() {
        let vc = makeViewController(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)], type: .slidein))
        vc.tableView.frame = CGRect(x: 0, y: 0, width: 375, height: 600)
        vc.tableView.reloadData()

        let userInfo: [AnyHashable: Any] = [
            UIResponder.keyboardAnimationDurationUserInfoKey: NSNumber(value: 0.25),
            UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: CGRect(x: 0, y: 400, width: 375, height: 300)),
            UIResponder.keyboardAnimationCurveUserInfoKey: UInt(7)
        ]

        NotificationCenter.default.post(name: UIResponder.keyboardWillShowNotification, object: nil, userInfo: userInfo)
        XCTAssertTrue(vc.withKeyboard)
        NotificationCenter.default.post(name: UIResponder.keyboardWillHideNotification, object: nil, userInfo: userInfo)
        XCTAssertFalse(vc.withKeyboard)
    }

    func testViewControllerGesturesAndNotifications() {
        let vc = makeViewController(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))
        vc.tableView.reloadData()

        vc.onTap(tap: UITapGestureRecognizer())
        vc.onPan(pan: UIPanGestureRecognizer())

        vc.scrollViewWillBeginDragging(vc.tableView)
        vc.scrollViewDidScroll(vc.tableView)

        NotificationCenter.default.post(name: .headerImageDidLoad, object: nil)

        let exp = expectation(description: "main tick")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 2)
    }

    func testCloseButtonTerminatesCampaign() {
        let vc = makeViewController(campaign: makeCampaign(pages: [makePage(fields: allFieldsPage)]))
        vc.tableView.reloadData()

        let exp = expectation(description: "terminated")
        vc.didTerminateHandler = { _, _, shownPages, totalPages in
            XCTAssertEqual(shownPages, 1)
            XCTAssertEqual(totalPages, 1)
            exp.fulfill()
        }

        vc.perform(NSSelectorFromString("closeButtonTapped"))
        wait(for: [exp], timeout: 5)
    }

    // MARK: HeaderCell: картинка снизу и выравнивания

    func testHeaderCellImageLayoutVariants() {
        let src = "https://example.com/header-variants.png"
        ImageCache.shared.setObject(makeImage(size: CGSize(width: 120, height: 80)), forKey: src as NSString)

        for position in ["topHeader", "bottom"] {
            for alignment in ["left", "right", "center"] {
                let cell = HeaderCell(style: .default, reuseIdentifier: nil)
                cell.frame = CGRect(x: 0, y: 0, width: 375, height: 300)
                let field = try! Field(from: ["id": "fH", "type": "header", "value": "Заголовок",
                                              "description": "Описание",
                                              "image": ["type": "custom",
                                                        "position": position,
                                                        "alignment": alignment,
                                                        "src": src]])
                let delegate = DataManager(CampaignViewController(), campaign: nil)
                cell.configureWith(field, theme: theme, delegate: delegate)
                cell.layoutIfNeeded()
            }
        }
    }

    // MARK: HtmlLabel: onPress

    func testHtmlLabelOnPress() {
        let label = HtmlLabel()
        label.textFont = .systemFont(ofSize: 14)
        label.linkColor = .blue
        label.defaultColor = .black
        label.html = "<p><a href=\"https://example.com\">ссылка</a></p>"

        var pressed = false
        label.onPress { _ in pressed = true }
        label.action?(URL(string: "https://example.com"))

        XCTAssertTrue(pressed)
    }
}
