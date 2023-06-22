//
//  UXFScreenshotCreator.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 01.08.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit

class ScreenshotCreator: UIView {

    private var direction: CGFloat = 0
    private var completeAction: imagePickerAction?
    
    @IBOutlet weak var handBottom: NSLayoutConstraint!
    
    @IBOutlet weak var shadowTop: NSLayoutConstraint!
    @IBOutlet weak var shadowBottom: NSLayoutConstraint!
    @IBOutlet weak var shadowLeft: NSLayoutConstraint!
    @IBOutlet weak var shadowRight: NSLayoutConstraint!
    
    @IBOutlet weak var textLabel: UILabel! {
        didSet {
            textLabel.text = Consts.Texts.startScroll
        }
    }
    @IBOutlet weak var touchImage: UIImageView!
    @IBOutlet weak var arrowImage: UIImageView!
    
    @IBOutlet weak var okButton: UIButton! {
        didSet {
            okButton.backgroundColor = UIColor.init("#0076C2")
            okButton.layer.masksToBounds = true
            okButton.addShadowAndRoundCorner(cornerRadius: 28)
            okButton.isEnabled = true
        }
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.backgroundColor = UIColor.init("#F15E61")
            cancelButton.layer.masksToBounds = true
            cancelButton.addShadowAndRoundCorner(cornerRadius: 28)
        }
    }
    @IBOutlet weak var shadowView: UIView! {
        didSet {
            shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            
            let panGestureRecognizer = UIPanGestureRecognizer()
            panGestureRecognizer.addTarget(self, action: #selector(onPan(pan:)))
            shadowView.addGestureRecognizer(panGestureRecognizer)
        }
    }
    
    private var displayLink: CADisplayLink?
    private var startTime: TimeInterval?
    
    public func configure(frame: CGRect, completion: @escaping imagePickerAction) {
        self.frame = frame
        self.completeAction = completion
    }
    
    func showHandAnimation() {
        displayLink = CADisplayLink(target: self,
        selector: #selector(animateHand))
        
        startTime = CACurrentMediaTime()
        displayLink?.add(to: RunLoop.main, forMode: .common)
    }
    
    @objc private func animateHand() {
        guard let startTime = startTime else {
            return
        }
        
        let now = CACurrentMediaTime()
        
        let timeDiff = now - startTime
        
        let whole = timeDiff.rounded(.down)
        let fraction = timeDiff - whole
        
        let diffPos = 28.0 * fraction
        
//        self.handBottom.constant = 48 + diffPos
        
        if Int(whole) % 2 == 0 {
            self.handBottom.constant = 48 + CGFloat(diffPos)
        } else {
            self.handBottom.constant = 76 - CGFloat(diffPos)
        }
    }
    
    @IBAction func pressOk(_ sender: Any) {
        let flashView = UIView(frame: self.bounds)
        flashView.backgroundColor = .white
        flashView.alpha = 1.0
        self.addSubview(flashView)
        
        UIView.animate(withDuration: 0.3) {
            flashView.alpha = 0.0
        } completion: { finished in
            ImageManager.hide(animated: true, duration: 0.5)
        }
        
        var screenshotImage :UIImage?
        for window in UIApplication.shared.windows {
            if !(window is PassthroughWindow) {
                let layer = window.layer
                let scale = UIScreen.main.scale
                UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
                guard let context = UIGraphicsGetCurrentContext() else { return }
                layer.render(in:context)
                screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                if let image = screenshotImage {
                    if self.completeAction != nil {
                        self.completeAction!([image])
                    }
                }
                break
            }
        }
    }
    
    @IBAction func pressCancel(_ sender: Any) {
        self.displayLink?.invalidate()
        ImageManager.hide(animated: true)
    }
    
    @objc func onPan(pan: UIPanGestureRecognizer) -> Void {
        
        switch pan.state {
        case .began:
            break
        case .changed:
            let velocity = pan.velocity(in: pan.view?.superview)
            direction = velocity.y
            break
        case .ended:
            if abs(direction) > 120 {
                textLabel.isHidden = true
                arrowImage.isHidden = true
                touchImage.isHidden = true
                
                //size = 136x72
                
                let bottom: CGFloat = 40 + .bottomArea
                let top: CGFloat = shadowView.frame.size.height - bottom - 72
                let side: CGFloat = (shadowView.frame.size.width - 136)/2
                
                self.shadowBottom.constant = bottom
                self.shadowTop.constant = top
                self.shadowLeft.constant = side
                self.shadowRight.constant = side
                
                self.displayLink?.invalidate()
                
                UIView.animate(withDuration: 0.3) {
                    self.shadowView.layoutIfNeeded()
                    self.shadowView.layer.cornerRadius = 36
                    self.shadowView.layer.masksToBounds = true
                } completion: { finished in
                    self.okButton.isEnabled = true
                }
            }
            
            break
        default:
            break
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = super.hitTest(point, with: event)
        if view != self {
            return view
        }
        
        while !(view is PassthroughWindow) {
            view = view?.superview
            
            if view?.superview == nil {
                break
            }
        }

        return view
    }
}
