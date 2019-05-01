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
        
        var allConstraints: [NSLayoutConstraint] = []
        for view in page.fields{
            controller.contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            
            let views = ["view": view, "topView": topView]
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[view]-15-|", metrics: nil, views: views as [String : Any])
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[topView]-15-[view(\(view.frame.size.height))]", metrics: nil, views: views as [String : Any])
            topView = view
        }
        
         NSLayoutConstraint.activate(allConstraints)
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
