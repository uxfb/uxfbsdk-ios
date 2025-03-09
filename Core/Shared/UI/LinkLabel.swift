//
//  LinkLabel.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 08.03.2025.
//  Copyright © 2025 UXF. All rights reserved.
//

import Foundation
import UIKit

class LinkLabel: UILabel {
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }
        
        let location = gesture.location(in: label)
        if let attributedText = attributedText {
            attributedText.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedText.length), options: []) { value, range, _ in
                if let url = value as? URL {
                    let textContainer = NSTextContainer(size: label.bounds.size)
                    let layoutManager = NSLayoutManager()
                    let textStorage = NSTextStorage(attributedString: label.attributedText!)
                    textStorage.addLayoutManager(layoutManager)
                    layoutManager.addTextContainer(textContainer)
                    
                    let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
                    
                    let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
                    
                    if boundingRect.contains(location) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
}
