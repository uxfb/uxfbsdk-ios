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
    func formDidLoaded(form: UINavigationController)
    func formDidFailLoading(error: UXFError)
    func formDidClose(formID: String, withFeedbackResults results: [UXFeedbackResult], isRedirectToAppStoreEnabled: Bool)
    func formWillClose(form: UINavigationController, formID: String, withFeedbackResults results: [UXFeedbackResult], isRedirectToAppStoreEnabled: Bool)
    
    func campaignDidClose(withFeedbackResult result: UXFeedbackResult, isRedirectToAppStoreEnabled: Bool)
}
