//
//  CampaignManager.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 10.07.2025.
//  Copyright © 2025 UXF. All rights reserved.
//

class CampaignManager {
    static func findCampaignInCandidates(_ canditates: [CampaignData], appId: String, requestManager: DataRequestManager, attributes: [Attribute]? = nil, completion: @escaping (Campaign?) -> Void) {
        
        var campaign: Campaign?
        
        let group = DispatchGroup()
        var shouldStop = false
        
		for canditate in canditates {
            
            if attributes == nil && (canditate.campaign?.targeting.attributes == nil || canditate.campaign?.targeting.attributes?.count == 0 ){
                completion(canditate.campaign)
                return
            }
            
            guard !shouldStop else { break }
            
            group.enter()
            AttributeManager.checkAttributes(appId: appId,
                                             requestManager: requestManager,
                                             campaignId: canditate.campaign!.campaignId,
                                             targeting: canditate.campaign!.targeting,
                                             attributes: attributes ?? []) { result in
                defer { group.leave() }
                
                if result {
                    campaign = canditate.campaign
                    shouldStop = true
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(campaign)
        }
    }
}
