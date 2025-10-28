//
//  UXFBGesture.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 29.10.2025.
//  Copyright © 2025 UXF. All rights reserved.
//

internal final class GestureRecognizer: UITapGestureRecognizer {
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }

    @objc private func execute() {
        action()
    }
}
