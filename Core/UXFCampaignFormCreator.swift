//
//  UXFCampaignFormCreator.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 16/04/2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation
import UIKit

class UXFCampaignFormCreator{
    
    func createForm(controller: UXFViewController, page: UXFPage) {

        var topView = controller.contentView;
        for view in page.fields{
            controller.contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            
            let views = ["view": view, "topView": topView, "superview": controller.contentView]
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[superview]-(15)-[view]-(15)-[superview]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: views as [String : Any])
            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[topView]-15-[view(44)]", options: NSLayoutConstraint.FormatOptions.alignAllCenterX, metrics: nil, views: views as [String : Any])
            controller.contentView.addConstraints(horizontalConstraints)
            controller.contentView.addConstraints(verticalConstraints)
            topView = view
        }
        
        controller.contentView.addSubview(page.button)
        page.button.translatesAutoresizingMaskIntoConstraints = false
        let views = ["topView" : topView, "button": page.button, "superview": controller.contentView]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[superview]-15-[button(44)]-15-[superview]",
                                                                   options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                                   metrics: nil,
                                                                   views: views as [String : Any])
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[topView]-15-[button(120)]-15-[superview]",
                                                                 options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                                 metrics: nil,
                                                                 views: views as [String : Any])
        controller.contentView.addConstraints(horizontalConstraints)
        controller.contentView.addConstraints(verticalConstraints)
    }
}
