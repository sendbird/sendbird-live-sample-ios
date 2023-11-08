//
//  HostCollectionViewCell.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2023/10/12.
//

import UIKit
import SendbirdLiveSDK

class HostCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var audioMutedImageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet var profileImageBackgroundView: UIView!
    @IBOutlet var userIdLabelLeadingConstraint: NSLayoutConstraint?

    var liveEvent: LiveEvent!
    var host: Host? {
        didSet {
            guard let host = host else { return }

            updateView(with: host)
            registerVideoView(with: host)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.host = nil
        self.videoView.subviews.forEach { $0.removeFromSuperview() }
    }

    func updateView(with host: Host) {
        userIdLabel.text = "User ID: \(host.userId)"
        audioMutedImageView.isHidden = host.isAudioOn
        profileImageView.isHidden = host.isVideoOn
        profileImageBackgroundView.isHidden = host.isVideoOn
        userIdLabelLeadingConstraint?.isActive = host.isAudioOn
    }

    func registerVideoView(with host: Host) {
        DispatchQueue.main.async { [self] in
            videoView.subviews.forEach { $0.removeFromSuperview() }

            let sendbirdVideoView = SendbirdVideoView(frame: videoView.frame, contentMode: .center)
            sendbirdVideoView.backgroundColor = UIColor(white: 44.0 / 255.0, alpha: 1.0)
            videoView.embed(sendbirdVideoView)

            liveEvent.setVideoViewForLiveEvent(view: sendbirdVideoView, hostId: host.hostId)
        }
    }
}
