//
//  SBLEmptyView.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2023/09/05.
//

import UIKit
import SendbirdUIKit

class SBLEmptyView: SBUEmptyView {
    override func updateViews() {
        super.updateViews()

        switch self.type {
        case .noChannels:
            self.statusLabel.text = "No Live Events"
        default: break
        }
    }
}
