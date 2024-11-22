//
//  UXFeedbackDelegate.swift
//  UX Feedback Demo
//
//  Created by Alexander Potemka on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit
/// Interface of the handler for various events from the SDK
@objc
public protocol YoHeCampaignDelegate: FeedbackCampaignDelegate {
     /// Event after loading campaigns from the server
     /// - Parameter success: Sign of successful download
     func campaignDidLoad(success: Bool)
     /// Event receiving an error when running the SDK
     /// - Parameter errorString: Error text
     func campaignDidReceiveError(errorString: String)
     /// Event after displaying the campaign form
     ///- Parameters:
     /// - campaignId: Campaign identificator
     /// - eventName: Name of the event passed to startCampaign
     func campaignDidShow(campaignId: String, eventName: String)
     /// Campaign form closing event
     /// - Parameters:
     /// - eventName: Name of the event passed to startCampaign
     /// - campaignId: Campaign identificator
     func campaignDidClose(campaignId: String, eventName: String)
     /// Campaign abort event
     /// - Parameters:
     /// - campaignId: Campaign identificator
     /// - eventName: Name of the event passed to startCampaign
     /// - terminatedPage: The page where the campaign was terminated
     /// - totalPages: Total number of campaign pages
     func campaignDidTerminate(campaignId: String, eventName: String, terminatedPage: Int, totalPages: Int)
     /// Event of sending campaign results to the server
     /// - Parameter campaignId: Campaign ID
     func campaignDidSend(campaignId: String)
     /// Campaign completion event with responses received
     /// - Parameters:
     /// - campaignId: Campaign ID
     /// - answers: An array of answers in the format Key: Value, where key is the block ID
     func campaignDidAnswered(campaignId: String, answers: [String: Any])
}


/// Log event handler interface from the SDK
@objc
public protocol YoHeLogDelegate: FeedbackLogDelegate {
     /// Log message receipt event
     /// - Parameter message: Log text
     func logDidReceive(message: String)
}
