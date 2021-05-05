//
//  UXFPage.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 21.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit

struct UXFPage {
    private(set) var id: String?
    private(set) var type: Int?
    private(set) var fields: Array<UXFField>
    private(set) var buttons: Array<UXFField>
}
