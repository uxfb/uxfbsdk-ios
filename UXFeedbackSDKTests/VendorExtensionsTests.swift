import XCTest
@testable import UXFeedbackSDK

// MARK: - Queue Tests

final class QueueTests: XCTestCase {

    func testNewQueueIsEmpty() {
        let queue = Queue<Int>()
        XCTAssertTrue(queue.isEmpty)
        XCTAssertNil(queue.first)
        XCTAssertNil(queue.last)
    }

    func testEnqueueSingleElement() {
        let queue = Queue<String>()
        queue.enqueue(key: "first")

        XCTAssertFalse(queue.isEmpty)
        XCTAssertEqual(queue.first?.data, "first")
        XCTAssertEqual(queue.last?.data, "first")
    }

    func testEnqueueMultipleElements() {
        let queue = Queue<Int>()
        queue.enqueue(key: 1)
        queue.enqueue(key: 2)
        queue.enqueue(key: 3)

        XCTAssertEqual(queue.first?.data, 1)
        XCTAssertEqual(queue.last?.data, 3)
    }

    func testDequeueReturnsNextElement() {
        let queue = Queue<Int>()
        queue.enqueue(key: 1)
        queue.enqueue(key: 2)
        queue.enqueue(key: 3)

        let dequeued = queue.dequeue()
        XCTAssertEqual(dequeued, 2)
        XCTAssertEqual(queue.first?.data, 2)
    }

    func testDequeueFromEmptyQueue() {
        let queue = Queue<Int>()
        let result = queue.dequeue()
        XCTAssertNil(result)
    }

    func testDequeueUntilEmpty() {
        let queue = Queue<Int>()
        queue.enqueue(key: 1)
        queue.enqueue(key: 2)

        _ = queue.dequeue()
        _ = queue.dequeue()

        XCTAssertTrue(queue.isEmpty)
    }

    func testEnqueueDequeueSequence() {
        let queue = Queue<String>()
        queue.enqueue(key: "a")
        queue.enqueue(key: "b")

        let first = queue.dequeue()
        XCTAssertEqual(first, "b")

        queue.enqueue(key: "c")
        XCTAssertEqual(queue.last?.data, "c")
    }
}

// MARK: - LinkedList Tests

final class LinkedListTests: XCTestCase {

    func testNodeCreation() {
        let node = LinkedList(data: 42)
        XCTAssertEqual(node.data, 42)
        XCTAssertNil(node.next)
    }

    func testNodeChaining() {
        let node1 = LinkedList(data: 1)
        let node2 = LinkedList(data: 2)
        node1.next = node2

        XCTAssertEqual(node1.next?.data, 2)
    }
}

// MARK: - Data Extension Tests

final class DataExtensionTests: XCTestCase {

    func testAppendString() {
        var data = Data()
        data.append("Hello")

        let result = String(data: data, encoding: .utf8)
        XCTAssertEqual(result, "Hello")
    }

    func testAppendMultipleStrings() {
        var data = Data()
        data.append("Hello")
        data.append(" ")
        data.append("World")

        let result = String(data: data, encoding: .utf8)
        XCTAssertEqual(result, "Hello World")
    }

    func testAppendEmptyString() {
        var data = Data()
        data.append("")

        XCTAssertTrue(data.isEmpty)
    }
}

// MARK: - Decodable Extension Tests

final class DecodableExtensionTests: XCTestCase {

    func testInitFromDictionary() throws {
        let dict: [String: Any] = [
            "togglesStatus": true
        ]

        let result = try ToggleStatus(from: dict)
        XCTAssertTrue(result.togglesStatus)
    }

    func testInitFromArray() throws {
        let array: [[String: Any]] = [
            ["id": "opt1", "value": "A"],
            ["id": "opt2", "value": "B"]
        ]

        let result = try [Option](from: array)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, "opt1")
        XCTAssertEqual(result[1].id, "opt2")
    }
}

// MARK: - Encodable Extension Tests

final class EncodableExtensionTests: XCTestCase {

    func testDictProperty() {
        let status = ToggleStatus(togglesStatus: true)
        let dict = status.dict

        XCTAssertNotNil(dict)
        XCTAssertEqual(dict?["togglesStatus"] as? Bool, true)
    }

    func testDictPropertyWithCodableStruct() {
        let option = Option(id: "opt1", value: "Test", exceptional: false)
        let dict = option.dict

        XCTAssertNotNil(dict)
        XCTAssertEqual(dict?["id"] as? String, "opt1")
        XCTAssertEqual(dict?["value"] as? String, "Test")
        XCTAssertEqual(dict?["exceptional"] as? Bool, false)
    }

    func testDictArrProperty() {
        let options = [
            Option(id: "1", value: "A", exceptional: nil),
            Option(id: "2", value: "B", exceptional: nil)
        ]
        let arr = options.dictArr

        XCTAssertNotNil(arr)
        XCTAssertEqual(arr?.count, 2)
    }
}

// MARK: - String Extensions Tests

final class StringExtensionsTests: XCTestCase {

    func testArgb2rgbaWith8CharHex() {
        let argb = "#FFAABBCC"
        let rgba = argb.argb2rgba

        XCTAssertNotNil(rgba)
        XCTAssertTrue(rgba!.hasPrefix("#"))
        XCTAssertEqual(rgba!.count, 9)
    }

    func testArgb2rgbaWith4CharHex() {
        let argb = "#FABC"
        let rgba = argb.argb2rgba

        XCTAssertNotNil(rgba)
        XCTAssertTrue(rgba!.hasPrefix("#"))
        XCTAssertEqual(rgba!.count, 5)
    }

    func testArgb2rgbaMissingHashPrefix() {
        let result = "AABBCC".argb2rgba
        XCTAssertNil(result)
    }

    func testArgb2rgbaInvalidLength() {
        let result = "#ABC".argb2rgba
        XCTAssertNil(result)
    }

    func testRandomImageNameLength() {
        let name = String.randomImageName
        XCTAssertEqual(name.count, 32)
    }

    func testRandomImageNameUniqueness() {
        let name1 = String.randomImageName
        let name2 = String.randomImageName
        XCTAssertNotEqual(name1, name2)
    }

    func testLinesCountSingleLine() {
        let text = "Hello"
        let font = UIFont.systemFont(ofSize: 14)
        let count = text.linesCount(width: 500, font: font)
        XCTAssertEqual(count, 1)
    }

    func testLinesCountMinimumIsOne() {
        let text = ""
        let font = UIFont.systemFont(ofSize: 14)
        let count = text.linesCount(width: 500, font: font)
        XCTAssertGreaterThanOrEqual(count, 1)
    }

    func testHeightPositive() {
        let text = "Hello World"
        let font = UIFont.systemFont(ofSize: 14)
        let height = text.height(withConstrainedWidth: 100, font: font)
        XCTAssertGreaterThan(height, 0)
    }

    func testWidthPositive() {
        let text = "Hello"
        let font = UIFont.systemFont(ofSize: 14)
        let width = text.width(withConstrainedHeight: 20, font: font)
        XCTAssertGreaterThan(width, 0)
    }

    func testConvertHtml() {
        let html = "<b>Bold</b> text"
        let attributed = html.convertHtml()
        XCTAssertGreaterThan(attributed.length, 0)
    }

    func testConvertHtmlPlainText() {
        let text = "Plain text"
        let attributed = text.convertHtml()
        XCTAssertTrue(attributed.string.contains("Plain text"))
    }
}

// MARK: - NSAttributedString Extension Tests

final class NSAttributedStringExtensionTests: XCTestCase {

    func testHeightForAttributedString() {
        let attrString = NSAttributedString(string: "Hello World",
                                             attributes: [.font: UIFont.systemFont(ofSize: 14)])
        let height = attrString.height(withConstrainedWidth: 200)
        XCTAssertGreaterThan(height, 0)
    }

    func testHeightForEmptyString() {
        let attrString = NSAttributedString(string: "")
        let height = attrString.height(withConstrainedWidth: 200)
        XCTAssertEqual(height, 0)
    }
}
