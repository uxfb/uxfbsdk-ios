//
//  UXFSmilesCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class SmilesCell: BaseCell {
    enum SmileState {
        case normal
        case touched
        case selected
        case disabled
    }
    
    
    private func replaceColorsInImage(_ image: UIImage, state: SmileState) -> UIImage? {
        guard let cgImage = image.cgImage,
              var newYellow = theme?.iconSmile1Color,
              let newBlack = theme?.iconSmile2Color,
              var newRed = theme?.iconSmile3Color else { return image }

        switch state {
            case .normal:
                break
                
        case .selected:
            break

        case .touched:
            newYellow = theme?.iconSmile4Color ?? newYellow

        case .disabled:
            newYellow = theme?.iconDisabledColor ?? newYellow
            newRed = theme?.text03Color ?? newRed
            // newRed = newBlack
        }

        let defaultTheme = Theme()
        let colorMap: [UIColor: UIColor] = [
            defaultTheme.iconSmile1Color: newYellow,
            defaultTheme.iconSmile2Color: newBlack,
            defaultTheme.iconSmile3Color: newRed
        ]

        guard let cg = image.cgImage else { return image }

        let width = cg.width
        let height = cg.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))

        let preparedColorMap: [([UInt8], [UInt8])] = colorMap.compactMap { oldColor, newColor in
            var oldR: CGFloat = 0, oldG: CGFloat = 0, oldB: CGFloat = 0, oldA: CGFloat = 0
            var newR: CGFloat = 0, newG: CGFloat = 0, newB: CGFloat = 0, newA: CGFloat = 0

            guard oldColor.getRed(&oldR, green: &oldG, blue: &oldB, alpha: &oldA),
                  newColor.getRed(&newR, green: &newG, blue: &newB, alpha: &newA) else {
                return nil
            }

            let oldRGB: [UInt8] = [
                UInt8(clamping: Int(oldR * 255)),
                UInt8(clamping: Int(oldG * 255)),
                UInt8(clamping: Int(oldB * 255))
            ]

            let newRGBA: [UInt8] = [
                UInt8(clamping: Int(newR * 255)),
                UInt8(clamping: Int(newG * 255)),
                UInt8(clamping: Int(newB * 255)),
                UInt8(clamping: Int(newA * 255))
            ]

            return (oldRGB, newRGBA)
        }

        let anchors: [(rgb: [Double], replacement: [Double])] = preparedColorMap.map { oldRGB, newRGBA in
            (oldRGB.map { Double($0) }, newRGBA.map { Double($0) })
        }

        for i in stride(from: 0, to: pixelData.count, by: 4) {
            let srcA = pixelData[i + 3]

            if srcA == 0 { continue }

            let p = [
                Double(pixelData[i]) * 255 / Double(srcA),
                Double(pixelData[i + 1]) * 255 / Double(srcA),
                Double(pixelData[i + 2]) * 255 / Double(srcA)
            ]

            var bestResidual = Double.greatestFiniteMagnitude
            var bestColor: [Double]?

            for a in 0..<anchors.count {
                for b in a..<anchors.count {
                    let ca = anchors[a]
                    let cb = anchors[b]

                    var t = 0.0
                    if a != b {
                        var dot = 0.0
                        var lengthSquared = 0.0
                        for k in 0..<3 {
                            let ab = cb.rgb[k] - ca.rgb[k]
                            dot += (p[k] - ca.rgb[k]) * ab
                            lengthSquared += ab * ab
                        }
                        if lengthSquared > 0 {
                            t = min(max(dot / lengthSquared, 0), 1)
                        }
                    }

                    var residual = 0.0
                    for k in 0..<3 {
                        let d = p[k] - (ca.rgb[k] + (cb.rgb[k] - ca.rgb[k]) * t)
                        residual += d * d
                    }

                    if residual < bestResidual {
                        bestResidual = residual
                        bestColor = (0..<4).map { k in
                            ca.replacement[k] + (cb.replacement[k] - ca.replacement[k]) * t
                        }
                    }
                }
            }

            guard let newColor = bestColor else { continue }

            let finalAlpha = (Double(srcA) / 255.0) * (newColor[3] / 255.0)

            pixelData[i]     = UInt8(clamping: Int(newColor[0] * finalAlpha))
            pixelData[i + 1] = UInt8(clamping: Int(newColor[1] * finalAlpha))
            pixelData[i + 2] = UInt8(clamping: Int(newColor[2] * finalAlpha))
            pixelData[i + 3] = UInt8(clamping: Int(finalAlpha * 255.0))
        }

        guard let newCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage, scale: image.scale, orientation: image.imageOrientation)
    }



    
    private func coloredAngry(state: SmileState) -> UIImage {
        let image = UIImage(named: (state == .selected || state == .touched) ? "angry_highlight" : "angry",
                            in: Consts.bundle,
                            compatibleWith: nil)
        
        return replaceColorsInImage(image!, state: state) ?? image!
    }
    
    private func coloredMad(state: SmileState) -> UIImage {
        let image = UIImage(named: (state == .selected || state == .touched) ? "mad_highlight" : "mad",
                            in: Consts.bundle,
                            compatibleWith: nil)
        
        return replaceColorsInImage(image!, state: state) ?? image!
    }
    
    private func coloredConfused(state: SmileState) -> UIImage {
        let image = UIImage(named: (state == .selected || state == .touched) ? "confused_highlight" : "confused",
                            in: Consts.bundle,
                            compatibleWith: nil)
        
        return replaceColorsInImage(image!, state: state) ?? image!
    }
    
    private func coloredHappy(state: SmileState) -> UIImage {
        let image = UIImage(named: (state == .selected || state == .touched) ? "happy_highlight" : "happy",
                            in: Consts.bundle,
                            compatibleWith: nil)
        
        return replaceColorsInImage(image!, state: state) ?? image!
    }
    
    private func coloredInLove(state: SmileState) -> UIImage {
        let image = UIImage(named: (state == .selected || state == .touched) ? "in-love_highlight" : "in-love",
                            in: Consts.bundle,
                            compatibleWith: nil)
        
        return replaceColorsInImage(image!, state: state) ?? image!
    }
    
    private lazy var smile1: UIButton = {
        let view = UIButton(type: .custom)
        view.tag = 1
        view.contentMode = .center
        view.imageView?.contentMode = .center
        view.clipsToBounds = false
        view.imageView?.clipsToBounds = false
        return view
    }()
    
    private lazy var smile2: UIButton = {
        let view = UIButton(type: .custom)
        view.tag = 2
        view.contentMode = .center
        view.imageView?.contentMode = .center
        view.clipsToBounds = false
        view.imageView?.clipsToBounds = false
        return view
    }()
    
    private lazy var smile3: UIButton = {
        let view = UIButton(type: .custom)
        view.tag = 3
        view.contentMode = .center
        view.imageView?.contentMode = .center
        view.clipsToBounds = false
        view.imageView?.clipsToBounds = false
        return view
    }()
    
    private lazy var smile4: UIButton = {
        let view = UIButton(type: .custom)
        view.tag = 4
        view.contentMode = .center
        view.imageView?.contentMode = .center
        view.clipsToBounds = false
        view.imageView?.clipsToBounds = false
        return view
    }()
    
    private lazy var smile5: UIButton = {
        let view = UIButton(type: .custom)
        view.tag = 5
        view.contentMode = .center
        view.imageView?.contentMode = .center
        view.clipsToBounds = false
        view.imageView?.clipsToBounds = false
        return view
    }()
    
    private lazy var noAnswerView: NoAnswerView = {
        let view = NoAnswerView()
        view.isHidden = true
        view.onToggle = { [weak self] isOn in
            self?.noAnswerToggled(isOn)
        }
        return view
    }()

    private var animationInProgress: Bool = false
    private var currentValue: Int = -1

    override func setupSubviews() {
        clipsToBounds = false
        contentView.clipsToBounds = false
        contentView.addSubview(smile1)
        contentView.addSubview(smile2)
        contentView.addSubview(smile3)
        contentView.addSubview(smile4)
        contentView.addSubview(smile5)
        contentView.addSubview(noAnswerView)
        
        for i in 1...5 {
            if let smile = contentView.viewWithTag(i) as? UIButton {
                smile.adjustsImageWhenHighlighted = false
                smile.layer.cornerRadius = 19
            }
        }
        
        smile1.translatesAutoresizingMaskIntoConstraints = false
        smile2.translatesAutoresizingMaskIntoConstraints = false
        smile3.translatesAutoresizingMaskIntoConstraints = false
        smile4.translatesAutoresizingMaskIntoConstraints = false
        smile5.translatesAutoresizingMaskIntoConstraints = false
        noAnswerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            smile3.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            smile3.centerYAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            smile3.heightAnchor.constraint(equalToConstant: 38),
            smile3.widthAnchor.constraint(equalToConstant: 38),

            smile2.trailingAnchor.constraint(equalTo: smile3.leadingAnchor, constant: -20),
            smile2.centerYAnchor.constraint(equalTo: smile3.centerYAnchor),
            smile2.heightAnchor.constraint(equalToConstant: 38),
            smile2.widthAnchor.constraint(equalToConstant: 38),

            smile1.trailingAnchor.constraint(equalTo: smile2.leadingAnchor, constant: -20),
            smile1.centerYAnchor.constraint(equalTo: smile3.centerYAnchor),
            smile1.heightAnchor.constraint(equalToConstant: 38),
            smile1.widthAnchor.constraint(equalToConstant: 38),

            smile4.leadingAnchor.constraint(equalTo: smile3.trailingAnchor, constant: 20),
            smile4.centerYAnchor.constraint(equalTo: smile3.centerYAnchor),
            smile4.heightAnchor.constraint(equalToConstant: 38),
            smile4.widthAnchor.constraint(equalToConstant: 38),

            smile5.leadingAnchor.constraint(equalTo: smile4.trailingAnchor, constant: 20),
            smile5.centerYAnchor.constraint(equalTo: smile3.centerYAnchor),
            smile5.heightAnchor.constraint(equalToConstant: 38),
            smile5.widthAnchor.constraint(equalToConstant: 38),

            noAnswerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            noAnswerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            noAnswerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            noAnswerView.heightAnchor.constraint(equalToConstant: NoAnswerView.height),
        ])
        
        for i in 1...5 {
            if let smile = contentView.viewWithTag(i) as? UIButton {
                smile.adjustsImageWhenHighlighted = false
                smile.layer.cornerRadius = 19

                smile.addTarget(self, action: #selector(smileTouchDown(_:)), for: .touchDown)

                smile.addTarget(self, action: #selector(smileDragEnter(_:)), for: .touchDragEnter)
                smile.addTarget(self, action: #selector(smileDragExit(_:)),  for: .touchDragExit)

                smile.addTarget(self, action: #selector(smileTouchUpInside(_:)), for: .touchUpInside)
                smile.addTarget(self, action: #selector(smileTouchCancel(_:)), for: [.touchUpOutside, .touchCancel])
            }
        }

    }
    
    override func updateUI() {
        currentValue = isNoAnswerSelected ? -1 : Int(field?.answers.first ?? "") ?? -1

        noAnswerView.isHidden = noAnswerName == nil
        if let name = noAnswerName {
            noAnswerView.configure(title: name, theme: theme, isOn: isNoAnswerSelected)
        }

        applyState()

        if (field?.isError ?? false) && currentValue == -1 && !isNoAnswerSelected {
            animateSmiles()
        }
    }
    
    private func setSmileState(tag: Int, state: SmileState) {
        switch tag {
            case 1:
                UIView.transition(with: self.smile1,
                                  duration: 0.25,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.smile1.setImage(self.coloredAngry(state: state), for: .normal)
                })
                
                
            case 2:
                UIView.transition(with: self.smile2,
                                  duration: 0.25,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.smile2.setImage(self.coloredMad(state: state), for: .normal)
                })
                
                
            case 3:
                UIView.transition(with: self.smile3,
                                  duration: 0.25,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.smile3.setImage(self.coloredConfused(state: state), for: .normal)
                })
                
                
            case 4:
                UIView.transition(with: self.smile4,
                                  duration: 0.25,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.smile4.setImage(self.coloredHappy(state: state), for: .normal)
                })
                
                
            case 5:
                UIView.transition(with: self.smile5,
                                  duration: 0.25,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.smile5.setImage(self.coloredInLove(state: state), for: .normal)
                })
                
                
            default:
                break
                
        }
    }
    
    private func applyState() {
        let noAnswer = isNoAnswerSelected
        for i in 1...5 {
            self.contentView.viewWithTag(i)?.borderWidth = 0
            self.contentView.viewWithTag(i)?.isUserInteractionEnabled = !noAnswer
            if noAnswer {
                setSmileState(tag: i, state: .disabled)
            } else if (i == currentValue + 1) {
                setSmileState(tag: i, state: .selected)
            } else if currentValue == -1 {
                setSmileState(tag: i, state: .normal)
            } else {
                setSmileState(tag: i, state: .disabled)
            }
        }
    }
    
    func animateSmiles() {
        UIView.animate(withDuration: 0.1) {
            for tag in 1...5 {
                self.contentView.viewWithTag(tag)?.frame.origin.x -= 3
            }
        } completion: { (finished) in
            UIView.animate(withDuration: 0.1) {
                for tag in 1...5 {
                    self.contentView.viewWithTag(tag)?.frame.origin.x += 6
                }
            } completion: { (finished) in
                UIView.animate(withDuration: 0.1) {
                    for tag in 1...5 {
                        self.contentView.viewWithTag(tag)?.frame.origin.x -= 4.5
                    }
                } completion: { (finished) in
                    UIView.animate(withDuration: 0.1) {
                        for tag in 1...5 {
                            self.contentView.viewWithTag(tag)?.frame.origin.x += 3
                        }
                    } completion: { (finished) in
                        UIView.animate(withDuration: 0.1) {
                            for tag in 1...5 {
                                self.contentView.viewWithTag(tag)?.frame.origin.x -= 1.5
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    @objc
    private func smileTouched(_ sender: UIButton) {
        setSmileState(tag: sender.tag, state: .touched)
        sender.layer.borderColor = theme?.iconSmile4Color.withAlphaComponent(1.0).cgColor
        sender.layer.borderWidth = 7
    }
    
    @objc
    private func smileOutside(_ sender: UIButton) {
        applyState()
        sender.layer.borderWidth = 0
    }
    
    @objc
    private func smileTapped(_ sender: UIButton) {
        sender.layer.borderWidth = 0
        guard !animationInProgress, sender.tag != currentValue+1 else {
            return
        }
        
        animationInProgress = true
        currentValue = sender.tag
        UIView.animate(withDuration: 0.15) {
//            self.applyState()
        } completion: { (finished) in
            self.animationInProgress = false
            
        }
    }

    private func clearHighlights() {
        for i in 1...5 {
            if let b = contentView.viewWithTag(i) as? UIButton {
                for layer in b.layer.sublayers ?? [] {
                    if layer.accessibilityLabel == "SmilesCell.Highlighted" && currentValue != b.tag - 1 {
                        layer.removeFromSuperlayer()
                    }
                }
            }
        }
    }

    private func highlight(_ sender: UIButton) {
        clearHighlights()
        setSmileState(tag: sender.tag, state: .touched)
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = UIBezierPath(
            roundedRect: sender.bounds.insetBy(dx: 0, dy: 0),
            cornerRadius: sender.layer.cornerRadius + 3
        ).cgPath

        borderLayer.strokeColor = theme?.iconSmile4Color.withAlphaComponent(0.2).cgColor
        borderLayer.fillColor = theme?.iconSmile4Color.withAlphaComponent(0.2).cgColor
        borderLayer.lineWidth = 6
        borderLayer.accessibilityLabel = "SmilesCell.Highlighted"
//        sender.layer.addSublayer(borderLayer)
        
    }

    @objc private func smileTouchDown(_ sender: UIButton) {
        highlight(sender)
    }

    @objc private func smileDragEnter(_ sender: UIButton) {
        highlight(sender)
    }

    @objc private func smileDragExit(_ sender: UIButton) {
        sender.layer.borderWidth = 0
        applyState()
    }

    @objc private func smileTouchUpInside(_ sender: UIButton) {
        currentValue = sender.tag - 1
        clearHighlights()
        delegate?.fieldChanged(field!, answer: [String(currentValue)], refresh: true)
        applyState()
    }

    @objc private func smileTouchCancel(_ sender: UIButton) {
        clearHighlights()
        applyState()
    }
    
    /*
    private func touchPoint(_ location: CGPoint) {
        applyState()
        for i in 1...5 {
            guard let smile = contentView.viewWithTag(i) as? UIButton else { continue }
            
            let p = contentView.convert(location, to: smile)
            
            if smile.bounds.contains(p) {
                smile.layer.borderColor = theme?.iconSmile4Color.withAlphaComponent(0.2).cgColor
                smile.layer.borderWidth = 5
                setSmileState(tag: smile.tag, state: .touched)
            } else {
                smile.layer.borderWidth = 0
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location : CGPoint = (touch?.location(in: self.contentView))!
		
        touchPoint(location)
        super.touchesBegan(touches, with:event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location : CGPoint = (touch?.location(in: self.contentView))!

        touchPoint(location)
        super.touchesMoved(touches, with: event)
    }
  
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location : CGPoint = (touch?.location(in: self.contentView))!

        for i in 1...5 {
            if let smile = contentView.viewWithTag(i) as? UIButton {
                if smile.point(inside: self.contentView.convert(location, to: smile.forLastBaselineLayout), with: nil) {
                    self.currentValue = smile.tag
                    if self.delegate != nil {
                        self.delegate?.fieldChanged(self.field!, answer: [String(self.currentValue - 1)], refresh: true)
                    }
                }
            }
        }
        
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		applyState()

        super.touchesCancelled(touches, with: event)
    }
     */
}
