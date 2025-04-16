//
//  HtmlLabel.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 24.08.2023.
//  Copyright © 2023 UXF. All rights reserved.
//

import UIKit

protocol HtmlLabelDelegate: AnyObject {
    func htmlLabelLinkDidPress(url: URL?)
}

class HtmlLabel: UILabel {
    weak var delegate: HtmlLabelDelegate?
    private var tapGesture = UITapGestureRecognizer()
    private var links: [HtmlLabelLink] = []

    var textFont: UIFont = .systemFont(ofSize: 14)
    var linkColor: UIColor = UIColor.blue
    var defaultColor: UIColor = UIColor.red
    var action: ((URL?) -> Void)?

    var html: String? {
        didSet {

            guard let string = html else { return }

//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }

                if let data = string.data(using: String.Encoding.unicode),
                   let attributedString = try? NSMutableAttributedString(
                    data: data,
                    options: [.documentType: NSAttributedString.DocumentType.html],
                    documentAttributes: nil
                   ) {
                    
                    

                    
                    if attributedString.length >= 2 {
                        let range = NSRange(location: attributedString.length - 1, length: 1)
                        let lineBreaking = attributedString.attributedSubstring(from: range)
                        if lineBreaking.string == "\n" {
                            attributedString.replaceCharacters(in: range, with: "")
                        }
                    }
                    
                    var universalLabelLinks: [HtmlTextWithLink] = []

                    attributedString.enumerateAttributes(in: attributedString.range) { (attributes, range, _) in
                        let attributedTextWithLink = self.prepareAttributedTextWithLinks(
                            attributedString,
                            attributes: attributes,
                            range: range
                        )
                        universalLabelLinks.append(attributedTextWithLink)
                    }

                    self.concat(textsWithLinks: universalLabelLinks)
                }
            }
//        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommon()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCommon()
    }

    func onPress(action: @escaping (URL?) -> Void) {
        self.action = action
    }
}

// MARK: - Add Link

extension HtmlLabel {
    func addLink(_ htmlLabelLink: HtmlLabelLink) {
        guard let attributedString = self.attributedText else { return }
        let attributedText = NSMutableAttributedString(attributedString: attributedString)
        attributedText.addAttributes(
            htmlLabelLink.linkAttributes.attributes,
            range: htmlLabelLink.textCheckingResult.range
        )
        self.attributedText = attributedText
        links.append(htmlLabelLink)
    }
    
    func concat(textsWithLinks: [HtmlTextWithLink]) {
        let attributedText = NSMutableAttributedString(string: "")
        var labelLinks = [HtmlLabelLink]()

        textsWithLinks.forEach {
            attributedText.append(NSAttributedString(
                string: $0.text,
                attributes: $0.attributes)
            )

            if let link = $0.link,
               let url = URL(string: link),
               let linkAttributes = $0.linkAttributes {

                let range = (attributedText.string as NSString).range(of: $0.text)
                let labelLink = HtmlLabelLink(
                    linkAttributes: linkAttributes,
                    textCheckingResult: .linkCheckingResult(range: range, url: url)
                )
                labelLinks.append(labelLink)
            }
        }
        
        self.attributedText = attributedText
        labelLinks.forEach { addLink($0) }
    }
}

// MARK: - Prepare Text

extension HtmlLabel {
    
    func prepareTextAttributes(_ attributes: [NSAttributedString.Key : Any]) -> [NSAttributedString.Key: Any] {
        guard let font: UIFont = attributes[NSAttributedString.Key.font] as? UIFont else {
            return attributes
        }

        let defaultFont: UIFont

        if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
            defaultFont = textFont
        } else {
            defaultFont = textFont
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        
        return [
            .font: defaultFont,
            .paragraphStyle: paragraphStyle
        ]
    }
    
    func prepareAttributedTextWithLinks(
        _ attributedString: NSAttributedString,
        attributes: [NSAttributedString.Key : Any],
        range: NSRange
    ) -> HtmlTextWithLink {
        let string = attributedString.attributedSubstring(from: range).string

        let textAttributes = self.prepareTextAttributes(attributes)
        var linkAttributes = textAttributes
        linkAttributes[.foregroundColor] = self.linkColor

        var linkActiveAttributes = textAttributes
        linkActiveAttributes[.foregroundColor] = self.linkColor.withAlphaComponent(0.6)
        
        if let link = attributes[.link], let url = link as? URL {
            return HtmlTextWithLink(
                text: string,
                attributes: [:],
                link: url.absoluteString,
                linkAttributes: LinkAttributes(
                    attributes: linkAttributes,
                    activeAttributes: linkActiveAttributes,
                    inactiveAttributes: linkAttributes
                )
            )
        } else {
            var defaultTextAttributes = textAttributes
            defaultTextAttributes[.foregroundColor] = defaultColor

            if let _ = attributes[NSAttributedString.Key.underlineStyle] as? Int {
                defaultTextAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }

            return HtmlTextWithLink(
                text: string,
                attributes: defaultTextAttributes
            )
        }
    }
}

// MARK: - Setup

private extension HtmlLabel {
    func setupCommon() {
        isUserInteractionEnabled = true
        setupTapGestureRecognizer()
    }

    func setupTapGestureRecognizer() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }

    func setupAttributes(of link: HtmlLabelLink) {
        setupAttributes(link.linkAttributes.attributes, range: link.textCheckingResult.range)
    }

    func setupActiveAttributes(of link: HtmlLabelLink) {
        setupAttributes(link.linkAttributes.activeAttributes, range: link.textCheckingResult.range)
    }
    
    private func setupAttributes(_ attributes: [NSAttributedString.Key : Any], range: NSRange) {
        guard let attributedString = self.attributedText else { return }
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        mutableAttributedString.addAttributes(attributes, range: range)
        self.attributedText = attributedText
    }
}

// MARK: - Get a link on tap

private extension HtmlLabel {
    @objc func onTap(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: self)
        guard let link = getLinkAtPoint(touchPoint) else { return }
        let url = link.textCheckingResult.url
        delegate?.htmlLabelLinkDidPress(url: url)
        action?(url)
    }

    func getLinkAtPoint(_ point: CGPoint) -> HtmlLabelLink? {
        let index = indexOfAttributedTextCharacterAtPoint(point)
        return links.first { NSLocationInRange(index, $0.textCheckingResult.range) == true }
    }

    func containLinkAtPoint(_ point: CGPoint) -> Bool {
        let index = indexOfAttributedTextCharacterAtPoint(point)
        return links.contains { NSLocationInRange(index, $0.textCheckingResult.range) }
    }

    func indexOfAttributedTextCharacterAtPoint(_ point: CGPoint) -> Int {
        guard let attributedString = self.attributedText else { return -1 }

        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode
        layoutManager.addTextContainer(textContainer)

        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}

// MARK: - UIGestureRecognizerDelegate

extension HtmlLabel: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        containLinkAtPoint(touch.location(in: self))
    }
}

// MARK: - Touches

extension HtmlLabel {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let touchPoint = touches.first?.location(in: self),
              let link = getLinkAtPoint(touchPoint) else { return }
        setupActiveAttributes(of: link)
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        links.forEach { setupAttributes(of: $0) }
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        links.forEach { setupAttributes(of: $0) }
        super.touchesCancelled(touches, with: event)
    }
}

// MARK: - NSAttributedString

extension NSAttributedString {
    var range: NSRange {
        NSRange(location: 0, length: length)
    }
}
