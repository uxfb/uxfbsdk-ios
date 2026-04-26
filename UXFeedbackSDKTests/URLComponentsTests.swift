import XCTest
@testable import UXFeedbackSDK

final class URLComponentsTests: XCTestCase {

    func testBasicURLConstruction() {
        let components = URLComponents(baseUrl: "https://api.example.com",
                                       path: "/v1/campaigns")

        XCTAssertEqual(components.baseUrl, "https://api.example.com")
        XCTAssertEqual(components.path, "/v1/campaigns")
        XCTAssertNotNil(components.url)
        XCTAssertEqual(components.url?.absoluteString, "https://api.example.com/v1/campaigns")
    }

    func testURLWithStringQueryParameter() {
        let components = URLComponents(baseUrl: "https://api.example.com",
                                       path: "/search",
                                       queryParameters: ["q": "hello"])

        let url = components.url?.absoluteString ?? ""
        XCTAssertTrue(url.contains("q=hello"))
    }

    func testURLWithIntQueryParameter() {
        let components = URLComponents(baseUrl: "https://api.example.com",
                                       path: "/items",
                                       queryParameters: ["limit": 10])

        let url = components.url?.absoluteString ?? ""
        XCTAssertTrue(url.contains("limit=10"))
    }

    func testURLWithArrayParameter() {
        let components = URLComponents(baseUrl: "https://api.example.com",
                                       path: "/items",
                                       queryParameters: ["ids": [1, 2, 3]])

        let query = components.query
        XCTAssertTrue(query.contains("ids[]=1"))
        XCTAssertTrue(query.contains("ids[]=2"))
        XCTAssertTrue(query.contains("ids[]=3"))
    }

    func testURLWithEmptyArrayParameter() {
        let components = URLComponents(baseUrl: "https://api.example.com",
                                       path: "/items",
                                       queryParameters: ["ids": [Any]()])

        let query = components.query
        XCTAssertTrue(query.contains("ids[]=nil"))
    }

    func testURLWithNoQueryParameters() {
        let components = URLComponents(baseUrl: "https://api.example.com",
                                       path: "/items")

        XCTAssertEqual(components.query, "")
    }

    func testQueryStartsWithQuestionMark() {
        let components = URLComponents(baseUrl: "https://api.example.com",
                                       path: "/items",
                                       queryParameters: ["key": "value"])

        let query = components.query
        XCTAssertTrue(query.hasPrefix("?"))
    }

    func testMultipleQueryParametersJoinedByAmpersand() {
        let components = URLComponents(baseUrl: "https://api.example.com",
                                       path: "/items",
                                       queryParameters: ["a": "1", "b": "2"])

        let query = components.query
        XCTAssertTrue(query.contains("&"))
    }

    func testURLWithBoolQueryParameter() {
        let components = URLComponents(baseUrl: "https://api.example.com",
                                       path: "/items",
                                       queryParameters: ["debug": true])

        let url = components.url?.absoluteString ?? ""
        XCTAssertTrue(url.contains("debug="))
    }

    func testNilQueryItems() {
        let components = URLComponents(baseUrl: "https://api.example.com",
                                       path: "/items",
                                       queryParameters: nil)
        components.queryItems = nil

        XCTAssertEqual(components.query, "")
    }
}
