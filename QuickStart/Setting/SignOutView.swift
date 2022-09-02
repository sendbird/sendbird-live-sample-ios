//
//  UserProfileFooterView.swift
//  QuickStart
//
//  Created by Ernest Hong on 2022/09/30.
//

import UIKit
import SendbirdUIKit

final class SignOutView: UIView {
    
    private let signOutAction: () -> Void
    
    @SBUThemeWrapper(theme: SBUTheme.userProfileTheme)
    private var theme: SBUUserProfileTheme
    
    private lazy var signOutButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTouchSignOut), for: .touchUpInside)
        button.layer.cornerRadius = 4.0
        button.setBackgroundImage(
            UIImage.from(color: self.theme.largeItemBackgroundColor),
            for: .normal
        )
        button.setBackgroundImage(
            UIImage.from(color: self.theme.largeItemHighlightedColor),
            for: .highlighted
        )
        button.setTitle("Sign out", for: [])
        return button
    }()
    
    init(signOutAction: @escaping () -> Void) {
        self.signOutAction = signOutAction
        super.init(frame: .zero)
        
        addSubview(signOutButton)
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signOutButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            signOutButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            signOutButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            signOutButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            signOutButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        signOutButton.tintColor = self.theme.largeItemTintColor
        signOutButton.setTitleColor(self.theme.largeItemTintColor, for: .normal)
        signOutButton.titleLabel?.font = self.theme.largeItemFont
        signOutButton.layer.borderWidth = 1
        signOutButton.layer.borderColor = self.theme.largeItemTintColor.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTouchSignOut() {
        signOutAction()
    }
}
