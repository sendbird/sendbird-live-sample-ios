//
//  SignInViewController.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2023/08/21.
//

import UIKit
import SendbirdChatSDK
import SendbirdLiveSDK
import SendbirdUIKit

class SignInViewController: UIViewController {
    @IBOutlet weak var appIdTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var accessTokenTextField: UITextField!

    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var signInButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.userIdTextField.text = UserDefaults.standard.value(forKey: "userId") as? String
        self.accessTokenTextField.text = UserDefaults.standard.value(forKey: "accessToken") as? String
        self.appIdTextField.text = UserDefaults.standard.value(forKey: "applicationId") as? String
        self.versionLabel.text = "SDK v\(SendbirdLive.version)"
    }

    // MARK: - ManualSignInDelegate
    @IBAction func didTapSignIn() {
        guard let appId = self.appIdTextField.text?.collapsed else {
            self.presentErrorAlert(message: "Please enter valid app ID")
            return
        }
        guard let userId = self.userIdTextField.text?.collapsed else {
            self.presentErrorAlert(message: "Please enter valid user ID")
            return
        }
        let accessToken = self.accessTokenTextField.text

        self.signIn(appId: appId, userId: userId, accessToken: accessToken)
    }

    func signIn(appId: String, userId: String, accessToken: String?) {
        SBUGlobals.currentUser = .init(userId: userId)
        SBUGlobals.accessToken = accessToken
        SBUGlobals.applicationId = appId
        
        self.signInButton.isEnabled = false
        
        let logLevel: SendbirdChatSDK.LogLevel = .none
        SendbirdUI.initialize(applicationId: appId,
                              initParamsBuilder: { params in
            params?.isLocalCachingEnabled = false
            params?.needsSynchronous = false
            params?.localCacheConfig = nil
            params?.logLevel = logLevel
        }) { error in
            SendbirdLive.initialize(
                params: .init(applicationId: appId),
                migrationStartHandler: nil) { _ in
                    SendbirdLive.setLogLevel(.verbose)
                    SendbirdLive.executeOn(.main)
                    SendbirdUI.connect { user, error in
                        SendbirdLive.authenticate(
                            userId: userId,
                            accessToken: accessToken
                        ) { result in
                            DispatchQueue.main.async {
                                self.signInButton.isEnabled = true
                                
                                switch result {
                                case .success:
                                    UserDefaults.standard.set(userId, forKey: "userId")
                                    UserDefaults.standard.set(accessToken, forKey: "accessToken")
                                    UserDefaults.standard.set(appId, forKey: "applicationId")
                                    self.performSegue(withIdentifier: "login", sender: nil)
                                    
                                case .failure(let error):
                                    self.presentErrorAlert(message: error.localizedDescription)
                                }
                            }
                        }
                    }
                }
            }
    }
    
    
    
}

// MARK: - UITextFieldDelegate
extension SignInViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            textField.layer.borderWidth = 0.0
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
        textField.resignFirstResponder()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            textField.layer.borderWidth = 1.0
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}
