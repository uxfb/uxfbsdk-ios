//
//  UXFRadioCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 12.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

class RadioCell: UITableViewCell {
    
    private lazy var symbolExtView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        return view
    }()
    private lazy var symbolMidView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var symbolIntView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        return view
    }()
    private lazy var dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        return view
    }()
    private lazy var radioLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private lazy var radioView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var theme: ThemeProtocol?
    private var option: Option?
    private var isError: Bool = false
    
    private func setupSubviews() {
        backgroundColor = .clear
        symbolIntView.addSubview(dotView)
        symbolMidView.addSubview(symbolIntView)
        symbolExtView.addSubview(symbolMidView)
        radioView.addSubview(symbolExtView)
        radioView.addSubview(radioLabel)
        contentView.addSubview(radioView)
        
        symbolIntView.translatesAutoresizingMaskIntoConstraints = false
        symbolMidView.translatesAutoresizingMaskIntoConstraints = false
        symbolExtView.translatesAutoresizingMaskIntoConstraints = false
        radioLabel.translatesAutoresizingMaskIntoConstraints = false
        radioView.translatesAutoresizingMaskIntoConstraints = false
        dotView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            radioView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            radioView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            radioView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            radioView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            symbolExtView.centerYAnchor.constraint(equalTo: radioView.centerYAnchor),
            symbolExtView.leadingAnchor.constraint(equalTo: radioView.leadingAnchor, constant: 8),
            symbolExtView.heightAnchor.constraint(equalToConstant: 24),
            symbolExtView.widthAnchor.constraint(equalToConstant: 24),
            
            radioLabel.centerYAnchor.constraint(equalTo: radioView.centerYAnchor),
            radioLabel.leadingAnchor.constraint(equalTo: symbolExtView.trailingAnchor, constant: 8),
            radioLabel.trailingAnchor.constraint(equalTo: radioView.trailingAnchor, constant: -4),
            radioLabel.topAnchor.constraint(equalTo: radioView.topAnchor, constant: 4),
            radioLabel.bottomAnchor.constraint(equalTo: radioView.bottomAnchor, constant: -4),
            
            symbolMidView.topAnchor.constraint(equalTo: symbolExtView.topAnchor, constant: 4),
            symbolMidView.bottomAnchor.constraint(equalTo: symbolExtView.bottomAnchor, constant: -4),
            symbolMidView.leadingAnchor.constraint(equalTo: symbolExtView.leadingAnchor, constant: 4),
            symbolMidView.trailingAnchor.constraint(equalTo: symbolExtView.trailingAnchor, constant: -4),
            
            symbolIntView.topAnchor.constraint(equalTo: symbolMidView.topAnchor, constant: 2),
            symbolIntView.bottomAnchor.constraint(equalTo: symbolMidView.bottomAnchor, constant: -2),
            symbolIntView.leadingAnchor.constraint(equalTo: symbolMidView.leadingAnchor, constant: 2),
            symbolIntView.trailingAnchor.constraint(equalTo: symbolMidView.trailingAnchor, constant: -2),
            
            dotView.topAnchor.constraint(equalTo: symbolIntView.topAnchor, constant: 2),
            dotView.bottomAnchor.constraint(equalTo: symbolIntView.bottomAnchor, constant: -2),
            dotView.leadingAnchor.constraint(equalTo: symbolIntView.leadingAnchor, constant: 2),
            dotView.trailingAnchor.constraint(equalTo: symbolIntView.trailingAnchor, constant: -2),
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
        self.radioLabel.font = theme.fontP1
        updateUI()
    }
    
    private func updateUI() {        
        radioView.layer.cornerRadius = theme?.btnBorderRadius ?? 4
        radioView.layer.masksToBounds = true
        
        radioView.borderWidth = isError ? 2 : 1
        radioView.borderColor = isError ? theme?.errorColorSecondary : theme?.inputBorderColor
        
        UIView.animate(withDuration: 0.2) {
            self.radioLabel.text = self.option?.value
            if self.isSelected {
                self.radioLabel.textColor = self.theme?.text01Color
                
                self.symbolExtView.backgroundColor = .clear
//                self.symbolExtView.backgroundColor = self.theme?.mainColor.withAlphaComponent(0.2)
                self.symbolMidView.backgroundColor = self.theme?.mainColor
                self.symbolIntView.backgroundColor = self.theme?.mainColor
                
                self.radioView.backgroundColor = self.theme?.controlBgColorActive
                self.dotView.backgroundColor = self.theme?.controlIconColor
            }
            else {
                self.radioLabel.textColor = self.theme?.text02Color
                self.symbolExtView.backgroundColor = .clear
                self.symbolMidView.backgroundColor = self.theme?.iconColor
                self.symbolIntView.backgroundColor = self.theme?.bgColor ?? .white
                self.radioView.backgroundColor = .clear //self.theme?.controlBgColor
                self.dotView.backgroundColor = .clear
            }
        }
    }
    
}
