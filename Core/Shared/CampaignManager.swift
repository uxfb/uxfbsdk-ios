//
//  CampaignManager.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 10.07.2025.
//  Copyright © 2025 UXF. All rights reserved.
//

@objcMembers
class CampaignManager {
    static func findCampaignInCandidates(_ candidates: [CampaignData], appId: String, requestManager: DataRequestManager, attributes: [Attribute]? = nil, completion: @escaping (Campaign?) -> Void) {
        let stateQueue = DispatchQueue(label: "campaignmanager.state")
        var campaign: Campaign?
        var shouldStop = false
        
        let group = DispatchGroup()
        
        for candidate in candidates {
            var localShouldStop = false
            stateQueue.sync {
                localShouldStop = shouldStop
            }
            guard !localShouldStop else { break }
            
            guard let candidateCampaign = candidate.campaign else {
                continue
            }
            
            if attributes == nil && (candidateCampaign.targeting.attributes == nil || candidateCampaign.targeting.attributes?.isEmpty == true) {
                completion(candidateCampaign)
                return
            }
            
            group.enter()
            AttributeManager.checkAttributes(appId: appId, requestManager: requestManager, campaignId: candidateCampaign.campaignId, targeting: candidateCampaign.targeting, attributes: attributes ?? []) { result in
                defer { group.leave() }
                
                if result {
                    stateQueue.sync {
                        campaign = candidateCampaign
                        shouldStop = true
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(campaign)
        }
    }
}
