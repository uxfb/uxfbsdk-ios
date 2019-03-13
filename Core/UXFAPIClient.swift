//
//  UXFAPIClient.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import CocoaLumberjack

enum UFXAPIClientResponseResult{
    case success
    case fail
    case cancelled
}

class UFXAPIClient{
    
    init(appID: String){
        DDLog.add(DDOSLogger.sharedInstance, with: DDLogLevel.debug)
    }
    
    func setup(appID: String){
        
    }
}
