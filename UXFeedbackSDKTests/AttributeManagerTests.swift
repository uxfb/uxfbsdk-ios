import XCTest
@testable import UXFeedbackSDK

final class AttributeManagerTests: XCTestCase {

    // MARK: - Helpers

    private func makeCampaignData(campaignId: Int = 1, needsToShow: Bool = false) -> CampaignData {
        var data = CampaignData(campaignId: campaignId, priority: 1)
        data.needsToShow = needsToShow
        return data
    }

    private func makeTargeting(attributes: [CampaignAttribute]?) -> Targeting {
        return Targeting(attributes: attributes)
    }

    private func makeCampaignAttribute(name: String, rule: String, value: AttributeDecodable? = nil, valueFrom: AttributeDecodable? = nil, valueTo: AttributeDecodable? = nil) -> CampaignAttribute {
        return CampaignAttribute(attributeName: name, value: value, rule: rule, valueFrom: valueFrom, valueTo: valueTo)
    }

    // MARK: - Empty Attributes

    func testBothAttributesEmpty() {
        let expectation = expectation(description: "completion")
        let targeting = makeTargeting(attributes: [])
        let campaignData = makeCampaignData()

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: []) { result in
            XCTAssertTrue(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testCampaignAttributesEmpty() {
        let expectation = expectation(description: "completion")
        let targeting = makeTargeting(attributes: [])
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "plan", attributeValue: "pro")]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertTrue(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMoreCampaignAttributesThanAppAttributes() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [
            makeCampaignAttribute(name: "plan", rule: "equal", value: .string("pro")),
            makeCampaignAttribute(name: "age", rule: "equal", value: .int(25))
        ]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "plan", attributeValue: "pro")]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertFalse(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Equal Rule

    func testEqualRuleStringMatch() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "plan", rule: "equal", value: .string("pro"))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "plan", attributeValue: "pro")]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertTrue(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testEqualRuleStringMismatch() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "plan", rule: "equal", value: .string("pro"))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "plan", attributeValue: "free")]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertFalse(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testEqualRuleNumberMatch() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "score", rule: "equal", value: .int(100))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "score", attributeValue: NSNumber(value: 100))]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertTrue(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testEqualRuleBoolMatch() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "premium", rule: "equal", value: .string("true"))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "premium", attributeValue: true)]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertTrue(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testEqualRuleNilValue() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [CampaignAttribute(attributeName: "plan", value: nil, rule: "equal")]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "plan", attributeValue: "pro")]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertFalse(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Contain Rule

    func testContainRuleMatch() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "email", rule: "contain", value: .string("@gmail"))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "email", attributeValue: "user@gmail.com")]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertTrue(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testContainRuleMismatch() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "email", rule: "contain", value: .string("@yahoo"))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "email", attributeValue: "user@gmail.com")]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertFalse(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Number Range Rule

    func testNumberRangeInRange() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "age", rule: "numberRange", valueFrom: .int(18), valueTo: .int(65))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "age", attributeValue: NSNumber(value: 30))]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertTrue(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testNumberRangeAtMinBoundary() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "age", rule: "numberRange", valueFrom: .int(18), valueTo: .int(65))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "age", attributeValue: NSNumber(value: 18))]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertTrue(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testNumberRangeAtMaxBoundary() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "age", rule: "numberRange", valueFrom: .int(18), valueTo: .int(65))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "age", attributeValue: NSNumber(value: 65))]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertTrue(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testNumberRangeOutOfRange() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "age", rule: "numberRange", valueFrom: .int(18), valueTo: .int(65))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "age", attributeValue: NSNumber(value: 70))]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertFalse(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testNumberRangeWithNonNumberAttribute() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "age", rule: "numberRange", valueFrom: .int(18), valueTo: .int(65))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "age", attributeValue: "thirty")]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertFalse(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Date Range Rule

    func testDateRangeInRange() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "registered", rule: "dateRange", valueFrom: .string("2024-01-01"), valueTo: .string("2024-12-31"))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: "2024-06-15")!

        let appAttrs = [Attribute(attributeName: "registered", attributeValue: date)]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertTrue(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDateRangeOutOfRange() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "registered", rule: "dateRange", valueFrom: .string("2024-01-01"), valueTo: .string("2024-12-31"))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: "2025-06-15")!

        let appAttrs = [Attribute(attributeName: "registered", attributeValue: date)]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertFalse(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDateRangeWithNonDateAttribute() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "registered", rule: "dateRange", valueFrom: .string("2024-01-01"), valueTo: .string("2024-12-31"))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "registered", attributeValue: "not a date")]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertFalse(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - List Rule

    func testListRuleNeedsToShowTrue() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "plan", rule: "list", value: .string("pro"))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData(needsToShow: true)
        let appAttrs = [Attribute(attributeName: "plan", attributeValue: "pro")]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertTrue(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testListRuleNeedsToShowFalse() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "plan", rule: "list", value: .string("pro"))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData(needsToShow: false)
        let appAttrs = [Attribute(attributeName: "plan", attributeValue: "pro")]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertFalse(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Unknown Rule

    func testUnknownRule() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "plan", rule: "unknown_rule", value: .string("pro"))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "plan", attributeValue: "pro")]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertFalse(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Missing App Attribute

    func testMissingAppAttribute() {
        let expectation = expectation(description: "completion")
        let campaignAttrs = [makeCampaignAttribute(name: "plan", rule: "equal", value: .string("pro"))]
        let targeting = makeTargeting(attributes: campaignAttrs)
        let campaignData = makeCampaignData()
        let appAttrs = [Attribute(attributeName: "other_attr", attributeValue: "value")]

        AttributeManager.checkAttributes(appId: "app1",
                                          requestManager: DataRequestManager(),
                                          campaignCandidate: campaignData,
                                          targeting: targeting,
                                          attributes: appAttrs) { result in
            XCTAssertFalse(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}
