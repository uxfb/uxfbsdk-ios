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
    static let toggleReservedWidth: CGFloat = 63

    static func height(for title: String, width: CGFloat, font: UIFont) -> CGFloat {
        guard width > 0 else { return height }
        return max(height, ceil(title.height(withConstrainedWidth: width, font: font)))
    }

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

        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        toggle.setContentCompressionResistancePriority(.required, for: .horizontal)
        toggle.setContentHuggingPriority(.required, for: .horizontal)

        let heightConstraint = heightAnchor.constraint(equalToConstant: NoAnswerView.height)
        heightConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            heightConstraint,
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: toggle.leadingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            bottomAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: trailingAnchor),
            toggle.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
    }

    func configure(title: String, theme: ThemeProtocol?, isOn: Bool) {
        titleLabel.text = title
        titleLabel.font = theme?.fontP2
        titleLabel.textColor = theme?.text03Color
        toggle.onTintColor = theme?.btnBgColor
        toggle.setOn(isOn, animated: false)
    }

    func setOn(_ isOn: Bool) {
        toggle.setOn(isOn, animated: true)
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
        guard var field = field else { return }
        field.answers = isOn ? [NoAnswerView.noAnswerValue] : []
        self.field = field
        delegate?.fieldChanged(field, answer: field.answers, refresh: true)
    }

    internal func syncScaleAnswer(_ value: String, noAnswerView: NoAnswerView) {
        field?.answers = [value]
        noAnswerView.setOn(false)
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
