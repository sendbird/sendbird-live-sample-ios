//
//  UserProfileIdView.swift
//  QuickStart
//
//  Created by Ernest Hong on 2022/09/30.
//

import UIKit
import SendbirdUIKit

final class UserIdView: SettingLabelView {
    
    func updateUI(user: SBUUser) {
        updateUI(title: SBUStringSet.UserProfile_UserID, description: user.userId)
    }
    
}
