//
//  SettingsViewController.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2023/08/21.
//

import UIKit
import SendbirdUIKit
import SendbirdLiveSDK
import SendbirdChatSDK

class SettingsViewController: UIViewController {
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nicknameLabel: UILabel!
    @IBOutlet var userIdLabel: UILabel!
    @IBOutlet var appIdLabel: UILabel!

    @IBOutlet var signOutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let currentUser = SendbirdChat.getCurrentUser()

        if let profileURL = currentUser?.profileURL, !profileURL.isEmpty {
            profileImageView.loadImage(urlString: profileURL)
        }
        self.nicknameLabel.text = currentUser?.nickname.collapsed ?? "No nickname"
        self.userIdLabel.text = currentUser?.userId ?? " - "
        self.appIdLabel.text = SendbirdLive.applicationId

        self.signOutButton.layer.borderWidth = 1
        self.signOutButton.layer.borderColor = UIColor.black.cgColor
        self.signOutButton.layer.cornerRadius = 4
    }

    @IBAction func didTouchSignOut() {
        SendbirdLive.deauthenticate {
            SendbirdUI.disconnect { [weak self] in
                DispatchQueue.main.async {
                    UserDefaults.standard.removeObject(forKey: "userId")
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                    UserDefaults.standard.removeObject(forKey: "applicationId")

                    self?.dismiss(animated: true)
                }
            }
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
}
