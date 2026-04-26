import XCTest
@testable import UXFeedbackSDK

final class TransformTests: XCTestCase {

    func testTransformDecoding() throws {
        let json = """
        {
            "id": "t1",
            "to": {
                "action": "transition",
                "value": "page_2",
                "type": "toPage",
                "queryParams": null
            },
            "scenarios": [
                {
                    "id": "s1",
                    "name": "Scenario 1",
                    "conditions": [
                        {
                            "id": "c1",
                            "from": { "field": "f1", "page": "p1" },
                            "condition": { "rule": "equal", "value": ["opt1", "opt2"] }
                        }
                    ]
                }
            ]
        }
        """.data(using: .utf8)!

        let transform = try JSONDecoder().decode(Transform.self, from: json)

        XCTAssertEqual(transform.id, "t1")
        XCTAssertEqual(transform.to.action, "transition")
        XCTAssertEqual(transform.to.value, "page_2")
        XCTAssertEqual(transform.to.type, "toPage")
        XCTAssertNil(transform.to.queryParams)
        XCTAssertEqual(transform.scenarios.count, 1)
        XCTAssertEqual(transform.scenarios[0].id, "s1")
        XCTAssertEqual(transform.scenarios[0].conditions.count, 1)
        XCTAssertEqual(transform.scenarios[0].conditions[0].from.field, "f1")
        XCTAssertEqual(transform.scenarios[0].conditions[0].from.page, "p1")
        XCTAssertEqual(transform.scenarios[0].conditions[0].condition?.rule, "equal")
        XCTAssertEqual(transform.scenarios[0].conditions[0].condition?.value, ["opt1", "opt2"])
    }

    func testTransformConditionWithIntValues() throws {
        let json = """
        { "rule": "equal", "value": [1, 2, 3] }
        """.data(using: .utf8)!

        let condition = try JSONDecoder().decode(TransformCondition.self, from: json)

        XCTAssertEqual(condition.rule, "equal")
        XCTAssertEqual(condition.value, ["1", "2", "3"])
    }

    func testTransformConditionWithStringValues() throws {
        let json = """
        { "rule": "contain", "value": ["a", "b", "c"] }
        """.data(using: .utf8)!

        let condition = try JSONDecoder().decode(TransformCondition.self, from: json)

        XCTAssertEqual(condition.rule, "contain")
        XCTAssertEqual(condition.value, ["a", "b", "c"])
    }

    func testTransformConditionWithNullValue() throws {
        let json = """
        { "rule": "filled", "value": null }
        """.data(using: .utf8)!

        let condition = try JSONDecoder().decode(TransformCondition.self, from: json)

        XCTAssertEqual(condition.rule, "filled")
        XCTAssertNil(condition.value)
    }

    func testTransformToDecoding() throws {
        let json = """
        {
            "action": "transition",
            "value": "https://example.com",
            "type": "toURL",
            "queryParams": { "system": ["uid"], "user": ["plan"] }
        }
        """.data(using: .utf8)!

        let to = try JSONDecoder().decode(TransformTo.self, from: json)

        XCTAssertEqual(to.action, "transition")
        XCTAssertEqual(to.value, "https://example.com")
        XCTAssertEqual(to.type, "toURL")
        XCTAssertEqual(to.queryParams?.system, ["uid"])
        XCTAssertEqual(to.queryParams?.user, ["plan"])
    }

    func testTransformFromDecoding() throws {
        let json = """
        { "field": "f1", "page": "p1" }
        """.data(using: .utf8)!

        let from = try JSONDecoder().decode(TransformFrom.self, from: json)

        XCTAssertEqual(from.field, "f1")
        XCTAssertEqual(from.page, "p1")
    }

    func testTransformFromNilValues() throws {
        let json = """
        { "field": null, "page": null }
        """.data(using: .utf8)!

        let from = try JSONDecoder().decode(TransformFrom.self, from: json)

        XCTAssertNil(from.field)
        XCTAssertNil(from.page)
    }

    func testTransformScenarioDecoding() throws {
        let json = """
        {
            "id": "s1",
            "name": "Test Scenario",
            "conditions": []
        }
        """.data(using: .utf8)!

        let scenario = try JSONDecoder().decode(TransformScenario.self, from: json)

        XCTAssertEqual(scenario.id, "s1")
        XCTAssertEqual(scenario.name, "Test Scenario")
        XCTAssertTrue(scenario.conditions.isEmpty)
    }

    func testTransformWithMultipleScenarios() throws {
        let json = """
        {
            "id": "t1",
            "to": { "action": "transition", "value": "p2", "type": "toPage" },
            "scenarios": [
                {
                    "id": "s1",
                    "name": "First",
                    "conditions": [
                        { "id": "c1", "from": {"field": "f1", "page": "p1"}, "condition": {"rule": "equal", "value": ["1"]} }
                    ]
                },
                {
                    "id": "s2",
                    "name": "Second",
                    "conditions": [
                        { "id": "c2", "from": {"field": "f2", "page": "p1"}, "condition": {"rule": "filled"} }
                    ]
                }
            ]
        }
        """.data(using: .utf8)!

        let transform = try JSONDecoder().decode(Transform.self, from: json)
        XCTAssertEqual(transform.scenarios.count, 2)
    }

    func testTransformQueryParameterDecoding() throws {
        let json = """
        { "system": ["uid", "os"], "user": ["plan", "name"] }
        """.data(using: .utf8)!

        let params = try JSONDecoder().decode(TransformQueryParameter.self, from: json)

        XCTAssertEqual(params.system, ["uid", "os"])
        XCTAssertEqual(params.user, ["plan", "name"])
    }

    func testTransformQueryParameterNil() throws {
        let json = "{}".data(using: .utf8)!

        let params = try JSONDecoder().decode(TransformQueryParameter.self, from: json)
        XCTAssertNil(params.system)
        XCTAssertNil(params.user)
    }
}
