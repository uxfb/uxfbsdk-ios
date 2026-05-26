import XCTest
@testable import UXFeedbackSDK

final class HTTPHeaderFieldTests: XCTestCase {

    func testRawValues() {
        XCTAssertEqual(HTTPHeaderField.contentType.rawValue, "Content-Type")
        XCTAssertEqual(HTTPHeaderField.acceptType.rawValue, "Accept")
        XCTAssertEqual(HTTPHeaderField.uid.rawValue, "uid")
        XCTAssertEqual(HTTPHeaderField.campaignId.rawValue, "campaignId")
        XCTAssertEqual(HTTPHeaderField.sdkVersion.rawValue, "X-SDK-Version")
        XCTAssertEqual(HTTPHeaderField.sdkTargetOS.rawValue, "X-SDK-TargetOS")
        XCTAssertEqual(HTTPHeaderField.sdkPlatform.rawValue, "X-SDK-Platform")
        XCTAssertEqual(HTTPHeaderField.state.rawValue, "x-state")
        XCTAssertEqual(HTTPHeaderField.idempotencyKey.rawValue, "Idempotency-Key")
    }
}

final class ContentTypeTests: XCTestCase {

    func testJsonContentType() {
        XCTAssertEqual(ContentType.json.rawValue, "application/json")
    }

    func testScreenshotContentType() {
        XCTAssertTrue(ContentType.screenshot.rawValue.hasPrefix("multipart/form-data"))
    }
}

final class APIWebRouterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        APIWebRouter.endpoint = "https://api.test.com/v18"
        APIWebRouter.settings = nil
    }

    // MARK: - HTTP Method Tests

    func testCheckToggleMethod() {
        let router = APIWebRouter.checkToggle(appID: "app1")
        XCTAssertEqual(router.method, "POST")
    }

    func testGetCampaignMethod() {
        let router = APIWebRouter.getCampaign(appID: "app1", state: "")
        XCTAssertEqual(router.method, "GET")
    }

    func testShowFormMethod() {
        let router = APIWebRouter.showForm(uid: "uid1", campaingId: 1)
        XCTAssertEqual(router.method, "POST")
    }

    func testSaveFormDataMethod() {
        let router = APIWebRouter.saveFormData(appId: "app1",
                                               projectId: nil,
                                               createdAtClient: "",
                                               uid: "uid1",
                                               campaignId: 1,
                                               pages: [],
                                               info: [:],
                                               properties: [:],
                                               idempotency: "key1")
        XCTAssertEqual(router.method, "POST")
    }

    func testSaveScreenshotMethod() {
        let screenshot = ScreenshotData(id: "ss1", base64image: "")
        let router = APIWebRouter.saveScreenshot(screenshot: screenshot)
        XCTAssertEqual(router.method, "POST")
    }

    func testCheckAttributeMethod() {
        let router = APIWebRouter.checkAttribute(appID: "app1",
                                                  campaignIDs: [1],
                                                  attributes: [],
                                                  debug: false)
        XCTAssertEqual(router.method, "POST")
    }

    // MARK: - Path Tests

    func testCheckTogglePath() {
        let router = APIWebRouter.checkToggle(appID: "myApp")
        XCTAssertEqual(router.path, "/mobile/toggles/myApp")
    }

    func testGetCampaignPath() {
        let router = APIWebRouter.getCampaign(appID: "myApp", state: "")
        XCTAssertEqual(router.path, "/mobile/campaigns/myApp")
    }

    func testShowFormPath() {
        let router = APIWebRouter.showForm(uid: "uid1", campaingId: 1)
        XCTAssertEqual(router.path, "/mobile/visits")
    }

    func testSaveFormDataPathWithAppId() {
        let router = APIWebRouter.saveFormData(appId: "app1",
                                               projectId: nil,
                                               createdAtClient: "",
                                               uid: "uid1",
                                               campaignId: 1,
                                               pages: [],
                                               info: [:],
                                               properties: [:],
                                               idempotency: "key1")
        XCTAssertEqual(router.path, "/mobile/answers/app1")
    }

    func testSaveFormDataPathWithoutAppId() {
        let router = APIWebRouter.saveFormData(appId: nil,
                                               projectId: nil,
                                               createdAtClient: "",
                                               uid: "uid1",
                                               campaignId: 1,
                                               pages: [],
                                               info: [:],
                                               properties: [:],
                                               idempotency: "key1")
        XCTAssertEqual(router.path, "/mobile/answers")
    }

    func testSaveFormDataPathWithEmptyAppId() {
        let router = APIWebRouter.saveFormData(appId: "",
                                               projectId: nil,
                                               createdAtClient: "",
                                               uid: "uid1",
                                               campaignId: 1,
                                               pages: [],
                                               info: [:],
                                               properties: [:],
                                               idempotency: "key1")
        XCTAssertEqual(router.path, "/mobile/answers")
    }

    func testSaveScreenshotPath() {
        let screenshot = ScreenshotData(id: "ss1", base64image: "")
        let router = APIWebRouter.saveScreenshot(screenshot: screenshot)
        XCTAssertEqual(router.path, "/mobile/screenshots")
    }

    func testCheckAttributePath() {
        let router = APIWebRouter.checkAttribute(appID: "myApp",
                                                  campaignIDs: [1],
                                                  attributes: [],
                                                  debug: false)
        XCTAssertEqual(router.path, "/mobile/campaigns/myApp/checkattributes")
    }

    // MARK: - Headers Tests

    func testGetCampaignHeadersContainState() {
        let router = APIWebRouter.getCampaign(appID: "app1", state: "abc123")
        let headers = router.headers

        XCTAssertEqual(headers?["x-state"], "abc123")
        XCTAssertEqual(headers?["Accept"], "application/json")
        XCTAssertEqual(headers?["Content-Type"], "application/json")
        XCTAssertEqual(headers?["X-SDK-TargetOS"], Consts.os)
        XCTAssertEqual(headers?["X-SDK-Version"], Consts.version)
    }

    func testCheckToggleHeaders() {
        let router = APIWebRouter.checkToggle(appID: "app1")
        let headers = router.headers

        XCTAssertEqual(headers?["Accept"], "application/json")
        XCTAssertEqual(headers?["Content-Type"], "application/json")
        XCTAssertNotNil(headers?["X-SDK-Version"])
    }

    func testSaveFormDataHeadersContainIdempotencyKey() {
        let router = APIWebRouter.saveFormData(appId: "app1",
                                               projectId: nil,
                                               createdAtClient: "",
                                               uid: "uid1",
                                               campaignId: 1,
                                               pages: [],
                                               info: [:],
                                               properties: [:],
                                               idempotency: "unique-key-123")
        let headers = router.headers

        XCTAssertEqual(headers?["Idempotency-Key"], "unique-key-123")
    }

    func testSaveScreenshotHeaders() {
        let screenshot = ScreenshotData(id: "ss1", base64image: "")
        let router = APIWebRouter.saveScreenshot(screenshot: screenshot)
        let headers = router.headers

        XCTAssertTrue(headers?["Content-Type"]?.hasPrefix("multipart/form-data") ?? false)
    }

    func testHeadersWithSettings() {
        class MockSettings: SettingsProtocol {
            var globalDelayTimer: Int = 0
            var closeOnSwipe: Bool = true
            var debugEnabled: Bool = false
            var fieldsEventEnabled: Bool = false
            var retryTimeout: Double = 5
            var retryCount: Int = 3
            var socketTimeout: Double = 30
            var slideInUiBlocked: Bool = false
            var slideInUiBlackoutColor: String?
            var slideInUiBlackoutOpacity: Int = 0
            var slideInUiBlackoutBlur: Int = 0
            var popupUiBlackoutColor: String?
            var popupUiBlackoutOpacity: Int = 0
            var popupUiBlackoutBlur: Int = 0
            var endpoint: String?
            var rotateToggle: Bool = false
            var sdkPlatform: String? = "Native"
            var sdkPlatformVersion: String? = "4.4.0"
        }

        APIWebRouter.settings = MockSettings()
        let router = APIWebRouter.checkToggle(appID: "app1")
        let headers = router.headers

        XCTAssertEqual(headers?["X-SDK-Platform"], "Flutter")
        XCTAssertEqual(headers?["X-SDK-Platform-Version"], "3.0.0")
    }

    func testDefaultPlatformWhenNoSettings() {
        APIWebRouter.settings = nil
        let router = APIWebRouter.checkToggle(appID: "app1")
        let headers = router.headers

        XCTAssertEqual(headers?["X-SDK-Platform"], "Native")
    }

    // MARK: - Parameters Tests

    func testShowFormParameters() {
        let router = APIWebRouter.showForm(uid: "test-uid", campaingId: 42)
        let params = router.parameters

        XCTAssertEqual(params?["uid"] as? String, "test-uid")
        XCTAssertEqual(params?["campaignId"] as? Int, 42)
    }

    func testSaveFormDataParameters() {
        let pages: [[String: Any]] = [["pageId": "p1", "fields": []]]
        let info: [String: Any] = ["os": "iOS"]
        let properties: [String: Any] = ["key": "val"]

        let router = APIWebRouter.saveFormData(appId: "app1",
                                               projectId: "proj1",
                                               createdAtClient: "2024-01-01",
                                               uid: "uid1",
                                               campaignId: 5,
                                               pages: pages,
                                               info: info,
                                               properties: properties,
                                               idempotency: "key1")
        let params = router.parameters

        XCTAssertEqual(params?["uid"] as? String, "uid1")
        XCTAssertEqual(params?["createdAtClient"] as? String, "2024-01-01")
        XCTAssertEqual(params?["campaignId"] as? Int, 5)
        XCTAssertNotNil(params?["pages"])
        XCTAssertNotNil(params?["info"])
        XCTAssertNotNil(params?["properties"])
    }

    func testCheckAttributeParameters() {
        let attrs = [Attribute(attributeName: "plan", attributeValue: "pro")]
        let router = APIWebRouter.checkAttribute(appID: "app1",
                                                  campaignIDs: [1, 2, 3],
                                                  attributes: attrs,
                                                  debug: true)
        let params = router.parameters

        XCTAssertNotNil(params?["attributes"])
        XCTAssertEqual(params?["campaignIds"] as? [Int], [1, 2, 3])
    }

    func testGetCampaignEmptyParameters() {
        let router = APIWebRouter.getCampaign(appID: "app1", state: "")
        let params = router.parameters

        XCTAssertTrue(params?.isEmpty ?? true)
    }

    // MARK: - Path Parameters Tests

    func testCheckTogglePathParameters() {
        let router = APIWebRouter.checkToggle(appID: "app1")
        let pathParams = router.pathParameters

        XCTAssertNotNil(pathParams?["uid"])
        XCTAssertNotNil(pathParams?["language"])
    }

    func testGetCampaignPathParameters() {
        let router = APIWebRouter.getCampaign(appID: "app1", state: "")
        let pathParams = router.pathParameters

        XCTAssertNotNil(pathParams?["uid"])
        XCTAssertNotNil(pathParams?["language"])
    }

    func testCheckAttributeDebugPathParameter() {
        let router = APIWebRouter.checkAttribute(appID: "app1",
                                                  campaignIDs: [],
                                                  attributes: [],
                                                  debug: true)
        let pathParams = router.pathParameters

        XCTAssertEqual(pathParams?["debug"] as? Bool, true)
    }

    func testSaveFormDataProjectIdPathParameter() {
        let router = APIWebRouter.saveFormData(appId: "app1",
                                               projectId: "proj123",
                                               createdAtClient: "",
                                               uid: "uid1",
                                               campaignId: 1,
                                               pages: [],
                                               info: [:],
                                               properties: [:],
                                               idempotency: "key1")
        let pathParams = router.pathParameters

        XCTAssertEqual(pathParams?["projectId"] as? String, "proj123")
    }

    // MARK: - URL Construction Tests

    func testAsURLConstruction() throws {
        let router = APIWebRouter.getCampaign(appID: "app1", state: "")
        let url = try router.asURL()

        XCTAssertTrue(url.absoluteString.hasPrefix("https://api.test.com/v18"))
        XCTAssertTrue(url.absoluteString.contains("/mobile/campaigns/app1"))
    }

    func testAsURLRequestConstruction() throws {
        let router = APIWebRouter.showForm(uid: "uid1", campaingId: 1)
        let request = try router.asURLRequest()

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNotNil(request.allHTTPHeaderFields)
        XCTAssertNotNil(request.httpBody)
    }

    // MARK: - Body Tests

    func testShowFormBodyIsNotNil() {
        let router = APIWebRouter.showForm(uid: "uid1", campaingId: 1)
        XCTAssertNotNil(router.body)
    }

    func testGetCampaignBodyIsNil() {
        let router = APIWebRouter.getCampaign(appID: "app1", state: "")
        XCTAssertNil(router.body)
    }

    // MARK: - Endpoint Tests

    func testEndpointThreadSafety() {
        let expectation = expectation(description: "Concurrent endpoint access")
        expectation.expectedFulfillmentCount = 100

        for i in 0..<100 {
            DispatchQueue.global().async {
                APIWebRouter.endpoint = "https://test\(i).com"
                _ = APIWebRouter.endpoint
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }
}
