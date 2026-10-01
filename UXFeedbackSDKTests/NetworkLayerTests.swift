import XCTest
@testable import UXFeedbackSDK

// MARK: - URLProtocol-стаб для URLSession.shared

final class StubURLProtocol: URLProtocol {

    struct Stub {
        var statusCode: Int = 200
        var body: Data = Data("{}".utf8)
        var headers: [String: String] = [:]
        var error: Error? = nil
    }

    /// Возвращает стаб для запроса. nil → дефолтный 200 {}
    static var stubProvider: ((URLRequest) -> Stub?)?

    static func register() {
        URLProtocol.registerClass(StubURLProtocol.self)
    }

    static func unregister() {
        URLProtocol.unregisterClass(StubURLProtocol.self)
        stubProvider = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        // Перехватываем только запросы на стабовый хост, чтобы не мешать другим тестам
        return request.url?.host?.contains("stub.test") ?? false
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        let stub = Self.stubProvider?(request) ?? Stub()

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        let response = HTTPURLResponse(url: request.url!,
                                       statusCode: stub.statusCode,
                                       httpVersion: "HTTP/1.1",
                                       headerFields: stub.headers)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: stub.body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}

private func jsonData(_ object: Any) -> Data {
    return try! JSONSerialization.data(withJSONObject: object)
}

// Словарь кампании в формате бэкенда
private func campaignInfoDict(campaignId: Int, event: String = "test_event") -> [String: Any] {
    return [
        "type": 102,
        "campaignId": campaignId,
        "projectId": 7,
        "autoclose": 0.0,
        "progress": true,
        "targeting": ["trigger": ["value": event]],
        "pages": [["id": "p1",
                   "fields": [["id": "f1", "type": "header", "value": "Заголовок"]],
                   "buttons": [["id": "b1", "type": "button", "value": "Далее"]]]],
        "transforms": []
    ]
}

// MARK: - APIClient

final class APIClientNetworkTests: XCTestCase {

    private var client: APIClient!

    override func setUp() {
        super.setUp()
        StubURLProtocol.register()
        client = APIClient(endpoint: "https://stub.test",
                           appID: "test-app",
                           parser: Parser(theme: nil),
                           settings: UXFBSettings())
    }

    override func tearDown() {
        StubURLProtocol.unregister()
        client = nil
        super.tearDown()
    }

    func testCheckToggleSuccess() {
        StubURLProtocol.stubProvider = { _ in
            .init(body: jsonData(["data": ["togglesStatus": true]]))
        }

        let exp = expectation(description: "toggle")
        client.checkToggle { status in
            XCTAssertEqual(status, true)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testCheckToggleNetworkErrorReturnsFalse() {
        StubURLProtocol.stubProvider = { _ in
            .init(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet))
        }

        let exp = expectation(description: "toggle fail")
        client.checkToggle { status in
            XCTAssertEqual(status, false)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testGetAllCampaignsSuccess() {
        StubURLProtocol.stubProvider = { _ in
            .init(body: jsonData([
                "campaigns": [["campaignId": 10, "priority": 1, "data": campaignInfoDict(campaignId: 10)]],
                "showCampaignsInterval": 42
            ]), headers: ["x-state": "state-42"])
        }

        let exp = expectation(description: "campaigns")
        client.getAllCampaings(state: "") { success, httpCode, message, interval, campaigns, state in
            XCTAssertTrue(success)
            XCTAssertEqual(httpCode, 200)
            XCTAssertNil(message)
            XCTAssertEqual(interval, 42)
            XCTAssertEqual(campaigns.count, 1)
            XCTAssertEqual(campaigns.first?.campaignId, 10)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testGetAllCampaignsNoCampaignsKey() {
        StubURLProtocol.stubProvider = { _ in
            .init(body: jsonData(["something": 1]))
        }

        let exp = expectation(description: "no campaigns")
        client.getAllCampaings(state: "") { success, _, message, _, campaigns, _ in
            XCTAssertFalse(success)
            XCTAssertEqual(message, "No campaings detected")
            XCTAssertTrue(campaigns.isEmpty)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testGetAllCampaignsInvalidBody() {
        StubURLProtocol.stubProvider = { _ in
            .init(body: Data("не json".utf8))
        }

        let exp = expectation(description: "bad body")
        client.getAllCampaings(state: "") { success, _, _, _, campaigns, _ in
            XCTAssertFalse(success)
            XCTAssertTrue(campaigns.isEmpty)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testSaveFormDataSuccess() {
        StubURLProtocol.stubProvider = { _ in
            .init(body: jsonData(["data": ["ok": 1]]))
        }

        let exp = expectation(description: "save form")
        client.saveFormData(projectId: "7",
                            createdAtClient: "2026-09-09T00:00:00Z",
                            campaignId: 5,
                            pages: [["pageId": "p1"]],
                            properties: ["key": "value"],
                            idempotency: "uuid-1") { success, httpCode, message in
            XCTAssertTrue(success)
            XCTAssertEqual(httpCode, 200)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testShowFormSuccess() {
        StubURLProtocol.stubProvider = { _ in
            .init(body: jsonData(["data": ["ok": 1]]))
        }

        let exp = expectation(description: "show form")
        client.showForm(campaingId: 5) { success, httpCode in
            XCTAssertTrue(success)
            XCTAssertEqual(httpCode, 200)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testSaveScreenshotsDataSuccess() {
        StubURLProtocol.stubProvider = { _ in
            .init(body: jsonData(["data": ["ok": 1]]))
        }

        let exp = expectation(description: "screenshot")
        let screenshot = ScreenshotData(id: "s1", base64image: "aGVsbG8=")
        client.saveScreenshotsData(screenshot) { success, httpCode in
            XCTAssertTrue(success)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testCheckAttributesSuccess() {
        StubURLProtocol.stubProvider = { _ in
            .init(body: jsonData(["data": ["campaignId": 77]]))
        }

        let exp = expectation(description: "attributes")
        let attributes = [Attribute(attributeName: "plan", attributeValue: "pro")]
        client.checkAttribues("test-app", [77], attributes, false) { success, campaignId in
            XCTAssertTrue(success)
            XCTAssertEqual(campaignId, 77)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testCheckAttributesFailure() {
        StubURLProtocol.stubProvider = { _ in
            .init(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut))
        }

        let exp = expectation(description: "attributes fail")
        client.checkAttribues("test-app", [1], [], false) { success, campaignId in
            XCTAssertFalse(success)
            XCTAssertNil(campaignId)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }
}

// MARK: - DataRequestManager

private final class RequestManagerSpy: RequestManagerDelegate {
    var onCampaignsLoaded: ((Bool, Int?, [CampaignData], String) -> Void)?
    var onFormDataSaved: ((Bool, Int, String) -> Void)?

    func campaingsLoaded(success: Bool, message: String?, delay: Int?, campaigns: Array<CampaignData>, state: String) {
        onCampaignsLoaded?(success, delay, campaigns, state)
    }

    func formDataSaved(success: Bool, message: String?, campaignId: Int, invocationId: String) {
        onFormDataSaved?(success, campaignId, invocationId)
    }
}

final class DataRequestManagerTests: XCTestCase {

    private var spy: RequestManagerSpy!
    private var manager: DataRequestManager!

    override func setUp() {
        super.setUp()
        StubURLProtocol.register()
        spy = RequestManagerSpy()
        manager = DataRequestManager(endpoint: "https://stub.test",
                                     appID: "test-app",
                                     parser: Parser(theme: nil),
                                     sdkSettings: UXFBSettings(),
                                     delegate: spy)
        manager.settings = NetworkSettings(requestTimeout: 1, retryCount: 0, retryTimeout: 0.1)
    }

    override func tearDown() {
        StubURLProtocol.unregister()
        manager = nil
        spy = nil
        super.tearDown()
    }

    // MARK: CoreData: last update

    func testLastUpdateRoundtrip() {
        let setExp = expectation(description: "set")
        manager.setLastUpdate("state-abc") { success in
            XCTAssertTrue(success)
            setExp.fulfill()
        }
        wait(for: [setExp], timeout: 5)

        let getExp = expectation(description: "get")
        manager.getLastUpdate { value in
            XCTAssertEqual(value, "state-abc")
            getExp.fulfill()
        }
        wait(for: [getExp], timeout: 5)
    }

    // MARK: CoreData: campaigns

    private func storedCampaign(id: Int, event: String) -> CampaignData {
        return CampaignData(campaignId: id,
                            priority: 1,
                            data: jsonData(campaignInfoDict(campaignId: id, event: event)))
    }

    func testSetAndGetCampaignCandidates() {
        let setExp = expectation(description: "set campaigns")
        manager.setCampaigns([storedCampaign(id: 101, event: "evt_101")]) { needsReload in
            XCTAssertFalse(needsReload)
            setExp.fulfill()
        }
        wait(for: [setExp], timeout: 5)

        let getExp = expectation(description: "get candidates")
        manager.getCampaignCanditates(eventName: "evt_101") { candidates in
            XCTAssertEqual(candidates?.count, 1)
            XCTAssertEqual(candidates?.first?.campaignId, 101)
            XCTAssertEqual(candidates?.first?.campaign?.targeting.value, "evt_101")
            getExp.fulfill()
        }
        wait(for: [getExp], timeout: 5)
    }

    func testGetCampaignCandidatesWrongEventReturnsNil() {
        let setExp = expectation(description: "set campaigns")
        manager.setCampaigns([storedCampaign(id: 102, event: "evt_102")]) { _ in setExp.fulfill() }
        wait(for: [setExp], timeout: 5)

        let getExp = expectation(description: "no candidates")
        manager.getCampaignCanditates(eventName: "другое_событие") { candidates in
            XCTAssertNil(candidates)
            getExp.fulfill()
        }
        wait(for: [getExp], timeout: 5)
    }

    func testSetCampaignsWithoutDataNeedsReload() {
        let exp = expectation(description: "needs reload")
        manager.setCampaigns([CampaignData(campaignId: 103, priority: 1)]) { needsReload in
            XCTAssertTrue(needsReload)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testRemoveCampaign() {
        let setExp = expectation(description: "set")
        manager.setCampaigns([storedCampaign(id: 104, event: "evt_104")]) { _ in setExp.fulfill() }
        wait(for: [setExp], timeout: 5)

        manager.removeCampaign(campaignId: 104)

        let getExp = expectation(description: "removed")
        manager.getCampaignCanditates(eventName: "evt_104") { candidates in
            XCTAssertNil(candidates)
            getExp.fulfill()
        }
        wait(for: [getExp], timeout: 5)
    }

    // MARK: Очередь запросов → сеть → делегат

    func testGetAllCampaignsCallsDelegate() {
        StubURLProtocol.stubProvider = { request in
            guard request.url?.path.contains("campaign") ?? false else { return nil }
            return .init(body: jsonData([
                "campaigns": [["campaignId": 201, "priority": 1, "data": campaignInfoDict(campaignId: 201)]],
                "showCampaignsInterval": 10
            ]), headers: ["x-state": "st-201"])
        }

        let exp = expectation(description: "delegate campaigns")
        exp.assertForOverFulfill = false
        spy.onCampaignsLoaded = { success, delay, campaigns, state in
            guard campaigns.first?.campaignId == 201 else { return } // отсекаем хвосты других тестов
            XCTAssertTrue(success)
            XCTAssertEqual(delay, 10)
            exp.fulfill()
        }

        manager.getAllCampaigns()
        wait(for: [exp], timeout: 10)
    }

    func testSendFormDataCallsDelegate() {
        StubURLProtocol.stubProvider = { _ in
            .init(body: jsonData(["data": ["ok": 1]]))
        }

        let exp = expectation(description: "delegate form saved")
        exp.assertForOverFulfill = false
        spy.onFormDataSaved = { success, campaignId, invocationId in
            guard campaignId == 202 else { return }
            XCTAssertTrue(success)
            XCTAssertEqual(invocationId, "inv-202")
            exp.fulfill()
        }

        manager.sendFormData(projectId: "7",
                             createdAtClient: "2026-09-09T00:00:00Z",
                             campaignId: 202,
                             invocationId: "inv-202",
                             pages: [["pageId": "p1"]],
                             properties: [:])
        wait(for: [exp], timeout: 10)
    }

    func testSendShowFormHitsNetwork() {
        let exp = expectation(description: "show form request")
        exp.assertForOverFulfill = false
        StubURLProtocol.stubProvider = { request in
            // campaignId уходит в теле запроса, маршрут показа формы — /mobile/visits
            if request.url?.path.contains("visits") ?? false {
                exp.fulfill()
            }
            return nil
        }

        manager.sendShowForm(campaignId: 203)
        wait(for: [exp], timeout: 10)
    }

    func testSendScreenshotsDataHitsNetwork() {
        let exp = expectation(description: "screenshot request")
        exp.assertForOverFulfill = false
        StubURLProtocol.stubProvider = { request in
            if request.url?.path.contains("screenshot") ?? false {
                exp.fulfill()
            }
            return nil
        }

        let image = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4)).image { _ in }
        let field = try! Field(from: ["id": "f1", "type": "screenshot"])
        manager.sendScreenshotsData(screenshots: [Screenshot(id: "sc1", image: image, type: .screenshot, field: field)])
        wait(for: [exp], timeout: 10)
    }

    func testCheckToggles() {
        StubURLProtocol.stubProvider = { _ in
            .init(body: jsonData(["data": ["togglesStatus": false]]))
        }

        let exp = expectation(description: "toggles")
        manager.checkToggles { enabled in
            XCTAssertFalse(enabled)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testSendAttributes() {
        StubURLProtocol.stubProvider = { _ in
            .init(body: jsonData(["data": ["campaignId": 204]]))
        }

        let exp = expectation(description: "attributes")
        manager.sendAttributes(appId: "test-app",
                               campaignIds: [204],
                               attributes: [Attribute(attributeName: "a", attributeValue: "b")]) { success, campaignId in
            XCTAssertTrue(success)
            XCTAssertEqual(campaignId, 204)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }
}

// MARK: - CampaignManager

final class CampaignManagerTests: XCTestCase {

    private var manager: DataRequestManager!

    override func setUp() {
        super.setUp()
        StubURLProtocol.register()
        manager = DataRequestManager(endpoint: "https://stub.test",
                                     appID: "test-app",
                                     parser: Parser(theme: nil),
                                     sdkSettings: UXFBSettings(),
                                     delegate: nil)
    }

    override func tearDown() {
        StubURLProtocol.unregister()
        manager = nil
        super.tearDown()
    }

    private func candidate(id: Int) -> CampaignData {
        var data = CampaignData(campaignId: id, priority: 1)
        data.campaign = Campaign(campaignId: id,
                                 theme: Theme(),
                                 pages: [],
                                 type: .slidein,
                                 targeting: Targeting(value: "evt"),
                                 transforms: [],
                                 autoclose: 0)
        return data
    }

    func testFindCampaignWithoutAttributesReturnsFirst() {
        let exp = expectation(description: "found")
        CampaignManager.findCampaignInCandidates([candidate(id: 301)],
                                                 appId: "test-app",
                                                 requestManager: manager) { campaign in
            XCTAssertEqual(campaign?.campaignId, 301)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
    }

    func testFindCampaignWithEmptyCandidatesReturnsNil() {
        let exp = expectation(description: "nil")
        CampaignManager.findCampaignInCandidates([],
                                                 appId: "test-app",
                                                 requestManager: manager) { campaign in
            XCTAssertNil(campaign)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
    }
}
