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
        DispatchQueue.global(qos: .background).async {
            let stateQueue = DispatchQueue(label: "campaignmanager.state")
            var campaign: Campaign?
            var shouldStop = false
            
            let group = DispatchGroup()
            
            let campaignIds = candidates.filter { campaign in
                if let attrs = campaign.campaign?.targeting.attributes,
                   attrs.contains(where: { attr in
                       attr.rule == "list"
                   }) {
                    return true
                } else {
                    return false
                }
            }.map { $0.campaign?.campaignId }
            
            var foundCampaignId: Int?
            
            var listAttrs: [CampaignAttribute] = []
            candidates.forEach { campaign in
                if let attrs = campaign.campaign?.targeting.attributes?.filter({ attr in
                    attr.rule == "list"
                }), attrs.count > 0 {
                    listAttrs.append(contentsOf: attrs)
                }
            }
            
            let filteredAttrs = attributes?.filter { attr in
                if listAttrs.firstIndex(where: { lAttr in
                    attr.attributeName == lAttr.attributeName
                }) != nil {
                    return true
                }
                return false
            }
            
            if campaignIds.count > 0,
                let attributes = filteredAttrs,
                attributes.count > 0 {
                group.enter()
                requestManager.sendAttributes(appId: appId, campaignIds: campaignIds as! [Int], attributes: attributes) { result, campaignId  in
                    
                    defer { group.leave() }
                    stateQueue.sync {
                        foundCampaignId = campaignId
                    }
                }
            }
            
            group.wait()
            
            let updatedCandidates = candidates.map { candidate in
                var mutableCandidate = candidate
                if candidate.campaignId == foundCampaignId {
                    mutableCandidate.needsToShow = true
                }
                return mutableCandidate
            }
            
            
            for candidate in updatedCandidates {
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
                AttributeManager.checkAttributes(appId: appId, requestManager: requestManager, campaignCandidate: candidate, targeting: candidateCampaign.targeting, attributes: attributes ?? []) { result in
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
}
