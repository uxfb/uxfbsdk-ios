//
//  UXFeedbackDelegate.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit


@objc
@_documentation(visibility: internal)
public protocol FeedbackCampaignDelegate: AnyObject {
    func campaignDidLoad(success: Bool)
    func campaignDidReceiveError(errorString: String)
    func campaignDidShow(campaignId: Int, eventName: String, invocationId: String)
    func campaignDidClose(campaignId: Int, eventName: String, invocationId: String)
    func campaignDidTerminate(campaignId: Int, eventName: String, terminatedPage: Int, totalPages: Int, invocationId: String)
    func campaignDidSend(campaignId: Int, invocationId: String)
    func campaignDidAnswered(campaignId: Int, answers: [String: Any], invocationId: String)
    func noCampaignToStart(eventName: String, invocationId: String)
}


@objc
@_documentation(visibility: internal)
public protocol FeedbackLogDelegate: AnyObject {
    func logDidReceive(message: String)
}
