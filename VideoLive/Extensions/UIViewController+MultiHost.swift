//
//  UIViewController+MultiHost.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2023/09/05.
//

import UIKit
import SendbirdLiveSDK

extension UIViewController {
    static var topViewController: UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        } else {
            return nil
        }
    }

    func presentErrorAlert(message: String, closeHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let actionDone = UIAlertAction(title: "Done", style: .cancel, handler: closeHandler)
        alert.addAction(actionDone)
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIView {
    func embed(_ videoView: SendbirdVideoView) {
        insertSubview(videoView, at: 0)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[view]|",
                options: [],
                metrics: nil,
                views: ["view": videoView]
            )
        )
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[view]|",
                options: [],
                metrics: nil,
                views: ["view": videoView]
            )
        )

        layoutIfNeeded()
    }
}
