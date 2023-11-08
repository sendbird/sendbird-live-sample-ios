//
//  UIButton+MultiHost.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2023/09/05.
//

import UIKit

extension UIButton {
    func setContentInset(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
        if #available(iOS 15.0, *) {
            self.configuration = self.configuration ?? .plain()
            self.configuration?.contentInsets = NSDirectionalEdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
        } else {
            self.contentEdgeInsets = UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
        }
    }
}
