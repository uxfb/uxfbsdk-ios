import XCTest
@testable import UXFeedbackSDK

// MARK: - Шпион делегата

private final class CampaignDelegateSpy: NSObject, FeedbackCampaignDelegate {
    var onLoad: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onShow: ((Int, String, String) -> Void)?
    var onClose: ((Int, String, String) -> Void)?
    var onTerminate: ((Int, String, Int, Int) -> Void)?
    var onSend: ((Int, String) -> Void)?
    var onAnswered: ((Int, [String: Any], String) -> Void)?
    var onNoCampaign: ((String, String) -> Void)?

    func campaignDidLoad(success: Bool) { onLoad?(success) }
    func campaignDidReceiveError(errorString: String) { onError?(errorString) }
    func campaignDidShow(campaignId: Int, eventName: String, invocationId: String) { onShow?(campaignId, eventName, invocationId) }
    func campaignDidClose(campaignId: Int, eventName: String, invocationId: String) { onClose?(campaignId, eventName, invocationId) }
    func campaignDidTerminate(campaignId: Int, eventName: String, terminatedPage: Int, totalPages: Int, invocationId: String) { onTerminate?(campaignId, eventName, terminatedPage, totalPages) }
    func campaignDidSend(campaignId: Int, invocationId: String) { onSend?(campaignId, invocationId) }
    func campaignDidAnswered(campaignId: Int, answers: [String: Any], invocationId: String) { onAnswered?(campaignId, answers, invocationId) }
    func noCampaignToStart(eventName: String, invocationId: String) { onNoCampaign?(eventName, invocationId) }
}

// MARK: - UXFeedback facade

final class UXFeedbackFacadeTests: XCTestCase {

    private let appId = "abcdefghijklmnopqrstuvwxy" // ровно 25 символов
    private var delegateSpy: CampaignDelegateSpy!

    override func setUp() {
        super.setUp()
        StubURLProtocol.register()
        // Дефолтный стаб: toggles выключены, кампаний нет
        StubURLProtocol.stubProvider = { request in
            if request.url?.path.contains("toggles") ?? false {
                return .init(body: try! JSONSerialization.data(withJSONObject: ["data": ["togglesStatus": false]]))
            }
            return .init(body: Data("{\"campaigns\": []}".utf8))
        }
        delegateSpy = CampaignDelegateSpy()
        // Сбрасываем глобальный таймер показа
        UserDefaults.standard.removeObject(forKey: appId)
    }

    override func tearDown() {
        UXFeedback.sdk.stopCampaign()
        UserDefaults.standard.removeObject(forKey: appId)
        StubURLProtocol.unregister()
        delegateSpy = nil
        super.tearDown()
    }

    // MARK: Крипто-хелперы (зеркалят Crypto: XOR c ключом + base64)

    private func xorUXF(_ input: String) -> String {
        let key = Array("UXFeedback")
        var output = ""
        for (index, char) in input.enumerated() {
            let byte = String(char).utf8.first! ^ String(key[index % key.count]).utf8.first!
            output.append(String(bytes: [byte], encoding: .utf8)!)
        }
        return output
    }

    private func encryptedEndpoint(_ url: String) -> String {
        return Data(xorUXF("UXFeedback#\(url)").utf8).base64EncodedString()
    }

    private func makeSettings() -> UXFBSettings {
        let settings = UXFBSettings()
        settings.endpoint = encryptedEndpoint("https://stub.test")
        settings.globalDelayTimer = 0
        settings.retryCount = 0
        settings.retryTimeout = 0.1
        return settings
    }

    private func setupSDK() {
        UXFeedback.setup(appID: appId,
                         settings: makeSettings(),
                         campaignDelegate: delegateSpy,
                         logDelegate: nil)
    }

    // MARK: Crypto

    func testCryptoDecryptRoundtrip() {
        let encrypted = encryptedEndpoint("https://stub.test")
        XCTAssertEqual(Crypto().decrypt(encrypted), "https://stub.test")
    }

    func testCryptoDecryptInvalidBase64ReturnsEmpty() {
        XCTAssertEqual(Crypto().decrypt("не base64!"), "")
    }

    func testCryptoUidNotCrashing() {
        _ = Crypto().uid
    }

    // MARK: Setup

    func testSetupWithInvalidAppIdReportsError() {
        let exp = expectation(description: "invalid appId")
        delegateSpy.onError = { message in
            guard message.contains("AppId") else { return }
            exp.fulfill()
        }

        UXFeedback.setup(appID: "короткий",
                         settings: UXFBSettings(),
                         campaignDelegate: delegateSpy,
                         logDelegate: nil)

        wait(for: [exp], timeout: 5)
    }

    func testSetupWithValidAppIdLoadsCampaigns() {
        let exp = expectation(description: "campaigns load callback")
        exp.assertForOverFulfill = false
        delegateSpy.onLoad = { _ in
            exp.fulfill()
        }

        setupSDK()

        wait(for: [exp], timeout: 10)
        XCTAssertEqual(UXFeedback.sdk.version, Consts.version)
    }

    // MARK: Global properties

    func testGlobalPropertiesLifecycle() {
        let sdk = UXFeedback.sdk

        sdk.clearGlobalProperties()
        sdk.addGlobalProperty(key: "plan", value: "pro")
        sdk.addGlobalProperty(key: "age", value: 42)
        XCTAssertEqual(sdk.getGlobalProperties().count, 2)
        XCTAssertEqual(sdk.getGlobalProperties()["plan"] as? String, "pro")

        sdk.removeGlobalProperty(key: "plan")
        XCTAssertEqual(sdk.getGlobalProperties().count, 1)

        sdk.clearGlobalProperties()
        XCTAssertTrue(sdk.getGlobalProperties().isEmpty)
    }

    // MARK: startCampaign

    func testStartCampaignWithUnknownEventReportsNoCampaign() {
        setupSDK()

        let exp = expectation(description: "no campaign")
        exp.assertForOverFulfill = false
        delegateSpy.onNoCampaign = { eventName, invocationId in
            guard eventName == "evt_unknown_zzz" else { return }
            XCTAssertFalse(invocationId.isEmpty)
            exp.fulfill()
        }

        let uuid = UXFeedback.sdk.startCampaign(eventName: "evt_unknown_zzz")
        XCTAssertFalse(uuid.isEmpty)

        wait(for: [exp], timeout: 10)
    }

    func testStartCampaignShowsFormForStoredCampaign() {
        setupSDK()

        // Кладём кампанию в общее CoreData-хранилище через отдельный менеджер
        let seeder = DataRequestManager(endpoint: "https://stub.test",
                                        appID: appId,
                                        parser: Parser(theme: nil),
                                        sdkSettings: UXFBSettings(),
                                        delegate: nil)
        let campaignDict: [String: Any] = [
            "type": 102,
            "campaignId": 501,
            "projectId": 7,
            "autoclose": 0.0,
            "targeting": ["trigger": ["value": "evt_facade_501", "seconds": 0]],
            "pages": [["id": "p1",
                       "fields": [["id": "f1", "type": "header", "value": "Привет"]],
                       "buttons": [["id": "b1", "type": "button", "value": "Далее"]]]],
            "transforms": []
        ]
        let data = CampaignData(campaignId: 501,
                                priority: 1,
                                data: try! JSONSerialization.data(withJSONObject: campaignDict))
        let seedExp = expectation(description: "seeded")
        seeder.setCampaigns([data]) { _ in seedExp.fulfill() }
        wait(for: [seedExp], timeout: 5)

        // В headless-среде презентация UIWindow не завершается, поэтому ждём
        // детерминированные сигналы показа: запрос /mobile/visits и отметку времени показа
        let visitExp = expectation(description: "show form request sent")
        visitExp.assertForOverFulfill = false
        StubURLProtocol.stubProvider = { request in
            if request.url?.path.contains("toggles") ?? false {
                return .init(body: try! JSONSerialization.data(withJSONObject: ["data": ["togglesStatus": false]]))
            }
            if request.url?.path.contains("visits") ?? false {
                visitExp.fulfill()
            }
            return .init(body: Data("{\"campaigns\": []}".utf8))
        }

        _ = UXFeedback.sdk.startCampaign(eventName: "evt_facade_501")

        wait(for: [visitExp], timeout: 15)

        // saveShowingTime зафиксировал показ
        XCTAssertNotNil(UserDefaults.standard.object(forKey: appId) as? Date)

        UXFeedback.sdk.stopCampaign()
    }

    // MARK: CampaignPresentor: хендлеры формы → делегат

    private final class PresentorDelegateSpy: CampaignFormPresentorProtocol {
        var onSubmitted: (([[String: Any]]?, Int) -> Void)?
        func formSubmitted(info: Array<Dictionary<String, Any>>?, screenshots: [Screenshot], campaign: Campaign, invocationId: String) {
            onSubmitted?(info, campaign.campaignId)
        }
    }

    func testPresentorHandlersForwardToDelegates() {
        let campaign = Campaign(campaignId: 701,
                                theme: Theme(),
                                pages: [],
                                type: .slidein,
                                targeting: Targeting(value: "evt_701"),
                                transforms: [],
                                autoclose: 0)
        let presentor = CampaignPresentor(window: PassthroughWindow(frame: UIScreen.main.bounds),
                                          campaign: campaign,
                                          animationEnabled: false)
        presentor.feedbackCampaignDelegate = delegateSpy
        let presentorSpy = PresentorDelegateSpy()
        presentor.delegate = presentorSpy

        let form = presentor.createCampaignForm(campaign, invocationId: "inv-701")

        // presentHandler → campaignDidShow
        var shown = false
        delegateSpy.onShow = { campaignId, eventName, invocationId in
            shown = campaignId == 701 && eventName == "evt_701" && invocationId == "inv-701"
        }
        form.presentHandler?()
        XCTAssertTrue(shown)
        XCTAssertTrue(presentor.isFormOnScreen)

        // completeHandler → formSubmitted
        var submittedId: Int?
        presentorSpy.onSubmitted = { _, campaignId in submittedId = campaignId }
        form.completeHandler?([["pageId": "p1"]], [])
        XCTAssertEqual(submittedId, 701)

        // didTerminateHandler → formSubmitted + campaignDidTerminate
        var terminated = false
        delegateSpy.onTerminate = { campaignId, _, page, total in
            terminated = campaignId == 701 && page == 1 && total == 2
        }
        form.didTerminateHandler?([], [], 1, 2)
        XCTAssertTrue(terminated)
        XCTAssertFalse(presentor.isFormOnScreen)

        // didCloseHandler → campaignDidClose (асинхронно на main)
        let closeExp = expectation(description: "closed")
        delegateSpy.onClose = { campaignId, _, _ in
            XCTAssertEqual(campaignId, 701)
            closeExp.fulfill()
        }
        form.didCloseHandler?()
        wait(for: [closeExp], timeout: 5)

        // dismissCurrentForm без формы → false, с завершением
        var dismissCompletionCalled = false
        XCTAssertFalse(presentor.dismissCurrentForm { dismissCompletionCalled = true })
        XCTAssertTrue(dismissCompletionCalled)

        presentor.stopCampaign()
        XCTAssertFalse(presentor.isFormOnScreen)
    }

    // MARK: stopCampaign

    func testStopCampaignWithoutFormDoesNotCrash() {
        UXFeedback.sdk.stopCampaign()
        UXFeedback.sdk.stopCampaign(eventForStop: "любое_событие")
    }

    // MARK: RequestManagerDelegate → FeedbackCampaignDelegate

    func testFormDataSavedForwardsToDelegate() {
        setupSDK()

        let exp = expectation(description: "did send")
        delegateSpy.onSend = { campaignId, invocationId in
            XCTAssertEqual(campaignId, 601)
            XCTAssertEqual(invocationId, "inv-601")
            exp.fulfill()
        }

        UXFeedback.sdk.formDataSaved(success: true, message: nil, campaignId: 601, invocationId: "inv-601")
        wait(for: [exp], timeout: 5)
    }

    func testFormDataSavedFailureNotForwarded() {
        setupSDK()

        var called = false
        delegateSpy.onSend = { _, _ in called = true }

        UXFeedback.sdk.formDataSaved(success: false, message: "err", campaignId: 602, invocationId: "inv-602")

        let exp = expectation(description: "tick")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 2)
        XCTAssertFalse(called)
    }

    // MARK: formSubmitted → ответы + отправка

    func testFormSubmittedMapsAnswersAndNotifiesDelegate() {
        setupSDK()

        let exp = expectation(description: "answered")
        delegateSpy.onAnswered = { campaignId, answers, invocationId in
            XCTAssertEqual(campaignId, 603)
            XCTAssertEqual(answers["f1"] as? String, "значение")
            XCTAssertEqual(answers["f2"] as? Int, 9)
            XCTAssertEqual(invocationId, "inv-603")
            exp.fulfill()
        }

        let campaign = Campaign(campaignId: 603,
                                theme: Theme(),
                                pages: [],
                                type: .slidein,
                                targeting: Targeting(value: "evt"),
                                transforms: [],
                                projectId: "7",
                                autoclose: 0)
        let info: [[String: Any]] = [
            ["pageId": "p1",
             "fields": [["fieldId": "f1", "value": "значение"],
                        ["fieldId": "f2", "value": 9]]]
        ]

        UXFeedback.sdk.formSubmitted(info: info, screenshots: [], campaign: campaign, invocationId: "inv-603")
        wait(for: [exp], timeout: 5)
    }
}
