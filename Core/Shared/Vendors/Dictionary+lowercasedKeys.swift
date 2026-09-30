//
//  Dictionary+lowercasedKeys.swift
//  UX Feedback SDK
//

import Foundation

extension Dictionary where Key == String {
    func lowercasedKeys() -> [String: Value] {
        Dictionary(
            map { ($0.key.lowercased(), $0.value) },
            uniquingKeysWith: { $1 }
        )
    }
}
