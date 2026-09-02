//
//  UXFBaseCell.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 11.11.2020.
//  Copyright © 2020 UXF. All rights reserved.
//

import UIKit

internal class NoAnswerView: UIView {
    static let noAnswerValue = "-1"
    static let height: CGFloat = 31
    static let topSpacing: CGFloat = 16

    var onToggle: ((Bool) -> Void)?

    private let titleLabel = UILabel()
    private let toggle = UISwitch()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(titleLabel)
        addSubview(toggle)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggle.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            toggle.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            toggle.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            toggle.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
    }

    func configure(title: String, theme: ThemeProtocol?, isOn: Bool) {
        titleLabel.text = title
        titleLabel.font = theme?.fontP2
        titleLabel.textColor = theme?.text03Color
        toggle.onTintColor = theme?.mainColor
        toggle.setOn(isOn, animated: false)
    }

    @objc private func toggleChanged() {
        onToggle?(toggle.isOn)
    }
}

internal class BaseCell: UITableViewCell {
    internal var delegate: FieldDelegate?
    internal var field: Field?
    internal var theme: ThemeProtocol?

    internal var noAnswerName: String? {
        guard let name = field?.noAnswerName, !name.isEmpty else {
            return nil
        }
        return name
    }

    internal var isNoAnswerSelected: Bool {
        return noAnswerName != nil && field?.answers.first == NoAnswerView.noAnswerValue
    }

    internal func noAnswerToggled(_ isOn: Bool) {
        guard let field = field else { return }
        delegate?.fieldChanged(field, answer: isOn ? [NoAnswerView.noAnswerValue] : [], refresh: true)
    }
    
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
    
    override func layoutSubviews() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        super.layoutSubviews()
        CATransaction.commit()
    }
}
