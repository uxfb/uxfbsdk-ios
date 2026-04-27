import XCTest
@testable import UXFeedbackSDK

final class AttributeDecodableTests: XCTestCase {

    func testDecodeString() throws {
        let json = "\"hello\"".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AttributeDecodable.self, from: json)

        XCTAssertEqual(decoded.getString(), "hello")
        XCTAssertNil(decoded.getNumber())
    }

    func testDecodeInt() throws {
        let json = "42".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AttributeDecodable.self, from: json)

        XCTAssertNil(decoded.getString())
        XCTAssertEqual(decoded.getNumber(), 42)
    }

    func testDecodeDouble() throws {
        let json = "3.14".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AttributeDecodable.self, from: json)

        XCTAssertNil(decoded.getString())
        XCTAssertEqual(decoded.getNumber()!.doubleValue, 3.14, accuracy: 0.001)
    }

    func testGetNumberFromString() throws {
        let json = "\"42.5\"".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AttributeDecodable.self, from: json)

        XCTAssertEqual(decoded.getString(), "42.5")
        XCTAssertEqual(decoded.getNumber()!.doubleValue, 42.5, accuracy: 0.001)
    }

    func testGetNumberFromNonNumericString() throws {
        let json = "\"not a number\"".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AttributeDecodable.self, from: json)

        XCTAssertEqual(decoded.getString(), "not a number")
        XCTAssertNil(decoded.getNumber())
    }
}

final class CampaignAttributeTests: XCTestCase {

    func testCampaignAttributeDecoding() throws {
        let json = """
        {
            "attributeName": "plan",
            "value": "pro",
            "rule": "equal"
        }
        """.data(using: .utf8)!

        let attr = try JSONDecoder().decode(CampaignAttribute.self, from: json)

        XCTAssertEqual(attr.attributeName, "plan")
        XCTAssertEqual(attr.rule, "equal")
        XCTAssertEqual(attr.value?.getString(), "pro")
        XCTAssertNil(attr.valueFrom)
        XCTAssertNil(attr.valueTo)
    }

    func testCampaignAttributeWithRange() throws {
        let json = """
        {
            "attributeName": "age",
            "rule": "numberRange",
            "valueFrom": 18,
            "valueTo": 65
        }
        """.data(using: .utf8)!

        let attr = try JSONDecoder().decode(CampaignAttribute.self, from: json)

        XCTAssertEqual(attr.attributeName, "age")
        XCTAssertEqual(attr.rule, "numberRange")
        XCTAssertNil(attr.value)
        XCTAssertEqual(attr.valueFrom?.getNumber()?.intValue, 18)
        XCTAssertEqual(attr.valueTo?.getNumber()?.intValue, 65)
    }

    func testCampaignAttributeDateRange() throws {
        let json = """
        {
            "attributeName": "registered",
            "rule": "dateRange",
            "valueFrom": "2024-01-01",
            "valueTo": "2024-12-31"
        }
        """.data(using: .utf8)!

        let attr = try JSONDecoder().decode(CampaignAttribute.self, from: json)

        XCTAssertEqual(attr.attributeName, "registered")
        XCTAssertEqual(attr.rule, "dateRange")
        XCTAssertEqual(attr.valueFrom?.getString(), "2024-01-01")
        XCTAssertEqual(attr.valueTo?.getString(), "2024-12-31")
    }
}

final class AttributeTests: XCTestCase {

    func testAttributeCreation() {
        let attr = Attribute(attributeName: "key", attributeValue: "value")
        XCTAssertEqual(attr.attributeName, "key")
        XCTAssertEqual(attr.attributeValue as? String, "value")
    }

    func testAttributeWithNilValue() {
        let attr = Attribute(attributeName: "key")
        XCTAssertEqual(attr.attributeName, "key")
        XCTAssertNil(attr.attributeValue)
    }

    func testAttributeValueMutability() {
        let attr = Attribute(attributeName: "key", attributeValue: "old")
        attr.attributeValue = "new"
        XCTAssertEqual(attr.attributeValue as? String, "new")
    }
}

final class AttributesBuilderTests: XCTestCase {

    func testAddStringValue() {
        let attributes = AttributesBuilder()
            .addValue("name", value: "John")
            .build()

        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes.first?.attributeName, "name")
        XCTAssertEqual(attributes.first?.attributeValue as? String, "John")
    }

    func testAddIntValue() {
        let attributes = AttributesBuilder()
            .addValue("age", value: 25)
            .build()

        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes.first?.attributeValue as? Int, 25)
    }

    func testAddDoubleValue() {
        let attributes = AttributesBuilder()
            .addValue("score", value: 4.5)
            .build()

        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes.first?.attributeValue as? Double, 4.5)
    }

    func testAddBoolValue() {
        let attributes = AttributesBuilder()
            .addValue("premium", value: true)
            .build()

        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes.first?.attributeValue as? Bool, true)
    }

    func testAddDateValue() {
        let date = Date()
        let attributes = AttributesBuilder()
            .addValue("registered", value: date)
            .build()

        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes.first?.attributeValue as? Date, date)
    }

    func testAddMultipleValues() {
        let attributes = AttributesBuilder()
            .addValue("name", value: "John")
            .addValue("age", value: 25)
            .addValue("premium", value: true)
            .build()

        XCTAssertEqual(attributes.count, 3)
    }

    func testOverwriteExistingAttribute() {
        let attributes = AttributesBuilder()
            .addValue("name", value: "John")
            .addValue("name", value: "Jane")
            .build()

        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes.first?.attributeValue as? String, "Jane")
    }

    func testRemoveAttribute() {
        let attributes = AttributesBuilder()
            .addValue("name", value: "John")
            .addValue("age", value: 25)
            .remove(attributeName: "name")
            .build()

        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes.first?.attributeName, "age")
    }

    func testRemoveNonExistentAttribute() {
        let attributes = AttributesBuilder()
            .addValue("name", value: "John")
            .remove(attributeName: "nonexistent")
            .build()

        XCTAssertEqual(attributes.count, 1)
    }

    func testChainability() {
        let builder = AttributesBuilder()
        let result = builder.addValue("a", value: "1")
            .addValue("b", value: 2)
            .remove(attributeName: "a")
            .addValue("c", value: true)

        XCTAssertTrue(result === builder)
    }

    func testEmptyBuild() {
        let attributes = AttributesBuilder().build()
        XCTAssertTrue(attributes.isEmpty)
    }
}

final class AttributeArrayConvertToDictTests: XCTestCase {

    func testConvertStringAttribute() {
        let attrs = [Attribute(attributeName: "name", attributeValue: "John")]
        let dict = attrs.convertToDict()

        XCTAssertEqual(dict["name"], "John")
    }

    func testConvertIntAttribute() {
        let attrs = [Attribute(attributeName: "age", attributeValue: 25)]
        let dict = attrs.convertToDict()

        XCTAssertEqual(dict["age"], "25")
    }

    func testConvertDoubleAttribute() {
        let attrs = [Attribute(attributeName: "score", attributeValue: 4.5)]
        let dict = attrs.convertToDict()

        XCTAssertEqual(dict["score"], "4.5")
    }

    func testConvertBoolAttribute() {
        let attrs = [Attribute(attributeName: "premium", attributeValue: true)]
        let dict = attrs.convertToDict()

        XCTAssertEqual(dict["premium"], "true")
    }

    func testConvertDateAttribute() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: "2024-06-15")!

        let attrs = [Attribute(attributeName: "registered", attributeValue: date)]
        let dict = attrs.convertToDict()

        XCTAssertEqual(dict["registered"], "2024-06-15")
    }

    func testConvertMultipleAttributes() {
        let attrs = [
            Attribute(attributeName: "name", attributeValue: "John"),
            Attribute(attributeName: "age", attributeValue: 25),
            Attribute(attributeName: "premium", attributeValue: true)
        ]
        let dict = attrs.convertToDict()

        XCTAssertEqual(dict.count, 3)
        XCTAssertEqual(dict["name"], "John")
        XCTAssertEqual(dict["age"], "25")
        XCTAssertEqual(dict["premium"], "true")
    }

    func testConvertEmptyArray() {
        let attrs: [Attribute] = []
        let dict = attrs.convertToDict()
        XCTAssertTrue(dict.isEmpty)
    }

    func testConvertNilValueAttribute() {
        let attrs = [Attribute(attributeName: "key")]
        let dict = attrs.convertToDict()
        XCTAssertNil(dict["key"])
    }
}

final class CheckAttributeTests: XCTestCase {

    func testCheckAttributeDecoding() throws {
        let json = """
        {"campaignId": 42}
        """.data(using: .utf8)!

        let result = try JSONDecoder().decode(CheckAttribute.self, from: json)
        XCTAssertEqual(result.campaignId, 42)
    }

    func testCheckAttributeNilCampaignId() throws {
        let json = """
        {"campaignId": null}
        """.data(using: .utf8)!

        let result = try JSONDecoder().decode(CheckAttribute.self, from: json)
        XCTAssertNil(result.campaignId)
    }
}
