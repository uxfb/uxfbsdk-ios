//
//  Encodable+.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 21.05.2024.
//  Copyright © 2024 UXF. All rights reserved.
//

import Foundation

extension Encodable {
  var dict : [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return nil }
    return json
  }
  
  var dictArr : [[String: Any]]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]] else { return nil }
    return json
  }
}
