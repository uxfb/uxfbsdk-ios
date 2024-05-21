//
//  UXFField.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

struct Field {
    private(set) var id: String?
    private(set) var type: FieldType?
    private(set) var value: String?
    private(set) var uiData: Dictionary<String, Any>
    var answers: [String] = []
    var isError: Bool = false
}
