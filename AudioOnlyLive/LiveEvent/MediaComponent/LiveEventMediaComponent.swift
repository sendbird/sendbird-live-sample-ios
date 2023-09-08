//
//  LiveEventMediaComponent.swift
//  SendbirdLiveUIKit
//
//  Created by Minhyuk Kim on 2022/09/19.
//

import UIKit
import SendbirdUIKit
import SendbirdLiveSDK

protocol LiveStreamChannelModuleMediaDataSource: AnyObject {
    func liveStreamChannelModule(
        _ mediaComponent: SBUOpenChannelModule.Media,
        liveEventForMediaView mediaView: UIView
    ) -> LiveEvent?
}

protocol LiveMediaDelegate: SBUOpenChannelModuleMediaDelegate {
    func liveMediaComponent(
        _ mediaComponent: LiveEventMediaComponent,
        didTapStatusButton: UIButton
    )
}

class LiveEventMediaComponent: SBUOpenChannelModule.Media {
    // MARK: - UI Components (Layouts)
    lazy var overlayStackView: SBUStackView = {
        let stackView = SBUStackView(axis: .vertical, spacing: 0)
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    var topStackView = SBUStackView(axis: .horizontal, alignment: .fill, spacing: 8)
    var bottomStackView = SBUStackView(axis: .horizontal, alignment: .center, spacing: 4)
    
    // MARK: - UI Components (Views)
    lazy var activeIndicator = UIView()
    lazy var liveLabel = UILabel()
    lazy var participantCountLabel = UILabel()
    
    lazy var liveBackground: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "liveBackground")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage()
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    lazy var statusButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapStatusButton(_:)), for: .touchUpInside)
        button.setTitleColor(SBUColorSet.onlight01, for: .normal)
        button.setTitleColor(SBUColorSet.ondark01, for: .disabled)
        button.setTitle("--:--", for: .normal)
        button.isEnabled = false
        button.layer.cornerRadius = 4
        
        return button
    }()
    
    // MARK: Delegate & Data Source
    weak var dataSource: LiveStreamChannelModuleMediaDataSource?

    var liveEvent: LiveEvent? {
        self.dataSource?
            .liveStreamChannelModule(self, liveEventForMediaView: self.mediaView)
    }
    
    // MARK: - State properties
    var durationTimer: Timer?
    var overlayViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Sendbird UIKit Life cycle
    override func setupViews() {
        super.setupViews()
        
        self.insertSubview(liveBackground, at: 0)
        self.addSubview(coverImageView)
//        mediaView.addSubview(self.translucentView)
        mediaView.addSubview(
            overlayStackView.setVStack([
                topStackView,
                UIView(), // Spacer
                bottomStackView.setHStack([
                    self.activeIndicator,
                    self.liveLabel,
                    self.participantCountLabel,
                    UIView() // Spacer
                ])
            ])
        )
        mediaView.addSubview(self.statusButton)
        
        self.backgroundColor = .white
        
        bottomStackView.setCustomSpacing(8, after: self.liveLabel)
    }
    
    override func setupLayouts() {
        super.setupLayouts()
        
        self.overlayStackView
            .sbu_constraint(equalTo: mediaView, leading: 0, trailing: 0, top: 0, bottom: 0)
        
        self.liveBackground
            .sbu_constraint(equalTo: mediaView, top: 0, bottom: 0)
        self.liveBackground.sbu_constraint(equalTo: self, centerX: 0)
        
        self.coverImageView.sbu_constraint(equalTo: self, centerX: 0, centerY: 0)
        self.coverImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.3).isActive = true
        self.coverImageView.widthAnchor.constraint(equalTo: self.coverImageView.heightAnchor, multiplier: 1).isActive = true
        
        self.activeIndicator
            .sbu_constraint(width: 10, height: 10)
        self.liveLabel
            .sbu_constraint(height: 16)
        self.participantCountLabel
            .sbu_constraint(height: 16)
        
        self.statusButton
            .sbu_constraint_equalTo(topAnchor: mediaView.topAnchor, top: 6, centerXAnchor: mediaView.centerXAnchor, centerX: 0)
            .sbu_constraint(height: 32)
    }
    
    override func setupStyles(theme: SBUChannelTheme? = nil) {
        self.backgroundColor = .black
        
        self.activeIndicator.backgroundColor = .red
        self.activeIndicator.layer.cornerRadius = 10 / 2
        self.activeIndicator.clipsToBounds = true
        
        self.liveLabel.font = SBUFontSet.body3
        self.liveLabel.textColor = SBUColorSet.ondark01
        
        self.participantCountLabel.font = SBUFontSet.body2
        self.participantCountLabel.textColor = SBUColorSet.ondark01
        
        self.statusButton.setContentInset(top: 8, leading: 12, bottom: 8, trailing: 12)
    }
    
    func configure(
        delegate: SBUOpenChannelModuleMediaDelegate,
        dataSource: LiveStreamChannelModuleMediaDataSource,
        theme: SBUChannelTheme
    ) {
        super.configure(delegate: delegate, theme: theme)
        
        self.delegate = delegate
        self.dataSource = dataSource
        self.theme = theme
        
        self.setupViews()
        self.setupLayouts()
        self.setupStyles(theme: theme)
        
        guard let liveEvent = liveEvent else { return }
        self.configure(liveEvent: liveEvent)
    }
    
    func configure(liveEvent: LiveEvent) {
        self.liveLabel.text = liveEvent.state.sbu_asString
        
        self.activeIndicator.backgroundColor = liveEvent.state == .ongoing ? .red : .gray
        
        self.statusButton.backgroundColor = SBUColorSet.error300
        self.statusButton.isEnabled = false
        
        self.participantCountLabel.text = "\(liveEvent.participantCount) participants"
        
        self.statusButton.isHidden = [.created, .ready].contains(liveEvent.state)
        
        if liveEvent.state == .ongoing {
            startDurationTimer()
        }
        
        if let coverURL = liveEvent.coverURL, !coverURL.isEmpty {
            self.coverImageView.loadImage(urlString: coverURL) { success in
                if !success {
                    self.coverImageView.image = UIImage(named: "icon-user")?.resize(with: .init(width: 32, height: 32)).sbu_with(tintColor: SBUColorSet.background50)
                    self.coverImageView.contentMode = .center
                }
            }
            self.coverImageView.contentMode = .scaleAspectFill
            self.coverImageView.backgroundColor = .gray
        } else {
            self.coverImageView.image = UIImage(named: "icon-user")?.resize(with: .init(width: 32, height: 32)).sbu_with(tintColor: SBUColorSet.background50)
            self.coverImageView.contentMode = .center
        }
        self.coverImageView.clipsToBounds = true
        
        self.coverImageView.layer.cornerRadius = self.coverImageView.frame.width / 2
        
        self.updateStatusButton()
    }
    
    // MARK: - Functions
    func enableOverlayViewConstraint(_ isEnabled: Bool) {
        DispatchQueue.main.async {
            self.overlayStackView.layoutSubviews()
            self.coverImageView.layer.cornerRadius = self.coverImageView.frame.width / 2
        }
    }
    
    func startDurationTimer() {
        guard self.durationTimer == nil else { return }
        self.statusButton.setTitle("00:00", for: .normal)
        self.durationTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.updateStatusButton),
            userInfo: nil,
            repeats: true
        )
    }
    
    func stopDurationTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
    }
    
    @objc func updateStatusButton() {
        guard let liveEvent = liveEvent else { return }
        
        switch liveEvent.state {
        case .created, .ready:
            break
        case .ongoing:
            statusButton.setTitle(liveEvent.duration.durationText(), for: .normal)
            liveBackground.isHidden = false
        case .ended:
            statusButton.setTitle((liveEvent.endedAt! - liveEvent.startedAt!).durationText(), for: .normal)
            coverImageView.isHidden = true
        @unknown default:
            break
        }
    }
    
    func toggleTranslucent(isHidden: Bool) {
        self.topStackView.isHidden = isHidden
        self.bottomStackView.isHidden = isHidden
        
        if isHidden {
            self.statusButton.isHidden = true
        } else if let liveEvent = liveEvent {
            if liveEvent.isActiveHost, [.created, .ready].contains(liveEvent.state) {
                self.statusButton.isHidden = false
            }
            if ![.created, .ready].contains(liveEvent.state) {
                self.statusButton.isHidden = false
            }
        }
    }
    
    // MARK: - Actions
    @objc func didTapStatusButton(_ sender: UIButton) {
        (self.delegate as? LiveMediaDelegate)?.liveMediaComponent(self, didTapStatusButton: sender)
    }
}
extension LiveEvent.State {
    var sbu_asString: String {
        switch self {
        case .created:
            return "OPEN"
        case .ready:
            return "OPEN"
        case .ongoing:
            return "LIVE"
        case .ended:
            return "ENDED"
        @unknown default:
            return ""
        }
    }
}
