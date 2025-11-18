//
//  Decodable+.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 15.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import Foundation

internal
extension Decodable {
  init(from: Any) throws {
    let data = try JSONSerialization.data(withJSONObject: from, options: .prettyPrinted)
    let decoder = JSONDecoder()
    self = try decoder.decode(Self.self, from: data)
  }
}
