//
//  UXFBaseCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

internal class BaseCell: UITableViewCell {
    internal var delegate: FieldDelegate?
    internal var field: Field?
    internal var theme: ThemeProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSubviews()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal func configureWith(_ value: Field, theme: ThemeProtocol, delegate: FieldDelegate, valueIndex: Int = 0) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rotated),
                                               name: NSNotification.Name("Rotated"),
                                               object: nil)
        
        self.field = value
        self.theme = theme
        self.delegate = delegate
        updateUI()
    }
    
    internal func setupSubviews() { }
    
    internal func updateUI() { }
    
    @objc internal func rotated() { }
}
