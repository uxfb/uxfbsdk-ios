//
//  UX_Feedback_SDK_Demo_SwiftUIUITestsLaunchTests.swift
//  UX Feedback SDK Demo SwiftUIUITests
//
//  Created by Alexander Potemka on 14.02.2024.
//  Copyright © 2024 UXF. All rights reserved.
//

import XCTest

final class UX_Feedback_SDK_Demo_SwiftUIUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
