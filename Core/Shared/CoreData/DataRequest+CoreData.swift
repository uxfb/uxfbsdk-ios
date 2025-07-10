//
//  UXFRequest+CoreData.swift
//  UX Feedback SDK Demo
//
//  Created by Alexander Potemka on 18.04.2023.
//  Copyright © 2023 UXF. All rights reserved.
//

import Foundation
import CoreData

@objc(DataRequest)
internal class DataRequest: NSManagedObject { }

extension DataRequest {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataRequest> {
        return NSFetchRequest<DataRequest>(entityName: "DataRequest")
    }

    @NSManaged public var apiMethod: String?
    @NSManaged public var created: Date?
    @NSManaged public var parametersData: Data?
}

extension DataRequest : Identifiable { }
