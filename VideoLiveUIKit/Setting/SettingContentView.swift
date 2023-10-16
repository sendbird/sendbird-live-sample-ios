//
//  SettingContentView.swift
//  QuickStart
//
//  Created by Ernest Hong on 2022/09/29.
//

import UIKit
import SendbirdUIKit

final class SettingContentView: UIView {
    
    // MARK: - Property
    
    private let signOutAction: () -> Void
    
    private let appInfoAction: () -> Void
    
    private var user: SBUUser?
    
    @SBUThemeWrapper(theme: SBUTheme.userProfileTheme)
    private var theme: SBUUserProfileTheme
    
    private lazy var vStack: UIStackView = {
        let vStack = UIStackView()
        vStack.axis = .vertical
        return vStack
    }()
    
    private lazy var profileView = UserProfileView()
    
    private lazy var userIdView = UserIdView()
    
    private lazy var appInfoButton = SettingActionButton(didTouchAction: { [weak self] in
        self?.appInfoAction()
    })
    
    private lazy var signOutView = SignOutView(signOutAction: { [weak self] in
        self?.signOutAction()
    })
    
    // MARK: - View Lifecycle
    
    init(signOutAction: @escaping () -> Void, appInfoAction: @escaping () -> Void) {
        self.signOutAction = signOutAction
        self.appInfoAction = appInfoAction
        super.init(frame: .zero)
        self.setupViews()
        self.setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(vStack)
        vStack.addArrangedSubview(profileView)
        vStack.addArrangedSubview(userIdView)
        vStack.addArrangedSubview(appInfoButton)
        vStack.addArrangedSubview(signOutView)
    }
    
    private func setupLayouts() {
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: topAnchor),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func updateUI(user: SBUUser) {
        self.user = user
        profileView.updateUI(user: user)
        userIdView.updateUI(user: user)
    }
}
