import XCTest
@testable import UXFeedbackSDK

final class CryptoTests: XCTestCase {

    private var crypto: Crypto!

    override func setUp() {
        super.setUp()
        crypto = Crypto()
    }

    override func tearDown() {
        crypto = nil
        super.tearDown()
    }

    func testDecryptValidInput() {
        let plaintext = "test_data_123"

        let key = "UXFeedback"
        var xored = ""
        let input = "\(key)#\(plaintext)"
        let keyChars = key.map { $0 }
        let keyLen = keyChars.count

        for (offset, char) in input.enumerated() {
            let byte = [String(char).utf8.first! ^ String(keyChars[offset % keyLen]).utf8.first!]
            xored.append(String(bytes: byte, encoding: .utf8)!)
        }
        let encrypted = Data(xored.utf8).base64EncodedString()

        let decrypted = crypto.decrypt(encrypted)
        XCTAssertEqual(decrypted, plaintext)
    }

    func testDecryptInvalidBase64() {
        let result = crypto.decrypt("not_valid_base64!!!")
        XCTAssertEqual(result, "")
    }

    func testDecryptEmptyString() {
        let result = crypto.decrypt("")
        XCTAssertEqual(result, "")
    }

    func testDecryptMalformedContent() {
        let malformed = Data("no_hash_separator".utf8).base64EncodedString()
        let result = crypto.decrypt(malformed)
        XCTAssertEqual(result, "")
    }

    func testUidIsNotEmpty() {
        let uid = crypto.uid
        XCTAssertFalse(uid.isEmpty)
    }
}
