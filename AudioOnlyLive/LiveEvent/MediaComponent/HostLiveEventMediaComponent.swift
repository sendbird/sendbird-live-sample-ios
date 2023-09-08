//
//  HostLiveEventMediaComponent.swift
//  SendbirdLiveUIKit
//
//  Created by Minhyuk Kim on 2022/09/22.
//

import UIKit
import SendbirdUIKit
import SendbirdLiveSDK
import AVKit

protocol HostMediaDelegate: LiveMediaDelegate {
    func hostMediaComponent(
        _ mediaComponent: HostLiveEventMediaComponent,
        didTapDeviceSelectButton button: UIButton
    )
    
    func hostMediaComponent(
        _ mediaComponent: HostLiveEventMediaComponent,
        didTapMicToggleButton button: UIButton
    )
}

class HostLiveEventMediaComponent: LiveEventMediaComponent, AVRoutePickerViewDelegate {
    // MARK: - UI Components (Layouts)
    var mediaControlVStack = SBUStackView(axis: .horizontal, alignment: .center, spacing: 16)
    
    // MARK: - UI Components (Controls)
    lazy var deviceSelectButton: UIButton = {
       let button = UIButton()

        button.setImage(SBUIconSet.iconMore.sbu_with(tintColor: SBUColorSet.ondark01), for: .normal)

        let routePickerView = AVRoutePickerView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        routePickerView.activeTintColor = .clear
        routePickerView.tintColor = .clear
        routePickerView.delegate = self

        button.addSubview(routePickerView)

        return button
    }()
    
    lazy var micToggleButton: UIButton = {
       let button = UIButton()
        
        let micOffImage = UIImage(named: "iconMicOff")?.sbu_with(tintColor: SBUColorSet.ondark01)
        let micOnImage = UIImage(named: "iconMic")?.sbu_with(tintColor: SBUColorSet.ondark01)
        
        button.setImage(micOnImage, for: .normal)
        button.setImage(micOffImage, for: .selected)
        
        button.addTarget(self, action: #selector(didTapMicToggleButton(_:)), for: .touchUpInside)
        return button
    }()

    // MARK: - Sendbird UIKit Life cycle
    override func setupViews() {
        super.setupViews()
        
        topStackView.setVStack([
            deviceSelectButton,
            micToggleButton,
            mediaControlVStack
        ])
    }
    
    override func setupLayouts() {
        super.setupLayouts()
        
        topStackView.alignment = .trailing
        topStackView.spacing = 24
        
        deviceSelectButton.sbu_constraint(width: 24, height: 24)
        micToggleButton.sbu_constraint(width: 24, height: 24)
    }
    
    override func configure(liveEvent: LiveEvent) {
        super.configure(liveEvent: liveEvent)
        
        if liveEvent.state == .created || liveEvent.state == .ready {
            statusButton.isHidden = false
            statusButton.isEnabled = true
            statusButton.setTitle("Start", for: .normal)
            statusButton.backgroundColor = SBUColorSet.ondark01
        }
    }
    
    // MARK: - Actions
    @objc func didTapMicToggleButton(_ sender: UIButton) {
        (self.delegate as? HostMediaDelegate)?.hostMediaComponent(self, didTapMicToggleButton: sender)
    }
}
