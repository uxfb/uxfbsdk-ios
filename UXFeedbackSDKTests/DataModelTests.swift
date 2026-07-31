import XCTest
@testable import UXFeedbackSDK

final class CampaignTypeTests: XCTestCase {

    func testPopupRawValue() {
        XCTAssertEqual(CampaignType.popup.rawValue, "101")
    }

    func testSlideinRawValue() {
        XCTAssertEqual(CampaignType.slidein.rawValue, "102")
    }

    func testCampaignTypeFromRawValue() {
        XCTAssertEqual(CampaignType(rawValue: "101"), .popup)
        XCTAssertEqual(CampaignType(rawValue: "102"), .slidein)
        XCTAssertNil(CampaignType(rawValue: "999"))
    }
}

final class CampaignDataTests: XCTestCase {

    func testCampaignDataInitialization() {
        let data = CampaignData(campaignId: 42, priority: 5)

        XCTAssertEqual(data.campaignId, 42)
        XCTAssertEqual(data.priority, 5)
        XCTAssertNil(data.data)
        XCTAssertNil(data.copyright)
        XCTAssertNil(data.textProperties)
        XCTAssertNil(data.campaign)
        XCTAssertFalse(data.needsToShow)
    }

    func testCampaignDataNeedsToShowMutable() {
        var data = CampaignData(campaignId: 1, priority: 1)
        XCTAssertFalse(data.needsToShow)

        data.needsToShow = true
        XCTAssertTrue(data.needsToShow)
    }
}

final class CampaignTests: XCTestCase {

    func testShowDelayMatchingEvent() {
        let targeting = Targeting(seconds: 3.5, value: "page_view")
        let campaign = Campaign(campaignId: 1,
                                theme: Theme(),
                                pages: [],
                                type: .popup,
                                targeting: targeting,
                                transforms: [],
                                autoclose: 0)

        let delay = campaign.showDelay(eventName: "page_view")
        XCTAssertEqual(delay, 3.5)
    }

    func testShowDelayNonMatchingEvent() {
        let targeting = Targeting(seconds: 3.5, value: "page_view")
        let campaign = Campaign(campaignId: 1,
                                theme: Theme(),
                                pages: [],
                                type: .popup,
                                targeting: targeting,
                                transforms: [],
                                autoclose: 0)

        let delay = campaign.showDelay(eventName: "other_event")
        XCTAssertEqual(delay, 0.1)
    }

    func testShowDelayNilSeconds() {
        let targeting = Targeting(value: "page_view")
        let campaign = Campaign(campaignId: 1,
                                theme: Theme(),
                                pages: [],
                                type: .popup,
                                targeting: targeting,
                                transforms: [],
                                autoclose: 0)

        let delay = campaign.showDelay(eventName: "page_view")
        XCTAssertEqual(delay, 0.1)
    }

    func testUpdateTheme() {
        var campaign = Campaign(campaignId: 1,
                                theme: Theme(),
                                pages: [],
                                type: .popup,
                                targeting: Targeting(),
                                transforms: [],
                                autoclose: 0)

        let newTheme = Theme()
        newTheme.bgColor = .red
        campaign.updateTheme(theme: newTheme)

        XCTAssertEqual(campaign.theme.bgColor, UIColor.red)
    }
}

final class FieldTypeTests: XCTestCase {

    func testFieldTypeRawValues() {
        XCTAssertEqual(FieldType.text.rawValue, "text")
        XCTAssertEqual(FieldType.button.rawValue, "button")
        XCTAssertEqual(FieldType.checkbox.rawValue, "checkboxes")
        XCTAssertEqual(FieldType.email.rawValue, "email")
        XCTAssertEqual(FieldType.header.rawValue, "header")
        XCTAssertEqual(FieldType.image.rawValue, "image")
        XCTAssertEqual(FieldType.input.rawValue, "comment")
        XCTAssertEqual(FieldType.radiobutton.rawValue, "radiobuttons")
        XCTAssertEqual(FieldType.smiles.rawValue, "smiles")
        XCTAssertEqual(FieldType.stars.rawValue, "stars")
        XCTAssertEqual(FieldType.bottom.rawValue, "bottom")
        XCTAssertEqual(FieldType.nps.rawValue, "nps")
        XCTAssertEqual(FieldType.rating.rawValue, "rating")
        XCTAssertEqual(FieldType.screenshot.rawValue, "screenshot")
    }

    func testFieldTypeFromRawValue() {
        XCTAssertEqual(FieldType(rawValue: "text"), .text)
        XCTAssertEqual(FieldType(rawValue: "checkboxes"), .checkbox)
        XCTAssertEqual(FieldType(rawValue: "comment"), .input)
        XCTAssertNil(FieldType(rawValue: "unknown"))
    }
}

final class FieldTests: XCTestCase {

    func testFieldDefaultValues() throws {
        let field = try Field(from: ["id": "f1", "type": "text", "value": "Hello"] as [String: Any])

        XCTAssertEqual(field.id, "f1")
        XCTAssertEqual(field.type, .text)
        XCTAssertEqual(field.value, "Hello")
        XCTAssertNil(field.description)
        XCTAssertTrue(field.answers.isEmpty)
        XCTAssertFalse(field.isError)
        XCTAssertFalse(field.isLastPage)
    }

    func testFieldMutableProperties() throws {
        var field = try Field(from: ["id": "f1", "type": "stars"] as [String: Any])

        field.answers = ["5"]
        field.isError = true
        field.isLastPage = true

        XCTAssertEqual(field.answers, ["5"])
        XCTAssertTrue(field.isError)
        XCTAssertTrue(field.isLastPage)
    }
}

final class OptionTests: XCTestCase {

    func testOptionCodable() throws {
        let json = """
        {"id": "opt1", "value": "Option A", "exceptional": true}
        """.data(using: .utf8)!

        let option = try JSONDecoder().decode(Option.self, from: json)

        XCTAssertEqual(option.id, "opt1")
        XCTAssertEqual(option.value, "Option A")
        XCTAssertEqual(option.exceptional, true)
    }

    func testOptionWithoutExceptional() throws {
        let json = """
        {"id": "opt2", "value": "Option B"}
        """.data(using: .utf8)!

        let option = try JSONDecoder().decode(Option.self, from: json)

        XCTAssertEqual(option.id, "opt2")
        XCTAssertEqual(option.value, "Option B")
        XCTAssertNil(option.exceptional)
    }

    func testOptionEncodeDecode() throws {
        let option = Option(id: "opt3", value: "Option C", exceptional: false)
        let data = try JSONEncoder().encode(option)
        let decoded = try JSONDecoder().decode(Option.self, from: data)

        XCTAssertEqual(decoded.id, option.id)
        XCTAssertEqual(decoded.value, option.value)
        XCTAssertEqual(decoded.exceptional, option.exceptional)
    }
}

final class PageTests: XCTestCase {

    func testPageDecoding() throws {
        let dict: [String: Any] = [
            "id": "p1",
            "type": 1,
            "fields": [["id": "f1", "type": "text", "value": "text"]],
            "buttons": [["id": "b1", "type": "button", "value": "Submit"]]
        ]
        let page = try Page(from: dict)

        XCTAssertEqual(page.id, "p1")
        XCTAssertEqual(page.type, 1)
        XCTAssertEqual(page.fields.count, 1)
        XCTAssertEqual(page.buttons.count, 1)
    }
}

final class PrivacyTests: XCTestCase {

    func testPrivacyCodable() throws {
        let json = """
        {
            "warningMessage": "Please accept",
            "type": "checkbox",
            "declaration": "I agree to terms",
            "showType": "all",
            "privacyPages": ["p1", "p2"],
            "enabled": true
        }
        """.data(using: .utf8)!

        let privacy = try JSONDecoder().decode(Privacy.self, from: json)

        XCTAssertEqual(privacy.warningMessage, "Please accept")
        XCTAssertEqual(privacy.type, "checkbox")
        XCTAssertEqual(privacy.declaration, "I agree to terms")
        XCTAssertEqual(privacy.showType, "always")
        XCTAssertEqual(privacy.privacyPages, ["p1", "p2"])
        XCTAssertTrue(privacy.enabled)
    }

    func testPrivacyWithoutWarning() throws {
        let json = """
        {
            "type": "text",
            "declaration": "Terms",
            "showType": "once",
            "privacyPages": [],
            "enabled": false
        }
        """.data(using: .utf8)!

        let privacy = try JSONDecoder().decode(Privacy.self, from: json)
        XCTAssertNil(privacy.warningMessage)
        XCTAssertFalse(privacy.enabled)
    }
}

final class PrivacyViewStateTests: XCTestCase {

    private final class RecordingDelegate: PrivacyDelegate {
        var received: [Bool?] = []
        func checked(_ value: Bool?) { received.append(value) }
        func tapPrivacy() {}
    }

    func testPreparePrivacyAppliesDefaultOnlyOnce() {
        let delegate = RecordingDelegate()
        let view = PrivacyView(theme: Theme(), delegate: delegate)

        view.preparePrivacy("checkboxDisabled")
        XCTAssertEqual(delegate.received, [false])

        view.preparePrivacy("checkboxDisabled")
        view.preparePrivacy("checkboxDisabled")
        XCTAssertEqual(delegate.received, [false, nil, nil])
    }

    func testPreparePrivacyCheckboxEnabledDefault() {
        let delegate = RecordingDelegate()
        let view = PrivacyView(theme: Theme(), delegate: delegate)

        view.preparePrivacy("checkboxEnabled")
        view.preparePrivacy("checkboxEnabled")
        XCTAssertEqual(delegate.received, [true, nil])
    }
}

final class CopyrightTests: XCTestCase {

    func testCopyrightCodable() throws {
        let json = """
        {
            "isShow": true,
            "href": "https://example.com",
            "image": {"light": "logo_light.png", "dark": "logo_dark.png"}
        }
        """.data(using: .utf8)!

        let copyright = try JSONDecoder().decode(Copyright.self, from: json)

        XCTAssertTrue(copyright.isShow)
        XCTAssertEqual(copyright.href, "https://example.com")
        XCTAssertEqual(copyright.image?["light"], "logo_light.png")
        XCTAssertEqual(copyright.image?["dark"], "logo_dark.png")
    }

    func testCopyrightMinimal() throws {
        let json = """
        {"isShow": false}
        """.data(using: .utf8)!

        let copyright = try JSONDecoder().decode(Copyright.self, from: json)
        XCTAssertFalse(copyright.isShow)
        XCTAssertNil(copyright.href)
        XCTAssertNil(copyright.image)
    }
}

final class ProgressTests: XCTestCase {

    func testProgressCodable() throws {
        let json = """
        {"enabled": true}
        """.data(using: .utf8)!

        let progress = try JSONDecoder().decode(Progress.self, from: json)
        XCTAssertTrue(progress.enabled)
    }
}

final class ToggleStatusTests: XCTestCase {

    func testToggleStatusCodable() throws {
        let jsonTrue = """
        {"togglesStatus": true}
        """.data(using: .utf8)!

        let statusTrue = try JSONDecoder().decode(ToggleStatus.self, from: jsonTrue)
        XCTAssertTrue(statusTrue.togglesStatus)

        let jsonFalse = """
        {"togglesStatus": false}
        """.data(using: .utf8)!

        let statusFalse = try JSONDecoder().decode(ToggleStatus.self, from: jsonFalse)
        XCTAssertFalse(statusFalse.togglesStatus)
    }

    func testToggleStatusEncodeDecode() throws {
        let status = ToggleStatus(togglesStatus: true)
        let data = try JSONEncoder().encode(status)
        let decoded = try JSONDecoder().decode(ToggleStatus.self, from: data)
        XCTAssertEqual(decoded.togglesStatus, status.togglesStatus)
    }
}

final class ScreenshotDataTests: XCTestCase {

    func testScreenshotDataCodable() throws {
        let screenshotData = ScreenshotData(id: "ss1", base64image: "abc123==")
        let data = try JSONEncoder().encode(screenshotData)
        let decoded = try JSONDecoder().decode(ScreenshotData.self, from: data)

        XCTAssertEqual(decoded.id, "ss1")
        XCTAssertEqual(decoded.base64image, "abc123==")
    }
}

final class TextPropertyTests: XCTestCase {

    func testTextPropertyCodable() throws {
        let json = """
        {"name": "#", "type": "size", "value": "1,09/1,11"}
        """.data(using: .utf8)!

        let prop = try JSONDecoder().decode(TextProperty.self, from: json)
        XCTAssertEqual(prop.name, "#")
        XCTAssertEqual(prop.type, "size")
        XCTAssertEqual(prop.value, "1,09/1,11")
    }

    func testTextPropertiesCodable() throws {
        let json = """
        {
            "h1": [{"name": "#", "type": "size", "value": "1,09/1,11"}],
            "h2": [{"name": "##", "type": "size", "value": "0,9/0,92"}],
            "p": []
        }
        """.data(using: .utf8)!

        let props = try JSONDecoder().decode(TextProperties.self, from: json)
        XCTAssertEqual(props.h1?.count, 1)
        XCTAssertEqual(props.h2?.count, 1)
        XCTAssertEqual(props.p?.count, 0)
    }

    func testTextPropertiesNilArrays() throws {
        let json = "{}".data(using: .utf8)!
        let props = try JSONDecoder().decode(TextProperties.self, from: json)
        XCTAssertNil(props.h1)
        XCTAssertNil(props.h2)
        XCTAssertNil(props.p)
    }
}

final class TargetingTests: XCTestCase {

    func testTargetingDecoding() throws {
        let json = """
        {
            "counts": 5,
            "enabled": true,
            "isMultiVisited": false,
            "seconds": 2.5,
            "type": "event",
            "value": "page_view",
            "attributes": [
                {"attributeName": "plan", "value": "pro", "rule": "equal"}
            ]
        }
        """.data(using: .utf8)!

        let targeting = try JSONDecoder().decode(Targeting.self, from: json)

        XCTAssertEqual(targeting.counts, 5)
        XCTAssertEqual(targeting.enabled, true)
        XCTAssertEqual(targeting.isMultiVisited, false)
        XCTAssertEqual(targeting.seconds, 2.5)
        XCTAssertEqual(targeting.type, "event")
        XCTAssertEqual(targeting.value, "page_view")
        XCTAssertEqual(targeting.attributes?.count, 1)
        XCTAssertEqual(targeting.attributes?.first?.attributeName, "plan")
        XCTAssertEqual(targeting.attributes?.first?.rule, "equal")
    }

    func testTargetingMinimal() throws {
        let json = "{}".data(using: .utf8)!
        let targeting = try JSONDecoder().decode(Targeting.self, from: json)

        XCTAssertNil(targeting.counts)
        XCTAssertNil(targeting.enabled)
        XCTAssertNil(targeting.seconds)
        XCTAssertNil(targeting.value)
        XCTAssertNil(targeting.attributes)
    }
}
