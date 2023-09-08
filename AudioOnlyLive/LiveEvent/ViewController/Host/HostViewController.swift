//
//  HostViewController.swift
//  SendbirdLiveUIKit
//
//  Created by Minhyuk Kim on 2022/09/07.
//

import UIKit
import SendbirdUIKit
import SendbirdLiveSDK
import SendbirdChatSDK
import AVKit

open class HostViewController: LiveEventViewController {
    // MARK: - Initializers
    required public init(channel: OpenChannel, liveEvent: LiveEvent) {
        super.init(channel: channel, liveEvent: liveEvent)
        
        self.mediaComponent = HostLiveEventMediaComponent()
    }
    
    @available(*, unavailable, renamed: "init(channel:liveEvent:)")
    required public init(channel: OpenChannel, messageListParams: MessageListParams? = nil) {
        fatalError("init(channel:messageListParams:) has not been implemented")
    }
    
    @available(*, unavailable, renamed: "init(channel:liveEvent:)")
    required public init(channelURL: String, startingPoint: Int64 = .max, messageListParams: MessageListParams? = nil) {
        fatalError("init(channelURL:startingPoint:messageListParams:) has not been implemented")
    }
    
    @available(*, unavailable, renamed: "init(channel:liveEvent:)")
    required public init(channelURL: String, messageListParams: MessageListParams? = nil) {
        fatalError("init(channelURL:messageListParams:) has not been implemented")
    }
    
    @available(*, unavailable, renamed: "init(channel:liveEvent:)")
    required public init(channelURL: String, startingPoint: Int64? = nil, messageListParams: MessageListParams? = nil) {
        fatalError("init(channelURL:startingPoint:messageListParams:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        PermissionManager.shared.requestDeviceAccessIfNeeded(for: .audio) { audioAccess in
            if !audioAccess {
                PermissionManager.shared.showMicAccessPermissionAlert()
            }
        }
    }
    
    // MARK: - Actions
    open override func onClickClose() {
        SBUAlertView.show(
            title: "Are you sure you want to end the live?",
            confirmButtonItem: .init(title: "End Live", color: SBUColorSet.error200, completionHandler: { _ in
                self.liveEvent.endEvent { error in
                    if let error = error { return }
                    let summaryVC = LiveEventSummaryViewController(liveEvent: self.liveEvent)
                    self.navigationController?.pushViewController(summaryVC, animated: false)
                }
            }),
            cancelButtonItem: .init(title: "Cancel", color: SBUColorSet.primary200, completionHandler: { _ in })
        )
    }
}

// MARK: - HostMediaDelegate
extension HostViewController: HostMediaDelegate {
    func hostMediaComponent(_ mediaComponent: HostLiveEventMediaComponent, didTapDeviceSelectButton button: UIButton) {
        
    }
    
    func hostMediaComponent(_ mediaComponent: HostLiveEventMediaComponent, didTapFlipCameraButton button: UIButton) {
        button.isSelected.toggle()

        liveEvent.switchCamera() { _ in
            self.mirrorLocalVideoView(isEnabled: button.isSelected)
        }
    }
    
    func hostMediaComponent(_ mediaComponent: HostLiveEventMediaComponent, didTapMicToggleButton button: UIButton) {
        let isMuted = button.isSelected
        button.isSelected.toggle()
        
        if isMuted {
            liveEvent.unmuteAudioInput { error in
                guard error == nil else {
                    return
                }
            }
        } else {
            liveEvent.muteAudioInput { error in
                guard error == nil else {
                    return
                }
            }
        }
    }
    
    func hostMediaComponent(_ mediaComponent: HostLiveEventMediaComponent, didTapVideoToggleButton button: UIButton) {
        let isEnabled = button.isSelected
        button.isSelected.toggle()
        
        if isEnabled {
            liveEvent.startVideo { error in
                guard error == nil else {
                    return
                }
            }
        } else {
            liveEvent.stopVideo { error in
                guard error == nil else {
                    return
                }
            }
        }
    }
    
    func liveMediaComponent(_ mediaComponent: LiveEventMediaComponent, didTapStatusButton: UIButton) {
        liveEvent?.startEvent(mediaOptions: nil) { error in
            guard error == nil else { return }

            DispatchQueue.main.async {
                self.configure()
            }
        }
    }
}
