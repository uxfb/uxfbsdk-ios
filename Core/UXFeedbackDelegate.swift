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

public protocol UXFeedbackCampaignDelegate: class{
    func campaignDidClose(withFeedbackResult result: UXFeedbackResult, isRedirectToAppStoreEnabled: Bool)
    func campaignLoaded(success: Bool)
    func campaignErrorReceived(errorString: String)
}

public protocol UXFeedbackFormDelegate: AnyObject {
   func formDidLoaded(form: UXFViewController)
   func formDidFailLoading(error: UXFError)
   func formDidClose(formID: String?, withFeedbackResults results: [UXFeedbackResult], isRedirectToAppStoreEnabled: Bool)
   func formWillClose(form: UXFViewController, formID: String?, withFeedbackResults results: [UXFeedbackResult], isRedirectToAppStoreEnabled: Bool)
}
