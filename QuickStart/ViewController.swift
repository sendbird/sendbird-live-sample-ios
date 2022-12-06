//
//  ViewController.swift
//  QuickStart
//
//  Created by Minhyuk Kim on 2022/08/29.
//

import UIKit
import SendbirdUIKit
import SendbirdLiveUIKit
import SendbirdLiveSDK

class ViewController: UIViewController {
    @IBOutlet var uikitVersionLabel: UILabel!
    @IBOutlet var sdkVersionLabel: UILabel!
    @IBOutlet var applicationIdTextField: UITextField!
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var accessTokenTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uikitVersionLabel.text = "Live v1.0.0"
        sdkVersionLabel.text = "SDK v\(SendbirdLive.version)"
        
        self.userIdTextField.text = UserDefaults.standard.value(forKey: "userId") as? String
        self.accessTokenTextField.text = UserDefaults.standard.value(forKey: "accessToken") as? String
        self.applicationIdTextField.text = UserDefaults.standard.value(forKey: "applicationId") as? String
    }
    
    @IBAction func didTapSignInButton(_ sender: Any) {
        guard let applicationId = applicationIdTextField.text else { return }
        guard let userId = userIdTextField.text else { return }
        let accessToken = accessTokenTextField.text
        
        SendbirdLiveUI.initialize(applicationId: applicationId, startHandler: nil, migrationHandler: nil) { error in
            guard error == nil else { return }
            
            SBUGlobals.currentUser = SBUUser(userId: userId)
            SBUGlobals.accessToken = accessToken
            
            UserDefaults.standard.set(userId, forKey: "userId")
            UserDefaults.standard.set(accessToken, forKey: "accessToken")
            UserDefaults.standard.set(applicationId, forKey: "applicationId")
            DispatchQueue.main.async {
                self.presentMainVC()
            }
        }
    }
    
    private func presentMainVC() {
        let tabBar = MainTabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        present(tabBar, animated: false)
    }
}


extension UITextField {
    @IBInspectable
    var isPaddingEnabled: Bool {
        get {
            guard let paddingView = leftView else { return false }
            return paddingView.frame.width != 0
        }
        set {
            guard newValue else { return }
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: frame.height))
            leftView = paddingView
            leftViewMode = .always
            rightView = paddingView
            rightViewMode = .always
        }
    }
}

extension ViewController: UITextFieldDelegate {
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            textField.layer.borderWidth = 0.0
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
        textField.resignFirstResponder()
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(red: 116/255, green: 45/255, blue: 221/255, alpha: 1.0).cgColor
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            
            textField.layer.borderWidth = 1.0
            
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField.text != nil && textField.text?.isEmpty == false else {
            return false
        }

        textField.resignFirstResponder()
        return true
    }
}
