//
//  UnderLineView.swift
//  QuickStart
//
//  Created by Ernest Hong on 2022/09/30.
//

import UIKit
import SendbirdUIKit

class UnderLineView: UIView {
    
    @SBUThemeWrapper(theme: SBUTheme.userProfileTheme)
    private var theme: SBUUserProfileTheme

    private lazy var separatorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        separatorView.backgroundColor = theme.separatorColor
        
        addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
