//
//  UXFRequest+CoreData.swift
//  UX Feedback SDK Demo
//
//  Created by Alexander Potemka on 18.04.2023.
//  Copyright © 2023 UXF. All rights reserved.
//

import Foundation

import Foundation
import CoreData

@objc(UXFRequest)
internal class UXFRequest: NSManagedObject {

}

extension UXFRequest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UXFRequest> {
        return NSFetchRequest<UXFRequest>(entityName: "UXFRequest")
    }

    @NSManaged public var apiMethod: String?
    @NSManaged public var created: Date?
    @NSManaged public var parametersData: Data?

}

extension UXFRequest : Identifiable {

}
