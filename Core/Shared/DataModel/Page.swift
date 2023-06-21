//
//  UXFPage.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 21.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

internal struct Page {
    private(set) var id: String?
    private(set) var type: Int?
    private(set) var fields: Array<Field>
    private(set) var buttons: Array<Field>
}
