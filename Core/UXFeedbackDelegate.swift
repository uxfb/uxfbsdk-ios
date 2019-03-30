//
//  UXFeedbackDelegate.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit

public struct UXFeedbackResult {
    
    public let rating: Int?
    
    public let abandonedPageIndex: Int?
    
    public var sent: Bool
}

public protocol UXFeedbackDelegate: AnyObject {
    optional func formDidLoaded(form: UINavigationController)
    optional func formDidFailLoading(error: UXFError)
    optional func formDidClose(formID: String, withFeedbackResults results: [UXFeedbackResult], isRedirectToAppStoreEnabled: Bool)
    optional func formWillClose(form: UINavigationController, formID: String, withFeedbackResults results: [UXFeedbackResult], isRedirectToAppStoreEnabled: Bool)
    optional func campaignDidClose(withFeedbackResult result: UXFeedbackResult, isRedirectToAppStoreEnabled: Bool)
}
