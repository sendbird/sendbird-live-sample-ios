//
//  LiveEventHeader.swift
//  AudioOnlyLive
//
//  Created by Minhyuk Kim on 2023/08/27.
//

import UIKit
import SendbirdLiveSDK
import SendbirdUIKit

protocol LiveEventHeaderDelegate: AnyObject {
    func didClickReactionButton()
    func didClickHideMessageList()
}

class LiveEventHeader: SBUChannelInfoHeaderView {
    var channelInfoHStack = SBUStackView(axis: .horizontal, alignment: .center, spacing: 17)
    var showReactionButton = true
    
    public lazy var hideMessageListButton: UIButton = {
        let button = UIButton()
        button.addTarget(
            self,
            action: #selector(onClickHideMessageList),
            for: .touchUpInside
        )
        
        button.setImage(UIImage(named: "iconChatShow")?.sbu_with(tintColor: SBUColorSet.ondark01).resize(with: CGSize(width: 24, height: 24)), for: .selected)
        button.setImage(UIImage(named: "iconChatHide")?.sbu_with(tintColor: SBUColorSet.ondark01).resize(with: CGSize(width: 24, height: 24)), for: .normal)
        return button
    }()
    
    public lazy var reactionButton: UIButton = {
        let button = UIButton()
        button.addTarget(
            self,
            action: #selector(onClickReactionButton),
            for: .touchUpInside
        )
        
        button.setImage(UIImage(named: "iconHeart")?.sbu_with(tintColor: SBUColorSet.ondark01).resize(with: CGSize(width: 24, height: 24)), for: .normal)
        
        return button
    }()
    
    weak var liveEventHeaderDelegate: LiveEventHeaderDelegate?
    
    @objc
    open func onClickHideMessageList() {
        self.liveEventHeaderDelegate?.didClickHideMessageList()
        self.hideMessageListButton.isSelected.toggle()
    }
    
    @objc
    open func onClickReactionButton() {
        self.liveEventHeaderDelegate?.didClickReactionButton()
    }
    
    override func setupViews() {
        super.setupViews()
        
        self.addSubview(channelInfoHStack)
        
        channelInfoHStack.setHStack([
            self.hideMessageListButton
        ])
        
        if showReactionButton {
            channelInfoHStack.addArrangedSubview(reactionButton)
        }
    }
    
    override func setupLayouts() {
        super.setupLayouts()
        
        if let infoButton = infoButton {
            NSLayoutConstraint.deactivate(infoButton.constraints)
            infoButton.removeFromSuperview()
            infoButton.sbu_constraint(width: 24, height: 24)
            infoButton.tintColor = SBUColorSet.ondark01
            infoButton.setImage(SBUIconSet.iconInfo.sbu_with(tintColor: SBUColorSet.ondark01), for: .normal)
            self.channelInfoHStack.insertArrangedSubview(infoButton, at: 0)
        }
        
        self.channelInfoHStack
            .sbu_constraint_equalTo(trailingAnchor: self.trailingAnchor, trailing: -14, centerYAnchor: self.centerYAnchor, centerY: 0)
            .sbu_constraint_greater(leadingAnchor: self.titleLabel.trailingAnchor, leading: 16)
            .sbu_constraint(height: 24)

        self.hideMessageListButton
            .sbu_constraint(width: 24,
                            height: 24)
        self.reactionButton
            .sbu_constraint(width: 24,
                            height: 24)
    }
    
    override func setupStyles() {
        super.setupStyles()
        self.coverImage.backgroundColor = SBUColorSet.background300
        self.infoButton?.tintColor = SBUColorSet.ondark01
    }
}
