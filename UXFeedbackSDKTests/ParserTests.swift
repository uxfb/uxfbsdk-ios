import XCTest
@testable import UXFeedbackSDK

final class ParserTests: XCTestCase {

    private var parser: Parser!

    override func setUp() {
        super.setUp()
        parser = Parser(theme: nil)
    }

    override func tearDown() {
        parser = nil
        super.tearDown()
    }

    // MARK: - Theme Decoding

    func testDecodeThemeWithValidData() {
        let dict: [String: Any] = [
            "bgColor": "#FF0000",
            "mainColor": "#00FF00",
            "btnBorderRadius": 16,
            "formBorderRadius": 10
        ]

        let theme = try? Theme(from: dict)

        XCTAssertNotNil(theme)
        XCTAssertEqual(theme?.btnBorderRadius, 16)
        XCTAssertEqual(theme?.formBorderRadius, 10)
    }

    func testDecodeThemeWithEmptyDict() {
        let theme = try? Theme(from: [:] as [String: Any])
        XCTAssertNotNil(theme)
    }

    func testDecodeThemeWithPartialData() {
        let dict: [String: Any] = [
            "bgColor": "#AABBCC"
        ]

        let theme = try? Theme(from: dict)
        XCTAssertNotNil(theme)
    }

    // MARK: - Copyright Decoding

    func testDecodeCopyrightValid() {
        let dict: [String: Any] = [
            "isShow": true,
            "href": "https://example.com",
            "image": ["light": "logo.png"]
        ]

        let copyright = try? Copyright(from: dict)

        XCTAssertNotNil(copyright)
        XCTAssertTrue(copyright!.isShow)
        XCTAssertEqual(copyright?.href, "https://example.com")
    }

    func testDecodeCopyrightMinimal() {
        let dict: [String: Any] = [
            "isShow": false
        ]

        let copyright = try? Copyright(from: dict)

        XCTAssertNotNil(copyright)
        XCTAssertFalse(copyright!.isShow)
    }

    // MARK: - TextProperties Decoding

    func testDecodeTextPropertiesValid() {
        let dict: [String: Any] = [
            "h1": [["name": "#", "type": "size", "value": "1,09/1,11"]],
            "h2": [["name": "##", "type": "size", "value": "0,9/0,92"]],
            "p": []
        ]

        let textProps = try? TextProperties(from: dict)

        XCTAssertNotNil(textProps)
        XCTAssertEqual(textProps?.h1?.count, 1)
        XCTAssertEqual(textProps?.h2?.count, 1)
        XCTAssertEqual(textProps?.p?.count, 0)
    }

    func testDecodeTextPropertiesEmpty() {
        let textProps = try? TextProperties(from: [:] as [String: Any])
        XCTAssertNotNil(textProps)
    }

    // MARK: - Field Decoding

    func testDecodeFieldWithAllProperties() {
        let dict: [String: Any] = [
            "id": "f1",
            "type": "header",
            "value": "Welcome",
            "description": "A description",
            "required": true,
            "placeholder": "Enter text",
            "mode": "multi",
            "warning": "Required field",
            "ratingCount": 5
        ]

        let field = try? Field(from: dict)

        XCTAssertNotNil(field)
        XCTAssertEqual(field?.id, "f1")
        XCTAssertEqual(field?.type, .header)
        XCTAssertEqual(field?.value, "Welcome")
        XCTAssertEqual(field?.description, "A description")
        XCTAssertEqual(field?.required, true)
        XCTAssertEqual(field?.placeholder, "Enter text")
        XCTAssertEqual(field?.mode, "multi")
        XCTAssertEqual(field?.warning, "Required field")
        XCTAssertEqual(field?.ratingCount, 5)
    }

    func testDecodeFieldWithOptions() {
        let dict: [String: Any] = [
            "id": "f1",
            "type": "checkboxes",
            "options": [
                ["id": "o1", "value": "Option 1", "exceptional": false],
                ["id": "o2", "value": "Option 2"]
            ]
        ]

        let field = try? Field(from: dict)

        XCTAssertNotNil(field)
        XCTAssertEqual(field?.options?.count, 2)
        XCTAssertEqual(field?.options?.first?.id, "o1")
        XCTAssertEqual(field?.options?.first?.value, "Option 1")
    }

    func testDecodeFieldWithImage() {
        let dict: [String: Any] = [
            "id": "f1",
            "type": "header",
            "image": [
                "type": "custom",
                "position": "top",
                "alignment": "center",
                "src": "https://example.com/image.png",
                "3x": "https://example.com/image@3x.png"
            ]
        ]

        let field = try? Field(from: dict)

        XCTAssertNotNil(field?.image)
        XCTAssertEqual(field?.image?.type, "custom")
        XCTAssertEqual(field?.image?.position, "top")
        XCTAssertEqual(field?.image?.alignment, "center")
        XCTAssertEqual(field?.image?.src, "https://example.com/image.png")
        XCTAssertEqual(field?.image?.threeX, "https://example.com/image@3x.png")
    }

    func testDecodeFieldWithMessages() {
        let dict: [String: Any] = [
            "id": "f1",
            "type": "nps",
            "messages": [
                "negative": "Not likely",
                "positive": "Very likely"
            ]
        ]

        let field = try? Field(from: dict)

        XCTAssertNotNil(field?.messages)
        XCTAssertEqual(field?.messages?.negative, "Not likely")
        XCTAssertEqual(field?.messages?.positive, "Very likely")
    }

    func testDecodeFieldWithButtons() {
        let dict: [String: Any] = [
            "id": "f1",
            "type": "screenshot",
            "buttons": [
                "create": "Take screenshot",
                "upload": "Upload image"
            ]
        ]

        let field = try? Field(from: dict)

        XCTAssertNotNil(field?.buttons)
        XCTAssertEqual(field?.buttons?.create, "Take screenshot")
        XCTAssertEqual(field?.buttons?.upload, "Upload image")
    }

    // MARK: - Page Decoding

    func testDecodePageWithFieldsAndButtons() {
        let dict: [String: Any] = [
            "id": "p1",
            "type": 1,
            "fields": [
                ["id": "f1", "type": "header", "value": "Title"],
                ["id": "f2", "type": "stars"]
            ],
            "buttons": [
                ["id": "b1", "type": "button", "value": "Submit"]
            ]
        ]

        let page = try? Page(from: dict)

        XCTAssertNotNil(page)
        XCTAssertEqual(page?.id, "p1")
        XCTAssertEqual(page?.type, 1)
        XCTAssertEqual(page?.fields.count, 2)
        XCTAssertEqual(page?.buttons.count, 1)
    }

    // MARK: - CampaignData Parsing

    func testParseCampaignDataValid() {
        let dict: [String: Any] = [
            "campaignId": 42,
            "priority": 5,
            "data": ["key": "value"]
        ]

        let campaignData = parser.parseCampaignData(campaignDataInfo: dict,
                                                     copyright: nil,
                                                     textProperties: nil)

        XCTAssertNotNil(campaignData)
        XCTAssertEqual(campaignData?.campaignId, 42)
        XCTAssertEqual(campaignData?.priority, 5)
        XCTAssertNotNil(campaignData?.data)
    }

    func testParseCampaignDataMissingId() {
        let dict: [String: Any] = [
            "priority": 5
        ]

        let campaignData = parser.parseCampaignData(campaignDataInfo: dict,
                                                     copyright: nil,
                                                     textProperties: nil)
        XCTAssertNil(campaignData)
    }

    func testParseCampaignDataMissingPriority() {
        let dict: [String: Any] = [
            "campaignId": 42
        ]

        let campaignData = parser.parseCampaignData(campaignDataInfo: dict,
                                                     copyright: nil,
                                                     textProperties: nil)
        XCTAssertNil(campaignData)
    }

    func testParseCampaignDataWithCopyright() {
        let dict: [String: Any] = [
            "campaignId": 1,
            "priority": 1
        ]
        let copyright = Copyright(isShow: true, href: "https://test.com", image: nil)

        let campaignData = parser.parseCampaignData(campaignDataInfo: dict,
                                                     copyright: copyright,
                                                     textProperties: nil)

        XCTAssertNotNil(campaignData)
        XCTAssertNotNil(campaignData?.copyright)
    }

    // MARK: - Campaign Parsing

    func testParseCampaignMinimal() {
        let dict: [String: Any] = [
            "campaignId": 10,
            "type": 101,
            "projectId": 123,
            "autoclose": 5.0,
            "progress": true,
            "pages": [] as [[String: Any]],
            "transforms": [] as [[String: Any]]
        ]

        let campaign = parser.parseCampaign(campaignInfo: dict,
                                             copyright: nil,
                                             textProperties: nil)

        XCTAssertNotNil(campaign)
        XCTAssertEqual(campaign?.campaignId, 10)
        XCTAssertEqual(campaign?.type, .popup)
        XCTAssertEqual(campaign?.projectId, "123")
        XCTAssertEqual(campaign?.autoclose, 5.0)
        XCTAssertEqual(campaign?.progress, true)
        XCTAssertTrue(campaign?.pages.isEmpty ?? false)
        XCTAssertTrue(campaign?.transforms.isEmpty ?? false)
    }

    func testParseCampaignSlideIn() {
        let dict: [String: Any] = [
            "campaignId": 20,
            "type": 102,
            "projectId": 456,
            "autoclose": 0.0,
            "pages": [] as [[String: Any]],
            "transforms": [] as [[String: Any]]
        ]

        let campaign = parser.parseCampaign(campaignInfo: dict,
                                             copyright: nil,
                                             textProperties: nil)

        XCTAssertEqual(campaign?.type, .slidein)
    }

    func testParseCampaignWithPages() {
        let dict: [String: Any] = [
            "campaignId": 30,
            "type": 101,
            "projectId": 1,
            "pages": [
                [
                    "id": "p1",
                    "type": 1,
                    "fields": [
                        ["id": "f1", "type": "header", "value": "Welcome"],
                        ["id": "f2", "type": "stars"]
                    ],
                    "buttons": [
                        ["id": "b1", "type": "button", "value": "Submit"]
                    ]
                ] as [String : Any]
            ],
            "transforms": [] as [[String: Any]]
        ]

        let campaign = parser.parseCampaign(campaignInfo: dict,
                                             copyright: nil,
                                             textProperties: nil)

        XCTAssertEqual(campaign?.pages.count, 1)
        XCTAssertEqual(campaign?.pages.first?.id, "p1")
        XCTAssertEqual(campaign?.pages.first?.fields.count, 2)
        XCTAssertEqual(campaign?.pages.first?.buttons.count, 1)
        XCTAssertEqual(campaign?.pages.first?.fields[0].type, .header)
        XCTAssertEqual(campaign?.pages.first?.fields[0].value, "Welcome")
        XCTAssertEqual(campaign?.pages.first?.fields[1].type, .stars)
        XCTAssertEqual(campaign?.pages.first?.buttons[0].type, .button)
    }

    func testParseCampaignWithTargeting() {
        let dict: [String: Any] = [
            "campaignId": 40,
            "type": 101,
            "projectId": 1,
            "pages": [] as [[String: Any]],
            "transforms": [] as [[String: Any]],
            "targeting": [
                "trigger": [
                    "value": "page_view",
                    "seconds": 2.5,
                    "enabled": true,
                    "counts": 3
                ]
            ] as [String : Any]
        ]

        let campaign = parser.parseCampaign(campaignInfo: dict,
                                             copyright: nil,
                                             textProperties: nil)

        XCTAssertNotNil(campaign?.targeting)
        XCTAssertEqual(campaign?.targeting.value, "page_view")
        XCTAssertEqual(campaign?.targeting.seconds, 2.5)
        XCTAssertEqual(campaign?.targeting.enabled, true)
    }

    func testParseCampaignWithTransforms() {
        let dict: [String: Any] = [
            "campaignId": 50,
            "type": 101,
            "projectId": 1,
            "pages": [] as [[String: Any]],
            "transforms": [
                [
                    "id": "t1",
                    "to": ["action": "transition", "value": "p2", "type": "toPage"],
                    "scenarios": [
                        [
                            "id": "s1",
                            "name": "test",
                            "conditions": [
                                [
                                    "id": "c1",
                                    "from": ["field": "f1", "page": "p1"],
                                    "condition": ["rule": "equal", "value": ["opt1"]]
                                ]
                            ]
                        ]
                    ]
                ] as [String : Any]
            ]
        ]

        let campaign = parser.parseCampaign(campaignInfo: dict,
                                             copyright: nil,
                                             textProperties: nil)

        XCTAssertEqual(campaign?.transforms.count, 1)
        XCTAssertEqual(campaign?.transforms.first?.id, "t1")
    }

    func testParseCampaignWithPrivacy() {
        let dict: [String: Any] = [
            "campaignId": 60,
            "type": 101,
            "projectId": 1,
            "pages": [] as [[String: Any]],
            "transforms": [] as [[String: Any]],
            "privacy": [
                "warningMessage": "Accept terms",
                "type": "checkbox",
                "declaration": "I agree",
                "showType": "all",
                "privacyPages": ["p1"],
                "enabled": true
            ] as [String : Any]
        ]

        let campaign = parser.parseCampaign(campaignInfo: dict,
                                             copyright: nil,
                                             textProperties: nil)

        XCTAssertNotNil(campaign?.privacy)
        XCTAssertTrue(campaign?.privacy?.enabled ?? false)
        XCTAssertEqual(campaign?.privacy?.declaration, "I agree")
    }

    func testParseCampaignWithCustomTheme() {
        let dict: [String: Any] = [
            "campaignId": 70,
            "type": 101,
            "projectId": 1,
            "pages": [] as [[String: Any]],
            "transforms": [] as [[String: Any]],
            "design": [
                "theme": 0,
                "bgColor": "#FF0000",
                "mainColor": "#00FF00"
            ] as [String : Any]
        ]

        let campaign = parser.parseCampaign(campaignInfo: dict,
                                             copyright: nil,
                                             textProperties: nil)

        XCTAssertNotNil(campaign?.theme)
    }

    func testParseCampaignUsesInitTheme() {
        let customTheme = Theme()
        customTheme.bgColor = .green
        let parserWithTheme = Parser(theme: customTheme, isInitTheme: true)

        let dict: [String: Any] = [
            "campaignId": 80,
            "type": 101,
            "projectId": 1,
            "pages": [] as [[String: Any]],
            "transforms": [] as [[String: Any]]
        ]

        let campaign = parserWithTheme.parseCampaign(campaignInfo: dict,
                                                      copyright: nil,
                                                      textProperties: nil)

        XCTAssertEqual(campaign?.theme.bgColor, UIColor.green)
    }
}
