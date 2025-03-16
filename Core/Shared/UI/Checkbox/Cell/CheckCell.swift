//
//  UXFCheckCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 12.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class CheckCell: UITableViewCell {
    private lazy var symbolExtView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        return view
    }()
    private lazy var symbolMidView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        return view
    }()
    
    private lazy var symbolIntView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var checkLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private lazy var checkView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private var theme: ThemeProtocol?
    private var option: Option?
    private var isError: Bool = false
    
    private func setupSubviews() {
        backgroundColor = .clear
        symbolMidView.addSubview(symbolIntView)
        symbolExtView.addSubview(symbolMidView)
        checkView.addSubview(symbolExtView)
        checkView.addSubview(checkLabel)
        contentView.addSubview(checkView)
        
        symbolIntView.translatesAutoresizingMaskIntoConstraints = false
        symbolMidView.translatesAutoresizingMaskIntoConstraints = false
        symbolExtView.translatesAutoresizingMaskIntoConstraints = false
        checkLabel.translatesAutoresizingMaskIntoConstraints = false
        checkView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            checkView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            checkView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            checkView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            symbolExtView.centerYAnchor.constraint(equalTo: checkView.centerYAnchor),
            symbolExtView.leadingAnchor.constraint(equalTo: checkView.leadingAnchor, constant: 8),
            symbolExtView.heightAnchor.constraint(equalToConstant: 24),
            symbolExtView.widthAnchor.constraint(equalToConstant: 24),
            
            checkLabel.centerYAnchor.constraint(equalTo: checkView.centerYAnchor),
            checkLabel.leadingAnchor.constraint(equalTo: symbolExtView.trailingAnchor, constant: 8),
            checkLabel.topAnchor.constraint(equalTo: checkView.topAnchor, constant: 4),
            checkLabel.bottomAnchor.constraint(equalTo: checkView.bottomAnchor, constant: -4),
            
            symbolMidView.topAnchor.constraint(equalTo: symbolExtView.topAnchor, constant: 4),
            symbolMidView.bottomAnchor.constraint(equalTo: symbolExtView.bottomAnchor, constant: -4),
            symbolMidView.leadingAnchor.constraint(equalTo: symbolExtView.leadingAnchor, constant: 4),
            symbolMidView.trailingAnchor.constraint(equalTo: symbolExtView.trailingAnchor, constant: -4),
            
            symbolIntView.topAnchor.constraint(equalTo: symbolMidView.topAnchor, constant: 2),
            symbolIntView.bottomAnchor.constraint(equalTo: symbolMidView.bottomAnchor, constant: -2),
            symbolIntView.leadingAnchor.constraint(equalTo: symbolMidView.leadingAnchor, constant: 2),
            symbolIntView.trailingAnchor.constraint(equalTo: symbolMidView.trailingAnchor, constant: -2),
        ])
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
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
        self.updateUI()
    }
    
    func configure(option: Option, theme: ThemeProtocol, isError: Bool) {
        self.option = option
        self.theme = theme
        self.isError = isError
        self.checkLabel.font = theme.fontP1
        updateUI()
    }
    
    private func updateUI() {
        checkView.layer.cornerRadius = theme?.btnBorderRadius ?? 4
        checkView.layer.masksToBounds = true
        
        checkView.borderWidth = 2
        checkView.borderColor = isError ? theme?.errorColorSecondary : UIColor.clear
        
        UIView.animate(withDuration: 0.2) {
            self.checkLabel.text = self.option?.value
            if self.isSelected {
                self.checkLabel.textColor = self.theme?.text01Color
                
                self.symbolExtView.backgroundColor = self.theme?.mainColor.withAlphaComponent(0.2)
                self.symbolMidView.backgroundColor = self.theme?.mainColor
                self.symbolIntView.tintColor = self.theme?.controlIconColor
                
                self.symbolIntView.image = UIImage(named: "check_symbol",
                                                   in: Consts.bundle,
                                                   compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                self.symbolIntView.backgroundColor = .clear
                
                self.checkView.backgroundColor = self.theme?.controlBgColorActive
            }
            else {
                self.checkLabel.textColor = self.theme?.text02Color
                self.symbolExtView.backgroundColor = .clear
                self.symbolMidView.backgroundColor = self.theme?.iconColor
                self.symbolIntView.image = nil
                self.symbolIntView.backgroundColor = self.theme?.controlBgColor
                self.checkView.backgroundColor = self.theme?.controlBgColor
            }
        }
        
    }
    
}
