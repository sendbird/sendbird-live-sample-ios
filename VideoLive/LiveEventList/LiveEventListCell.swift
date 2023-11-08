//
//  LiveEventListCell.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2023/09/04.
//

import UIKit
import SendbirdLiveSDK
import SendbirdUIKit

class LiveEventListCell: UITableViewCell {

    @IBOutlet var coverImage: UIImageView!

    @IBOutlet var liveEventLabel: UILabel!

    @IBOutlet var statusLabel: PaddingLabel!

    @IBOutlet var participantCountLabel: UILabel!

    public func configure(liveEvent: LiveEvent) {
        if let coverURL = liveEvent.coverURL, !coverURL.isEmpty {
            self.coverImage.loadImage(urlString: coverURL) { success in
                DispatchQueue.main.async {
                    if !success {
                        self.coverImage.image = UIImage(named: "icon-user")?.resize(with: .init(width: 32, height: 32)).sbu_with(tintColor: SBUColorSet.background50)
                        self.coverImage.contentMode = .center
                    }
                }
            }
            self.coverImage.contentMode = .scaleAspectFill
            self.coverImage.backgroundColor = .black
        } else {
            self.coverImage.image = UIImage(named: "icon-user")?.resize(with: .init(width: 32, height: 32)).sbu_with(tintColor: SBUColorSet.background50)
            self.coverImage.backgroundColor = SBUColorSet.background300
            self.coverImage.contentMode = .center
        }

        // Title
        self.liveEventLabel.text = liveEvent.title?.trimmed.collapsed ?? "Live Event"

        let isLive = [LiveEvent.State.ready, .ongoing].contains(liveEvent.state)
        self.participantCountLabel.text = isLive ? "\(liveEvent.participantCount) watching" : nil

        switch liveEvent.state {
        case .created:
            statusLabel.backgroundColor = SBUColorSet.primary100
            statusLabel.textColor = SBUColorSet.primary400
            self.statusLabel.text = "UPCOMING"
        case .ready:
            statusLabel.backgroundColor = UIColor(red: 200/255, green: 217/255, blue: 250/255, alpha: 1.0)
            statusLabel.textColor = UIColor(red: 48/255, green: 48/255, blue: 143/255, alpha: 1.0)
            self.statusLabel.text = "OPEN"
        case .ongoing:
            statusLabel.backgroundColor = SBUColorSet.error300
            statusLabel.textColor = SBUColorSet.background50
            self.statusLabel.text = "LIVE"
        case .ended:
            statusLabel.backgroundColor = SBUColorSet.background200
            statusLabel.textColor = SBUColorSet.onlight02
            self.statusLabel.text = "ENDED"
        @unknown default: break
        }
    }
}
