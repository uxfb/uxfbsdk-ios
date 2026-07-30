import XCTest
@testable import UXFeedbackSDK

final class SmilesDisabledDiagTests: XCTestCase {

    private final class StubDelegate: FieldDelegate {
        func fieldChanged(_ field: Field, answer: [String], refresh: Bool) {}
        func buttonTapped(_ field: Field, answer: [String], refresh: Bool) {}
        func textChanged(_ field: Field, answer: [String]) {}
        func screenshotChanged(_ field: Field, screenshots: [Screenshot]) {}
        func didBeginEditing(_ field: Field) {}
        func didEndEditing(_ field: Field) {}
    }

    private func dominantOpaqueColors(_ image: UIImage) -> [(String, Int)] {
        guard let cg = image.cgImage else { return [] }
        let width = cg.width, height = cg.height
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)
        guard let ctx = CGContext(data: &pixelData, width: width, height: height,
                                  bitsPerComponent: 8, bytesPerRow: 4 * width,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return [] }
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
        var counts: [String: Int] = [:]
        for i in stride(from: 0, to: pixelData.count, by: 4) {
            let a = pixelData[i + 3]
            if a < 200 { continue }
            let key = String(format: "#%02X%02X%02X", pixelData[i], pixelData[i + 1], pixelData[i + 2])
            counts[key, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }
    }

    func testDisabledSmileHasNoYellowOutline() throws {
        let dict: [String: Any] = ["id": "f1", "type": "smiles", "value": "Rate us"]
        var field = try Field(from: dict)
        field.answers = ["0"]

        let cell = SmilesCell(style: .default, reuseIdentifier: "smiles")
        cell.frame = CGRect(x: 0, y: 0, width: 320, height: 80)
        cell.configureWith(field, theme: Theme(), delegate: StubDelegate())
        cell.layoutIfNeeded()

        guard let disabledButton = cell.contentView.viewWithTag(3) as? UIButton,
              let image = disabledButton.image(for: .normal) else {
            XCTFail("no disabled button/image")
            return
        }

        let colors = dominantOpaqueColors(image)

        var yellowCount = 0
        for (hex, count) in colors {
            let r = Int(hex.dropFirst(1).prefix(2), radix: 16) ?? 0
            let g = Int(hex.dropFirst(3).prefix(2), radix: 16) ?? 0
            let b = Int(hex.dropFirst(5).prefix(2), radix: 16) ?? 0
            if r > 200, g > 150, b < 100 { yellowCount += count }
        }
        XCTAssertEqual(yellowCount, 0, "disabled smile outline must not stay yellow; dominant: \(colors.prefix(12))")
    }
}
