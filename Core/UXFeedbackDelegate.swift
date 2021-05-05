//
//  UXFeedbackDelegate.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit

@objcMembers
public class UXFeedbackResult : NSObject{
    
    public var rating: Int? = nil
    public var abandonedPageIndex: Int? = nil
    public var sent: Bool = false
    
    init(rating: Int?, abandonedPageIndex: Int?, sent: Bool) {
        self.rating = rating
        self.abandonedPageIndex = abandonedPageIndex
        self.sent = sent
    }
}

@objc
public protocol UXFeedbackCampaignDelegate: AnyObject {
    func campaignDidClose(withFeedbackResult result: UXFeedbackResult, isRedirectToAppStoreEnabled: Bool)
    func campaignLoaded(success: Bool)
    func campaignErrorReceived(errorString: String)
    func campaignDidShow()
}

@objc
public protocol UXFeedbackFormDelegate: AnyObject {
   func formDidLoaded(form: UXFCampaignViewController)
   func formDidFailLoading(error: UXFError)
   func formDidClose(formID: String?, withFeedbackResults results: [UXFeedbackResult], isRedirectToAppStoreEnabled: Bool)
   func formWillClose(form: UXFCampaignViewController, formID: String?, withFeedbackResults results: [UXFeedbackResult], isRedirectToAppStoreEnabled: Bool)
}
