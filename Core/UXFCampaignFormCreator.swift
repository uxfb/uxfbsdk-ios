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

        var allConstraints: [NSLayoutConstraint] = []
        var viewIndex = 0
        var contentHeight: CGFloat = (controller.progressLabel?.frame.size.height ?? 0.0) + (controller.progressLabel?.frame.origin.y ?? 0.0)
        if let filedsInfoArr = page.uiData["fields"] as? Array<Dictionary<String, Any>> {
            
            var allviews: Dictionary <String, UIView> = ["topView": controller.progressLabel!]
            var fieldViews: Dictionary <String, UIView> = [:]
            for fieldInfo in  filedsInfoArr{
                
                if let filedView = UXFParser.sharedInstance.parseUIElement(dictionary: fieldInfo,
                                                        submitHandler: {(info) in
                    controller.nextHandler?(controller.formIndex, info)
                }){
                    controller.contentView.addSubview(filedView)
                    filedView.translatesAutoresizingMaskIntoConstraints = false
                    allviews["view\(viewIndex)"] = filedView
                    fieldViews["view\(viewIndex)"] = filedView
                    allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view\(viewIndex)]-|",
                                                                     metrics: nil,
                                                                     views: ["view\(viewIndex)": filedView])
                    viewIndex += 1
                    contentHeight += filedView.frame.size.height + 8.0
                }
            }
            var layoutFormat = "V:|-[topView]-"
            for viewName in fieldViews.keys.sorted(){
                layoutFormat += "[" + viewName + "]-"
            }
            layoutFormat += "|"
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: layoutFormat,
                                                             metrics: nil,
                                                             views: allviews as [String : Any])
        }
        controller.heightConstraint?.constant = contentHeight
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
