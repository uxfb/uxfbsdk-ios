//
//  UXFPageResponse.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 20.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation

struct UXFPageResponse: Decodable{
    var pages: [UXFPageElementProtocol]
    
    enum CodingKeys: String, CodingKey {
        case pages = "pages"
    }
}
