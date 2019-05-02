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

        var topView: UIView? = controller.progressLabel
        var allConstraints: [NSLayoutConstraint] = []
        var viewIndex = 0
        for view in page.fields{
            controller.contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            
            let views = ["view": view, "topView": topView]
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[view]-16-|", metrics: nil, views: views as [String : Any])
            let top = (topView == nil ? "|" : "[topView]")
            let bottom = (viewIndex == (page.fields.count - 1) ? "|" : "")
 
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:"+top+"-15-[view]-" + bottom, metrics: nil, views: views as [String : Any])

            topView = view
            viewIndex += 1
        }
        
        controller.contentView.addConstraints(allConstraints)

        /*
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
     */
    }
}
