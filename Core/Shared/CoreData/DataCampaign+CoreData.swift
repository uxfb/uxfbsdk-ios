//
//  DataCampaign+CoreData.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 10.07.2025.
//  Copyright © 2025 UXF. All rights reserved.
//

import Foundation
import CoreData

@objc(DataCampaign)
internal class DataCampaign: NSManagedObject { }

extension DataCampaign {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataCampaign> {
        return NSFetchRequest<DataCampaign>(entityName: "DataCampaign")
    }

    @NSManaged public var id: Int16
    @NSManaged public var priority: Int16
    @NSManaged public var data: Data?
    @NSManaged public var copyright: Data?
    @NSManaged public var textProperties: Data?
}

extension DataCampaign : Identifiable { }
