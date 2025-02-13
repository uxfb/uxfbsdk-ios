//
//  UXFScreenshotCreator.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 01.08.2021.
//  Copyright © 2021 UXF. All rights reserved.
//

import UIKit

class ScreenshotCreator: UIView {
    
    var theme: ThemeProtocol?
    
    private var direction: CGFloat = 0
    private var completeAction: imagePickerAction?
    
    private var handBottom: NSLayoutConstraint!
    private var shadowTop: NSLayoutConstraint!
    private var shadowBottom: NSLayoutConstraint!
    private var shadowLeft: NSLayoutConstraint!
    private var shadowRight: NSLayoutConstraint!
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = Consts.Texts.startScroll
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    lazy var touchImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "touch", in: Consts.bundle, compatibleWith: nil)
        return image
    }()
    lazy var arrowImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "line_array", in: Consts.bundle, compatibleWith: nil)
        return image
    }()
    
    lazy var okButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.addShadowAndRoundCorner(cornerRadius: 28)
        button.setImage(UIImage(named: "check", in: Consts.bundle, compatibleWith: nil), for: .normal)
        button.isEnabled = true
        button.addTarget(self, action: #selector(pressOk(_:)), for: .touchUpInside)
        return button
    }()
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.addShadowAndRoundCorner(cornerRadius: 28)
        button.setImage(UIImage(named: "close", in: Consts.bundle, compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(pressCancel(_:)), for: .touchUpInside)
        return button
    }()
    lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(onPan(pan:)))
        view.addGestureRecognizer(panGestureRecognizer)
        return view
    }()
    
    private var displayLink: CADisplayLink?
    private var startTime: TimeInterval?
    
    public func configure(frame: CGRect, completion: @escaping imagePickerAction) {
        self.frame = frame
        self.completeAction = completion
        updateUI()
    }
    
    func showHandAnimation() {
        displayLink = CADisplayLink(target: self,
                                    selector: #selector(animateHand))
        
        startTime = CACurrentMediaTime()
        displayLink?.add(to: RunLoop.main, forMode: .common)
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        shadowView.addSubview(textLabel)
        shadowView.addSubview(arrowImage)
        shadowView.addSubview(touchImage)
        addSubview(shadowView)
        addSubview(okButton)
        addSubview(cancelButton)
        
        okButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImage.translatesAutoresizingMaskIntoConstraints = false
        touchImage.translatesAutoresizingMaskIntoConstraints = false
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        handBottom = NSLayoutConstraint(item: textLabel,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: touchImage,
                                        attribute: .bottom,
                                        multiplier: 1,
                                        constant: 48)
        
        shadowLeft = NSLayoutConstraint(item: shadowView,
                                        attribute: .leading,
                                        relatedBy: .equal,
                                        toItem: self,
                                        attribute: .leading,
                                        multiplier: 1,
                                        constant: 0)
        
        shadowRight = NSLayoutConstraint(item: self,
                                         attribute: .trailing,
                                         relatedBy: .equal,
                                         toItem: shadowView,
                                         attribute: .trailing,
                                         multiplier: 1,
                                         constant: 0)
        
        shadowTop = NSLayoutConstraint(item: shadowView,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: self,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: 0)
        
        shadowBottom = NSLayoutConstraint(item: self,
                                          attribute: .bottom,
                                          relatedBy: .equal,
                                          toItem: shadowView,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 0)
        
        NSLayoutConstraint.activate([
            shadowLeft,
            shadowRight,
            shadowTop,
            shadowBottom,
            
            okButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 32),
            okButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -48),
            okButton.heightAnchor.constraint(equalToConstant: 56),
            okButton.widthAnchor.constraint(equalToConstant: 56),
            
            cancelButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -32),
            cancelButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -48),
            cancelButton.heightAnchor.constraint(equalToConstant: 56),
            cancelButton.widthAnchor.constraint(equalToConstant: 56),
            
            arrowImage.heightAnchor.constraint(equalToConstant: 65),
            arrowImage.widthAnchor.constraint(equalToConstant: 38),
            arrowImage.bottomAnchor.constraint(equalTo: okButton.topAnchor, constant: -60),
            arrowImage.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 48),
            
            textLabel.bottomAnchor.constraint(equalTo: arrowImage.topAnchor, constant: -32),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            
            touchImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            touchImage.widthAnchor.constraint(equalToConstant: 64),
            touchImage.heightAnchor.constraint(equalToConstant: 64),
            handBottom
        ])
    }
    
    private func updateUI() {
//        textLabel.textColor = theme?.btnTextColor
        okButton.backgroundColor = theme?.btnBgColor
        okButton.setTitleColor(theme?.btnTextColor, for: .normal)
        okButton.imageView?.tintColor = theme?.btnTextColor
        okButton.imageView?.image = okButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
        cancelButton.backgroundColor = theme?.errorColorPrimary
        cancelButton.setTitleColor(theme?.btnTextColor, for: .normal)
        cancelButton.imageView?.tintColor = theme?.btnTextColor
        cancelButton.imageView?.image = cancelButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
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
        
        if Int(whole) % 2 == 0 {
            self.handBottom.constant = 48 + CGFloat(diffPos)
        } else {
            self.handBottom.constant = 76 - CGFloat(diffPos)
        }
    }
    
    @objc
    private func pressOk(_ sender: Any) {
        let flashView = UIView(frame: self.bounds)
        flashView.backgroundColor = .white
        flashView.alpha = 1.0
        self.addSubview(flashView)
        
        UIView.animate(withDuration: 0.3) {
            flashView.alpha = 0.0
        } completion: { finished in
            ImageManager.hide(animated: true, duration: 0.5)
        }
        
        var captureWindow: UIWindow?
        if #available(iOS 13.0, *) {
            let allScenes = UIApplication.shared.connectedScenes
            let scene = allScenes.first { $0.activationState == .foregroundActive }
            if let windowScene = scene as? UIWindowScene {
                for window in windowScene.windows {
                    if window.windowLevel == .normal && !window.isKind(of: PassthroughWindow.self) {
                        captureWindow = window
                        break
                    }
                }
            } else {
                for window in UIApplication.shared.windows {
                    if window.windowLevel == .normal && !window.isKind(of: PassthroughWindow.self) {
                        captureWindow = window
                        break
                    }
                }
            }
        } else {
            for window in UIApplication.shared.windows {
                if window.windowLevel == .normal && !window.isKind(of: PassthroughWindow.self) {
                    captureWindow = window
                    break
                }
            }
        }
        
        if let window = captureWindow {
            print(String(describing: window.rootViewController.self))
            if let view = window.rootViewController?.view,
               String(describing: view.self).contains("FlutterView") {
                let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
                let image = renderer.image { ctx in
                    view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
                }
                if self.completeAction != nil {
                    self.completeAction!([image])
                }
            } else {
                UIGraphicsBeginImageContextWithOptions(window.layer.frame.size, true, 0)
                guard let context = UIGraphicsGetCurrentContext() else { return }
                window.layer.render(in: context)
                guard let image = UIGraphicsGetImageFromCurrentImageContext()  else { return }
                UIGraphicsEndImageContext()
                if self.completeAction != nil {
                    self.completeAction!([image])
                }
            }
        }
    }
    
    @objc
    private func pressCancel(_ sender: Any) {
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
                        pan.isEnabled = false
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
