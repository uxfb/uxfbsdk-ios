//
//  UXFSmilesCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class SmilesCell: BaseCell {
    private func replaceColorsInImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage,
              let newYellow = theme?.iconSmile1Color,
              let newBlack = theme?.iconSmile2Color,
              let newRed = theme?.iconSmile3Color else { return image }
        
        let defaultTheme = Theme()
        let colorMap: [UIColor: UIColor] = [
            defaultTheme.iconSmile1Color: newYellow,
            defaultTheme.iconSmile2Color: newBlack,
            defaultTheme.iconSmile3Color: newRed
        ]
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context = CGContext(data: &pixelData,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: bitsPerComponent,
                                    bytesPerRow: bytesPerRow,
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let preparedColorMap: [([UInt8], [UInt8])] = colorMap.compactMap { oldColor, newColor in
            var oldR: CGFloat = 0, oldG: CGFloat = 0, oldB: CGFloat = 0, oldA: CGFloat = 0
            var newR: CGFloat = 0, newG: CGFloat = 0, newB: CGFloat = 0, newA: CGFloat = 0
            
            guard oldColor.getRed(&oldR, green: &oldG, blue: &oldB, alpha: &oldA),
                  newColor.getRed(&newR, green: &newG, blue: &newB, alpha: &newA) else {
                return nil
            }
            
            let oldComponents = [
                UInt8(oldR * 255),
                UInt8(oldG * 255),
                UInt8(oldB * 255),
                UInt8(oldA * 255)
            ]
            
            let newComponents = [
                UInt8(newR * 255),
                UInt8(newG * 255),
                UInt8(newB * 255),
                UInt8(newA * 255)
            ]
            
            return (oldComponents, newComponents)
        }
        
        for i in stride(from: 0, to: pixelData.count, by: 4) {
            let r = pixelData[i]
            let g = pixelData[i+1]
            let b = pixelData[i+2]
            let a = pixelData[i+3]
            
            for (oldComponents, newComponents) in preparedColorMap {
                if abs(Int(r) - Int(oldComponents[0])) < 10 &&
                   abs(Int(g) - Int(oldComponents[1])) < 10 &&
                   abs(Int(b) - Int(oldComponents[2])) < 10 &&
                   abs(Int(a) - Int(oldComponents[3])) < 10 {
                    
                    pixelData[i] = newComponents[0]
                    pixelData[i+1] = newComponents[1]
                    pixelData[i+2] = newComponents[2]
                    pixelData[i+3] = newComponents[3]
                    break
                }
            }
        }
        
        guard let newCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage)
    }
    
    private func coloredAngry() -> UIImage {
        let image = UIImage(named: "angry",
                            in: Consts.bundle,
                            compatibleWith: nil)
        
        return replaceColorsInImage(image!) ?? image!
    }
    
    private func coloredMad() -> UIImage {
        let image = UIImage(named: "mad",
                            in: Consts.bundle,
                            compatibleWith: nil)
        
        return replaceColorsInImage(image!) ?? image!
    }
    
    private func coloredConfused() -> UIImage {
        let image = UIImage(named: "confused",
                            in: Consts.bundle,
                            compatibleWith: nil)
        
        return replaceColorsInImage(image!) ?? image!
    }
    
    private func coloredHappy() -> UIImage {
        let image = UIImage(named: "happy",
                            in: Consts.bundle,
                            compatibleWith: nil)
        
        return replaceColorsInImage(image!) ?? image!
    }
    
    private func coloredInLove() -> UIImage {
        let image = UIImage(named: "in-love",
                            in: Consts.bundle,
                            compatibleWith: nil)
        
        return replaceColorsInImage(image!) ?? image!
    }
    
    private lazy var smile1: UIButton = {
        let view = UIButton(type: .custom)
        view.addTarget(self, action: #selector(smileTapped(_:)), for: .touchUpInside)
        view.tag = 1
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var smile2: UIButton = {
        let view = UIButton(type: .custom)
        view.addTarget(self, action: #selector(smileTapped(_:)), for: .touchUpInside)
        view.tag = 2
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var smile3: UIButton = {
        let view = UIButton(type: .custom)
        view.addTarget(self, action: #selector(smileTapped(_:)), for: .touchUpInside)
        view.tag = 3
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var smile4: UIButton = {
        let view = UIButton(type: .custom)
        view.addTarget(self, action: #selector(smileTapped(_:)), for: .touchUpInside)
        view.tag = 4
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var smile5: UIButton = {
        let view = UIButton(type: .custom)
        view.addTarget(self, action: #selector(smileTapped(_:)), for: .touchUpInside)
        view.tag = 5
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private var animationInProgress: Bool = false
    private var currentValue: Int = -1
    
    override func setupSubviews() {
        contentView.addSubview(smile1)
        contentView.addSubview(smile2)
        contentView.addSubview(smile3)
        contentView.addSubview(smile4)
        contentView.addSubview(smile5)
        
        for i in 1...5 {
            if let smile = contentView.viewWithTag(i) as? UIButton {
                smile.adjustsImageWhenHighlighted = false
            }
        }
        
        smile1.translatesAutoresizingMaskIntoConstraints = false
        smile2.translatesAutoresizingMaskIntoConstraints = false
        smile3.translatesAutoresizingMaskIntoConstraints = false
        smile4.translatesAutoresizingMaskIntoConstraints = false
        smile5.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            smile3.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            smile3.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            smile3.heightAnchor.constraint(equalToConstant: 38),
            smile3.widthAnchor.constraint(equalToConstant: 38),
            
            smile2.trailingAnchor.constraint(equalTo: smile3.leadingAnchor, constant: -20),
            smile2.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            smile2.heightAnchor.constraint(equalToConstant: 38),
            smile2.widthAnchor.constraint(equalToConstant: 38),
            
            smile1.trailingAnchor.constraint(equalTo: smile2.leadingAnchor, constant: -20),
            smile1.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            smile1.heightAnchor.constraint(equalToConstant: 38),
            smile1.widthAnchor.constraint(equalToConstant: 38),
            
            smile4.leadingAnchor.constraint(equalTo: smile3.trailingAnchor, constant: 20),
            smile4.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            smile4.heightAnchor.constraint(equalToConstant: 38),
            smile4.widthAnchor.constraint(equalToConstant: 38),
            
            smile5.leadingAnchor.constraint(equalTo: smile4.trailingAnchor, constant: 20),
            smile5.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            smile5.heightAnchor.constraint(equalToConstant: 38),
            smile5.widthAnchor.constraint(equalToConstant: 38),
        ])
    }
    
    override func updateUI() {
        currentValue = Int(field?.answers.first ?? "") ?? -1
        
        for tag in 1...5 {
            self.contentView.viewWithTag(tag)?.cornerRadius = 19
            
            if currentValue == -1 {
                self.contentView.viewWithTag(tag)?.alpha = 1
            } else {
                self.contentView.viewWithTag(tag)?.alpha = tag != (currentValue + 1) ? 0.2 : 1
            }
        }
        
        if (field?.isError ?? false) && currentValue == -1 {
            animateSmiles()
        }
        
        smile1.setImage(coloredAngry(), for: .normal)
        smile2.setImage(coloredMad(), for: .normal)
        smile3.setImage(coloredConfused(), for: .normal)
        smile4.setImage(coloredHappy(), for: .normal)
        smile5.setImage(coloredInLove(), for: .normal)
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
    private func smileTapped(_ sender: UIButton) {
        guard !animationInProgress, sender.tag != currentValue+1 else {
            return
        }
        
        animationInProgress = true
        currentValue = sender.tag
        UIView.animate(withDuration: 0.15) {
            sender.alpha = 1
            for tag in 1...5 {
                self.contentView.viewWithTag(tag)?.borderColor = .clear
                
                if tag != self.currentValue {
                    self.contentView.viewWithTag(tag)?.alpha = 0.2
                }
            }
        } completion: { (finished) in
            self.animationInProgress = false
            if self.delegate != nil {
                self.delegate?.fieldChanged(self.field!, answer: [String(self.currentValue - 1)], refresh: true)
            }
        }
    }
}
