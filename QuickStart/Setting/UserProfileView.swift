//
//  UserProfileView.swift
//  QuickStart
//
//  Created by Ernest Hong on 2022/09/30.
//

import UIKit
import SendbirdUIKit

final class UserProfileView: UnderLineView {
    
    private enum Constant {
        static let profileImageSize: CGFloat = 80
    }
    
    @SBUThemeWrapper(theme: SBUTheme.userProfileTheme)
    private var theme: SBUUserProfileTheme
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.roundCorners(corners: .allCorners, radius: Constant.profileImageSize / 2)
        imageView.backgroundColor = theme.userPlaceholderBackgroundColor
        return imageView
    }()
    
    private lazy var userNameLabel: UILabel = {
        let userNameLabel = UILabel()
        userNameLabel.textAlignment = .center
        userNameLabel.textColor = theme.usernameTextColor
        userNameLabel.font = theme.usernameFont
        return userNameLabel
    }()
    
    init() {
        super.init(frame: .zero)
                
        addSubview(profileImageView)
        addSubview(userNameLabel)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: Constant.profileImageSize),
            profileImageView.heightAnchor.constraint(equalToConstant: Constant.profileImageSize),
        ])
        
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            userNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            userNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            userNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(user: SBUUser) {
        profileImageView.loadImage(urlString: user.profileURL ?? "", placeholder: UIImage(named: "iconUser"))
        userNameLabel.text = user.refinedNickname()
    }
    
}
