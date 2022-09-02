//
//  SettingLabelView.swift
//  QuickStart
//
//  Created by Ernest Hong on 2022/09/30.
//

import UIKit
import SendbirdUIKit

class SettingLabelView: UnderLineView {
    
    @SBUThemeWrapper(theme: SBUTheme.userProfileTheme)
    var theme: SBUUserProfileTheme
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
        ])
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
        
        titleLabel.font = theme.informationTitleFont
        titleLabel.textColor = theme.informationTitleColor
        descriptionLabel.font = theme.informationDesctiptionFont
        descriptionLabel.textColor = theme.informationDesctiptionColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(title: String?, description: String?) {
        titleLabel.text = title
        descriptionLabel.text = description
    }
    
}
