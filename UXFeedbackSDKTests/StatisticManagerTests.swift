import XCTest
@testable import UXFeedbackSDK

final class StatisticManagerTests: XCTestCase {

    func testGetDeviceInfoContainsExpectedKeys() {
        let info = StatisticManager.getDeviceInfo()

        XCTAssertNotNil(info["os"])
        XCTAssertNotNil(info["deviceVendor"])
        XCTAssertNotNil(info["deviceModel"])
        XCTAssertNotNil(info["language"])
        XCTAssertNotNil(info["orientation"])
        XCTAssertNotNil(info["width"])
        XCTAssertNotNil(info["height"])
        XCTAssertNotNil(info["network"])
        XCTAssertNotNil(info["device"])
    }

    func testGetDeviceInfoVendorIsApple() {
        let info = StatisticManager.getDeviceInfo()
        XCTAssertEqual(info["deviceVendor"] as? String, "apple")
    }

    func testGetDeviceInfoDeviceType() {
        let info = StatisticManager.getDeviceInfo()
        let device = info["device"] as? String

        XCTAssertNotNil(device)
        XCTAssertTrue(["mobile", "tablet", "unknown"].contains(device!))
    }

    func testGetDeviceInfoWidthAndHeightArePositive() {
        let info = StatisticManager.getDeviceInfo()

        let width = info["width"] as? Int ?? 0
        let height = info["height"] as? Int ?? 0

        XCTAssertGreaterThan(width, 0)
        XCTAssertGreaterThan(height, 0)
    }

    func testGetDeviceInfoOSContainsVersion() {
        let info = StatisticManager.getDeviceInfo()
        let os = info["os"] as? String ?? ""

        XCTAssertTrue(os.contains(UIDevice.current.systemName))
        XCTAssertTrue(os.contains(UIDevice.current.systemVersion))
    }

    func testGetTimeUTCFormat() {
        let utcTime = StatisticManager.getTimeUTC()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let parsedDate = dateFormatter.date(from: utcTime)
        XCTAssertNotNil(parsedDate, "UTC time string should be parseable: \(utcTime)")
    }

    func testGetTimeUTCEndsWithZ() {
        let utcTime = StatisticManager.getTimeUTC()
        XCTAssertTrue(utcTime.hasSuffix("Z"))
    }

    func testGetTimeUTCContainsT() {
        let utcTime = StatisticManager.getTimeUTC()
        XCTAssertTrue(utcTime.contains("T"))
    }

    func testGetTimeUTCIsRecentTime() {
        let utcTime = StatisticManager.getTimeUTC()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        guard let parsedDate = dateFormatter.date(from: utcTime) else {
            XCTFail("Failed to parse UTC time")
            return
        }

        let timeDifference = abs(parsedDate.timeIntervalSinceNow)
        XCTAssertLessThan(timeDifference, 5.0, "UTC time should be within 5 seconds of now")
    }
}
