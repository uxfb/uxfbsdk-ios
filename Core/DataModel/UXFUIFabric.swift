//
//  UXFUIFabric.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 19.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

class UXFUIFabric{
    static let sharedInstance = UXFUIFabric.init()
    
    func parseUIElement(dictionary: Dictionary<String, Any>)->(UIView?){
        
        if let type = dictionary["type"] as? String{
            switch type {
            case "button":
                return createButton(dictionary: dictionary)
            case "header":
                return createUIHeader(dictionary: dictionary)
            case "text":
                return createUIText(dictionary: dictionary)
            case "checkboxes":
                return createUICheckbox(dictionary: dictionary)
            default:
                return nil
            }
        }
        
       return nil
    }
    
    private func createButton(dictionary: Dictionary<String, Any>)->(UXFButton){
        let button = UXFButton.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 33))
        button.titleLabel?.text = dictionary["value"] as? String
        return button
    }
    
    private func createUICheckbox(dictionary: Dictionary<String, Any>)->(UIView){
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 33))
        let switchView = UISwitch.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: view.bounds.size.height))
        view.addSubview(switchView)
        #warning("title not implemented")
        return view
    }
    
    private func createUIHeader(dictionary: Dictionary<String, Any>)->(UILabel){
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 33))
        label.text = dictionary["value"] as? String
        label.sizeToFit()
        return label
    }
    
    private func createUIText(dictionary: Dictionary<String, Any>)->(UILabel){
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 33))
        label.text = dictionary["value"] as? String
        label.sizeToFit()
        return label
    }
}
