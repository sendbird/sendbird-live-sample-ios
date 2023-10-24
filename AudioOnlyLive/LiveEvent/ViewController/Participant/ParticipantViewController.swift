//
//  ParticipantViewController.swift
//  SendbirdLiveUIKit
//
//  Created by Minhyuk Kim on 2022/09/07.
//

import UIKit
import SendbirdUIKit
import SendbirdLiveSDK

public class ParticipantViewController: LiveEventViewController {
    // MARK: - OpenChannelSettings
    open override func showParticipantsList() {
        self.navigationController?.navigationBar.isHidden = false
        super.showParticipantsList()
    }
    
    public override func setupStyles() {
        super.setupStyles()
    }
    // MARK: - Actions
    @objc
    open override func onClickClose() {
        liveEvent.exit { error in
            DispatchQueue.main.async {
                if let error = error { }
                
                super.onClickClose()
            }
        }
    }

    open override func configure() {
        super.configure()
        
        updateBannerText()
        
        let iconImage = SBUIconSet.iconMembers.sbu_with(tintColor: SBUColorSet.ondark01).resize(with: CGSize(width: 24, height: 24))
        (self.headerComponent?.channelInfoView as? SBUChannelInfoHeaderView)?.infoButton?.setImage(iconImage.sbu_with(tintColor: SBUColorSet.ondark01), for: .normal)
    }
    
    open func updateBannerText() {
        var text: String?
        
        switch liveEvent.state {
        case .created, .ready:
            text = "Ready"
        case .ongoing:
            if let host = liveEvent.host {
                text = host.isAudioOn ? nil : "Host is muted."
            } else {
                text = "Host is temporarily unavailable."
            }
        case .ended: break
        @unknown default: break
        }
        
        (self.listComponent?.channelStateBanner as? UILabel)?.text = text
        self.listComponent?.channelStateBanner?.isHidden = text == nil
    }
    
    // MARK: - LiveEventDelegate
    open override func didHostMuteAudioInput(_ liveEvent: LiveEvent, host: Host) {
        super.didHostMuteAudioInput(liveEvent, host: host)
        updateBannerText()
    }
    
    open override func didHostUnmuteAudioInput(_ liveEvent: LiveEvent, host: Host) {
        super.didHostUnmuteAudioInput(liveEvent, host: host)
        updateBannerText()
    }
    
    open override func didHostEnter(_ liveEvent: LiveEvent, host: Host) {
        super.didHostEnter(liveEvent, host: host)
        updateBannerText()
    }
        
    open override func didHostExit(_ liveEvent: LiveEvent, host: Host) {
        super.didHostExit(liveEvent, host: host)
        updateBannerText()
    }
    
    open override func didHostConnect(_ liveEvent: LiveEvent, host: Host) {
        super.didHostConnect(liveEvent, host: host)
        updateBannerText()
    }
    
    open override func didHostDisconnect(_ liveEvent: LiveEvent, host: Host) {
        super.didHostDisconnect(liveEvent, host: host)
        updateBannerText()
    }
    
    public override func didLiveEventEnd(_ liveEvent: LiveEvent) {
        super.didLiveEventEnd(liveEvent)
        updateBannerText()
    }
    
    public override func didLiveEventReady(_ liveEvent: LiveEvent) {
        super.didLiveEventReady(liveEvent)
        updateBannerText()
    }
    
    public override func didLiveEventStart(_ liveEvent: LiveEvent) {
        super.didLiveEventStart(liveEvent)
        updateBannerText()
    }
}
