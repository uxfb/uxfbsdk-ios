//
//  UXFBaseViewController.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 09.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

enum UXFViewPopupDirection{
    case upToDown
    case downToUp
    case alphaIn
    case alphaOut
}

enum UXFViewControllerState{
    case presenting
    case presented
    case backDismiss
    case dismissOnly
}

open class UXFBaseViewController: UIViewController {

    @IBOutlet var contentView: UIView!
    @IBOutlet var contentHeihgt: NSLayoutConstraint!
    
    var presentationAnimated = true
    private (set) var formIndex: Int = 0
    
    var state:UXFViewControllerState = .presenting
    
    var didLoadHandler: ((_ formIndex: Int)->())?
    var didCloseHandler: ((_ formIndex: Int)->(Void))?
    var willCloseHandler: ((_ formIndex: Int)->(Void))?
    var nextHandler: ((_ formIndex: Int, _ info: Dictionary<String, Any>?)->())?
    var backHandler: ((_ formIndex: Int)->())?
    
    var presentDirection: UXFViewPopupDirection = .downToUp
    var dismissDirection: UXFViewPopupDirection = .upToDown
    
    internal var campaign: UXFCampaign?
    
    convenience init() {
        let bundle = Bundle(for: UXFeedback.self)
        self.init(nibName: "UXFBaseViewController", bundle: bundle)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    open override func viewDidLayoutSubviews() {
        switch campaign?.type {
        case .popup:
            contentView.roundCorners(corners: [.topLeft, .topRight], radius: campaign?.theme.formBorderRadius ?? 8)
            break
        case .slidein:
            contentView.roundCorners(corners: .allCorners, radius: campaign?.theme.formBorderRadius ?? 8)
            break
        default:
            break
        }
        
    }

    @IBAction  func closeButtonTapped(_ sender: UIButton){
         self.dismiss(animated: presentationAnimated)
    }
    
    override open func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.willCloseHandler?(self.formIndex)
        
        super.dismiss(animated: presentationAnimated) { [weak self] in

            if let index = self?.formIndex{
                self?.didCloseHandler?(index)
            }
            self?.didCloseHandler = nil
            
            if self?.state != .dismissOnly && self?.state != .backDismiss {
                let window = UIApplication.shared.keyWindow
                window?.isHidden = true
                UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            }
            
            completion?()
        }
    }
}
