//
//  DataCampaignLastUpdate+CoreData.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 10.07.2025.
//  Copyright © 2025 UXF. All rights reserved.
//

import Foundation
import CoreData

@objc(DataCampaignLastUpdate)
internal class DataCampaignLastUpdate: NSManagedObject { }

extension DataCampaignLastUpdate {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataCampaignLastUpdate> {
        return NSFetchRequest<DataCampaignLastUpdate>(entityName: "DataCampaignLastUpdate")
    }

    @NSManaged public var stateHeader: String?
}

extension DataCampaignLastUpdate : Identifiable { }
