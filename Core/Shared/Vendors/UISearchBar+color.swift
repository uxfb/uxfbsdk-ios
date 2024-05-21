//
//  UISearchBar+color.swift
//  Portal DA mobile
//
//  Created by Dmitry Kudryavtsev on 19/09/2018.
//  Copyright © 2018 ABK. All rights reserved.
//

import UIKit

// as UISearchBar extension
extension UISearchBar {
    func changeSearchBarColor(color: UIColor, textColor: UIColor) {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = textColor 
        textFieldInsideSearchBar?.backgroundColor = color
    }
}
