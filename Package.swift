// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "UXFeedbackSDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "UXFeedbackSDK",
            targets: ["UXFeedbackSDK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "UXFeedbackSDK",
            url: "https://github.com/uxfb/uxfbsdk-ios/releases/download/v4.6.0/UXFeedbackSDK.xcframework.zip",
            checksum: "94d22384f6e0f7d6b73939e61480f37f1b230d881c4397661d6503993c5cdcbe"
        ),
    ]
)
