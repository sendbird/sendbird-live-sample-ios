//
//  LiveEventViewController.swift
//  SendbirdLiveUIKit
//
//  Created by Minhyuk Kim on 2022/09/07.
//

import UIKit
import SendbirdUIKit
import SendbirdLiveSDK
import SendbirdChatSDK

open class LiveEventViewController: SBUOpenChannelViewController, LiveEventDelegate, LiveEventHeaderDelegate {
    // MARK: - UI Components
    public lazy var streamView: SendbirdVideoView = {
        let videoView = SendbirdVideoView(frame: self.view.layoutMarginsGuide.layoutFrame)
        videoView.videoContentMode = .scaleAspectFill
        videoView.backgroundColor = SBUColorSet.background600
        return videoView
    }()
    
    public lazy var closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(
            self,
            action: #selector(onClickClose),
            for: .touchUpInside
        )
        return button
    }()
    
    var liveEventStatusView = UIView()
    var hostImageView = UIImageView()
    var liveEventStatusLabel = UILabel()
    
    var reactionView = UIView()
    lazy var reactionAnimator = {
        ReactionAnimator(view: self.reactionView)
    }()
    
    var headerComponentConstraint: NSLayoutConstraint?
    var bottomMarginView = UIView()
    
    var liveEventMediaComponent: LiveEventMediaComponent? { (mediaComponent as? HostLiveEventMediaComponent) ?? mediaComponent as? LiveEventMediaComponent }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - State Properties
    
    public var liveEvent: LiveEvent!
    
    var isMediaComponentHidden = false
        
    var isMessageListHidden: Bool = false {
        didSet { self.hideMessageList(hidden: isMessageListHidden) }
    }
    
    let activeIndicatorSize: CGFloat = 10
    var prevNewMessageInfoViewHidden: Bool = true
    
    var hideMessageListButtonConstraint: NSLayoutConstraint?
    
    var screenRatio: Double = 0.3
    
    var lastReactionCount: [String: Int] = [:]
    // MARK: - Initializers
    public required init(channel: OpenChannel, liveEvent: LiveEvent) {
        super.init(channel: channel, messageListParams: nil)
        self.liveEvent = liveEvent
        
        self.liveEvent.addDelegate(self, forKey: self.description)
        self.liveEvent.setConnectionQualityDelegate(self)
        self.theme = .dark
        
        self.mediaComponent = LiveEventMediaComponent()
        
        let header = LiveEventHeader(delegate: self.headerComponent)
        header.liveEventHeaderDelegate = self
        self.headerComponent?.channelInfoView = header
        channel.getAllMetaCounters { metaData, error in
            self.lastReactionCount = metaData ?? [:]
        }
        self.hideChannelInfoView = false
        self.enableMediaView()
        
        self.mediaViewIgnoringSafeArea(false)
        self.updateMessageListRatio(to: 1 - screenRatio)
    }
    
    public required init(channel: OpenChannel, messageListParams: MessageListParams? = nil) {
        fatalError("init(channel:messageListParams:) has not been implemented")
    }
    
    public required init(channelURL: String, startingPoint: Int64 = .max, messageListParams: MessageListParams? = nil) {
        fatalError("init(channelURL:startingPoint:messageListParams:) has not been implemented")
    }
    
    public required init(channelURL: String, messageListParams: MessageListParams? = nil) {
        fatalError("init(channelURL:messageListParams:) has not been implemented")
    }
    
    public required init(channelURL: String, startingPoint: Int64? = nil, messageListParams: MessageListParams? = nil) {
        fatalError("init(channelURL:startingPoint:messageListParams:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    open override func loadView() {
        /// `setupAutolayout` and `setupStyles` will be called in `super.loadView()
        /// Please add sub views before `super.loadView()`
        super.loadView()
        
        liveEventMediaComponent?.configure(delegate: self, dataSource: self, theme: self.theme)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        self.theme = .dark

        self.configure()
        
//        if let hostId = liveEvent.host?.hostId {
//            liveEvent.setVideoViewForLiveEvent(view: streamView, hostId: hostId)
//        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClickMediaView(_:)))
        self.liveEventMediaComponent?.overlayStackView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onKeyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onKeyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func onKeyboardWillShow() {
        self.listComponent?.setScrollBottomView(hidden: true)
    }
    
    @objc func onKeyboardWillHide() {
        self.listComponent?.setScrollBottomView(hidden: self.listComponent?.isScrollNearByBottom == true)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.isHidden = true
        
        if self.currentOrientation != UIDevice.current.orientation {
            NotificationCenter.default.post(name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    open override func setupViews() {
        super.setupViews()
        
        self.view.addSubview(self.closeButton)
        self.view.addSubview(self.reactionView)
        reactionView.isUserInteractionEnabled = false
        self.view.addSubview(self.bottomMarginView)
        
        liveEventStatusView.addSubview(hostImageView)
        liveEventStatusView.addSubview(liveEventStatusLabel)
        
//        self.mediaComponent?.mediaView.insertSubview(streamView, at: 0)
        self.mediaComponent?.mediaView.insertSubview(liveEventStatusView, at: 1)
        
    }
    
    // MARK: - Styles & Layout
    // This method will be called inside of `super.loadView`
    open override func setupLayouts() {
        let isLandscape = self.currentOrientation.isLandscape
        self.mediaViewIgnoringSafeArea(isLandscape)
        self.updateMessageListRatio(to: 1 - screenRatio)
//        self.overlayMediaView(true, messageListRatio: 0.46)
        
        super.setupLayouts()
                
        if let mediaView = self.mediaComponent?.mediaView {
//            streamView
//                .sbu_constraint(widthAnchor: mediaView.widthAnchor, width: 0)//, heightAnchor: mediaView.heightAnchor, height: 0)
        }
        
        self.liveEventStatusView
            .sbu_constraint(equalTo: self.view, leading: 0, trailing: 0, top: 0, bottom: 0)
        self.hostImageView
            .sbu_constraint(equalTo: self.liveEventStatusView, centerX: 0, centerY: 0)
            .sbu_constraint(width: 80, height: 80)
        self.liveEventStatusLabel
            .sbu_constraint_equalTo(topAnchor: hostImageView.bottomAnchor, top: 8, centerXAnchor: hostImageView.centerXAnchor, centerX: 0)
            .sbu_constraint(height: 21)
        
        self.reactionView
            .sbu_constraint_equalTo(trailingAnchor: self.view.trailingAnchor, trailing: 0, topAnchor: self.view.topAnchor, top: 16, bottomAnchor: headerComponent!.topAnchor, bottom: 16)
            .sbu_constraint(width: 48)
        
//        let overlayViewHeightConstraint = liveEventMediaComponent?.bottomAnchor.constraint(equalTo: headerComponent!.topAnchor)
//        overlayViewHeightConstraint?.isActive = true
//        liveEventMediaComponent?.overlayViewHeightConstraint = overlayViewHeightConstraint
         
        let headerComponentConstraint = self.headerComponent?.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor)
        headerComponentConstraint?.isActive = false
        self.headerComponentConstraint = headerComponentConstraint
        
        self.weakHeaderComponentBottomConstraint.priority = .init(1000)
        weakHeaderComponentBottomConstraint.isActive = true
        (self.listComponent?.channelStateBanner)?.constraints.forEach { $0.isActive = false }
        self.listComponent?.channelStateBanner?
            .sbu_constraint(equalTo: self.view, leading: 8, trailing: -8)
            .sbu_constraint_equalTo(topAnchor: self.view.layoutMarginsGuide.topAnchor, top: 44)
            .sbu_constraint(height: 24)
        
        self.bottomMarginView.sbu_constraint_equalTo(leadingAnchor: self.view.leadingAnchor, leading: 0, trailingAnchor: self.view.trailingAnchor, trailing: 0, topAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, top: 0, bottomAnchor: self.view.bottomAnchor, bottom: 0)
        self.setupLiveInfo()
    }
    
    
    // When it received event of the device orientation,
    // `updateAutolayout` and `updateStyles` methods will be called.
    open override func updateLayouts() {
        let isLandscape = self.currentOrientation.isLandscape
        self.mediaViewIgnoringSafeArea(isLandscape)
        
        if self.currentOrientation != .portraitUpsideDown {
            self.updateMessageListRatio(to: 1 - screenRatio)
//            self.overlayMediaView(true, messageListRatio: 0.46)
            super.updateLayouts()
        }
        
        self.setupLiveInfo()
    }
    
    // This method will be called inside of `super.loadView`
    open override func setupStyles() {
        super.setupStyles()

        self.view.backgroundColor = SBUColorSet.background500
        
        self.closeButton.setImage(
            SBUIconSet.iconClose
                .sbu_with(tintColor: SBUColorSet.ondark01),
            for: .normal
        )
        self.closeButton.isEnabled = true
        
        self.liveEventStatusView.backgroundColor = SBUColorSet.background600
        self.liveEventStatusLabel.textColor = SBUColorSet.ondark01
        self.liveEventStatusLabel.font = SBUFontSet.h1
        
        self.hostImageView.layer.cornerRadius = 40
        self.hostImageView.clipsToBounds = true
        self.hostImageView.contentMode = .scaleAspectFill
        
        self.bottomMarginView.backgroundColor = SBUColorSet.background500
        
        (self.inputComponent?.messageInputView as? SBUMessageInputView)?.textView?.textColor = SBUColorSet.ondark01
    }
    
    // MARK: - Methods
    open func setupLiveInfo() {
        // Top left corner
        self.closeButton
            .sbu_constraint_equalTo(leadingAnchor: self.view.leadingAnchor,
                            leading: 14,
                                    topAnchor: self.view.layoutMarginsGuide.topAnchor,
                            top: 10)
            .sbu_constraint(width: 24,
                            height: 24)
    }
    
    open func configure() {
        if let host = liveEvent.host {
            if let profileURL = host.profileURL, !profileURL.isEmpty {
                hostImageView.loadImage(urlString: profileURL)
            } else {
                hostImageView.image = SBUIconSet.iconUser.resize(with: CGSize(width: 27, height: 27)).sbu_with(tintColor: SBUColorSet.onlight01)
                hostImageView.backgroundColor = SBUColorSet.background200
            }
            
            liveEventStatusLabel.text = host.nickname ?? "Host"
            liveEventStatusView.isHidden = true
        }
        
        if let headerView = (headerComponent?.channelInfoView as? SBUChannelInfoHeaderView) {
            self.channelDescription = liveEvent.host == nil ? "—" : liveEvent.host?.nickname?.trimmed.collapsed ?? "Host"
            headerView.titleLabel.text = liveEvent.title?.trimmed.collapsed ?? "Live Event"
//            headerView.descriptionLabel.text = self.channelDescription
            
            if let coverURL = self.liveEvent.coverURL {
                headerView.coverImage.setImage(with: coverURL)
                headerView.coverImage.contentMode = .scaleAspectFill
            } else {
                headerView.coverImage.setImage(withImage: SBUIconSet.iconUser.resize(with: CGSize(width: 27, height: 27)).sbu_with(tintColor: SBUColorSet.onlight01))
                headerView.coverImage.contentMode = .center
            }
        }
        
        liveEventMediaComponent?.configure(liveEvent: liveEvent)
    }
    
    func updateCenterImageView(image: UIImage, text: String) {
        liveEventStatusLabel.text = text
    }
    
    // MARK: - OpenChannelSettings
    open override func showParticipantsList() {
        guard let channel = liveEvent.openChannel else { return }
        self.navigationController?.navigationBar.isHidden = false

        let participantListVC = SBUViewControllerSet.OpenUserListViewController.init(channel: channel, userListType: .participants)
        participantListVC.theme = .dark
        participantListVC.componentTheme = .dark
        
        let usercell = SBLUserCell()
        usercell.theme = .dark
        participantListVC.listComponent?.register(userCell: usercell)
        
        self.navigationController?.pushViewController(participantListVC, animated: true)
    }
    
    open override func showChannelSettings() {
        self.navigationController?.navigationBar.isHidden = false
        
        if liveEvent.isActiveHost {
            let channelSettingsVC = LiveEventSettingsViewController(liveEvent: liveEvent)
            self.navigationController?.pushViewController(channelSettingsVC, animated: true)
        } else {
            self.showParticipantsList()
        }
    }
    
    // MARK: - Actions
    /// Called when a user clicks the exit button. By default, host is given a choice to end or leave without ending the live event while a participant is prompted to leave the live event.
    @objc
    open func onClickClose() {
        DispatchQueue.main.async {
            if let controller = self.navigationController {
                controller.popToRootViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    open override func baseChannelViewModel(_ viewModel: SBUBaseChannelViewModel, shouldDismissForChannel channel: BaseChannel?) {
        super.baseChannelViewModel(viewModel, shouldDismissForChannel: channel)
    }
    
    func didClickHideMessageList() {
        self.isMessageListHidden.toggle()
    }
    
    
    func didClickReactionButton() {
        liveEvent.increaseReactionCount(key: "LIKE") { result in
        }
    }
    
    // MARK: - Gesture actions
    @objc
    open func onClickMediaView(_ sender: UITapGestureRecognizer? = nil) {
        if let messageInputView = self.inputComponent?.messageInputView as? SBUMessageInputView,
           messageInputView.textView?.isFirstResponder == false {
            isMediaComponentHidden.toggle()
            
            liveEventMediaComponent?.toggleTranslucent(isHidden: isMediaComponentHidden)
            self.closeButton.isHidden = isMediaComponentHidden
        } else {
            self.dismissKeyboard()
        }
    }
    
    public func mirrorLocalVideoView(isEnabled: Bool) {
        switch isEnabled {
        case true: streamView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        case false: streamView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    public func hideMessageList(hidden: Bool) {
        guard self.isMediaViewEnabled else { return }
        
        let ratio = (56+self.view.layoutMargins.bottom) / self.view.frame.height
        self.updateMessageListRatio(to: hidden ? ratio : 1 - screenRatio)
        
        super.updateLayouts()
        
        liveEventMediaComponent?.enableOverlayViewConstraint(hidden)
        
        self.listComponent?.isHidden = hidden
        self.inputComponent?.isHidden = hidden
        
        self.headerComponentConstraint?.isActive = hidden
//        self.weakHeaderComponentBottomConstraint.isActive = !hidden
        
        if hidden {
            self.prevNewMessageInfoViewHidden = self.listComponent?.newMessageInfoView?.isHidden ?? true
        }
        self.listComponent?.newMessageInfoView?.isHidden = hidden
            ? true :
            self.prevNewMessageInfoViewHidden
        
        self.hideMessageListButtonConstraint?.isActive = hidden
    }
    
    // MARK: - ViewModel Delegate
    open override func baseChannelViewModel(_ viewModel: SBUBaseChannelViewModel,
                                       didChangeChannel channel: BaseChannel?,
                                       withContext context: MessageContext) {
        super.baseChannelViewModel(viewModel, didChangeChannel: channel, withContext: context)
       
        if context.source == .eventChannelChanged {
            self.configure()
        }
    }
    
    // MARK: - Navigation controller
    override open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // MARK: - Live Event Delegate
    public func didHostMuteAudioInput(_ liveEvent: LiveEvent, host: Host) {
        liveEventMediaComponent?.configure(liveEvent: liveEvent)
    }
    
    public func didHostUnmuteAudioInput(_ liveEvent: LiveEvent, host: Host) {
        liveEventMediaComponent?.configure(liveEvent: liveEvent)
    }
    
    public func didHostStartVideo(_ liveEvent: LiveEvent, host: Host) {
        liveEventStatusView.isHidden = true
        liveEventMediaComponent?.configure(liveEvent: liveEvent)
    }
    
    public func didHostStopVideo(_ liveEvent: LiveEvent, host: Host) {
        liveEventStatusView.isHidden = false
        liveEventMediaComponent?.configure(liveEvent: liveEvent)
    }
    
    public func didHostEnter(_ liveEvent: LiveEvent, host: Host) {
        liveEvent.setVideoViewForLiveEvent(view: streamView, hostId: host.hostId)
        self.configure()
    }
    
    public func didHostExit(_ liveEvent: LiveEvent, host: Host) {
        liveEventStatusView.isHidden = true
        self.configure()
    }
    
    public func didHostConnect(_ liveEvent: LiveEvent, host: Host) {
        liveEvent.setVideoViewForLiveEvent(view: streamView, hostId: host.hostId)
        self.configure()
    }
    
    public func didHostDisconnect(_ liveEvent: LiveEvent, host: Host) {
        liveEventStatusView.isHidden = true
        self.configure()
    }
    public func didParticipantCountChange(_ liveEvent: LiveEvent, participantCountInfo: ParticipantCountInfo) {
        liveEventMediaComponent?.configure(liveEvent: liveEvent)
    }
    
    public func didLiveEventReady(_ liveEvent: LiveEvent) {
        self.configure()
    }
    
    public func didLiveEventStart(_ liveEvent: LiveEvent) {
        self.configure()
        if let host = liveEvent.host {
            liveEvent.setVideoViewForLiveEvent(view: streamView, hostId: host.hostId)
        }
    }
    
    public func didLiveEventEnd(_ liveEvent: LiveEvent) {
        liveEventMediaComponent?.configure(liveEvent: liveEvent)
        liveEventStatusView.isHidden = false
        
        if let coverURL = liveEvent.coverURL, !coverURL.isEmpty {
            hostImageView.contentMode = .scaleAspectFill
            hostImageView.loadImage(urlString: coverURL)
        } else {
            hostImageView.contentMode = .center
            hostImageView.image = UIImage(named: "icon-user")?.resize(with: .init(width: 32, height: 32)).sbu_with(tintColor: SBUColorSet.background50)
            hostImageView.backgroundColor = SBUColorSet.background300
        }
        liveEventStatusLabel.text = "Live event has ended."
        
        self.hideMessageList(hidden: true)
        self.liveEventMediaComponent?.toggleTranslucent(isHidden: true)
    }
    
    public func didDisconnect(_ liveEvent: LiveEvent, error: Error) {
        SBUAlertView.show(
            title: "Disconnected",
            message: "Try entering the live event again.",
            confirmButtonItem: .init(title: SBUStringSet.OK, completionHandler: { info in
                DispatchQueue.main.async {
                    if let controller = self.navigationController {
                        controller.popToRootViewController(animated: true)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }),
            cancelButtonItem: nil
        )
    }
    
    open func didLiveEventInfoUpdate(_ liveEvent: LiveEvent) {
        self.configure()
    }
    
    open func didUpdateCustomItems(_ liveEvent: LiveEvent, customItems: [String : String], updatedKeys: [String]) {
        
    }
    
    open func didDeleteCustomItems(_ liveEvent: LiveEvent, customItems: [String : String], deletedKeys: [String]) {
        
    }
    
    enum ReactionColors: CaseIterable {
        static var random: UIColor {
            (allCases.randomElement() ?? .red).rawValue
        }
        
        case red
        case orange
        case blue
        case green
        case yellow
        case purple
        case violet
        
        var rawValue: UIColor {
            switch self {
            case .red:
                return UIColor(red: 0.984, green: 0.42, blue: 0.42, alpha: 1)
            case .orange:
                return UIColor(red: 1, green: 0.671, blue: 0.322, alpha: 1)
            case .blue:
                return UIColor(red: 0.475, green: 0.635, blue: 0.949, alpha: 1)
            case .green:
                return UIColor(red: 0.475, green: 0.82, blue: 0.635, alpha: 1)
            case .yellow:
                return UIColor(red: 1, green: 0.761, blue: 0.2, alpha: 1)
            case .purple:
                return UIColor(red: 0.557, green: 0.392, blue: 0.98, alpha: 1)
            case .violet:
                return UIColor(red: 0.647, green: 0.22, blue: 0.843, alpha: 1)
            }
        }
    }
    
    open func didReactionCountUpdate(_ liveEvent: LiveEvent, key: String, value: Int) {
        guard let image = UIImage(named: "LIKE") else { return }
        guard value > lastReactionCount[key, default: 0] else { return }

        let newReactionCount = value - lastReactionCount[key, default: 0]
        lastReactionCount[key] = value

        let options = ReactionAnimationOptions(
            initialPosition: CGPoint(x: self.reactionView.frame.width / 2, y: self.reactionView.frame.height),
            randomXOffet: self.reactionView.frame.width / 4,
            superviewSize: .init(width: self.reactionView.frame.width, height: self.reactionView.frame.height * 0.6),
            duration: 4,
            size: CGSize(width: 22.9, height: 20.23),
            image: image,
            colorSet: ReactionColors.allCases.map { $0.rawValue }
        )
        reactionAnimator.animate(count: newReactionCount, options: options)
    }
}

extension LiveEventViewController: LiveStreamChannelModuleMediaDataSource {
    public func liveStreamChannelModule(_ mediaComponent: SBUOpenChannelModule.Media, liveEventForMediaView mediaView: UIView) -> LiveEvent? {
        return liveEvent
    }
}

extension LiveEventViewController: ConnectionQualityDelegate {
    public func didConnectionQualityUpdate(hostId: String, metrics: ConnectionMetrics) {
        print("Connection Quality: \(hostId), rtt: \(metrics.rtt), jitter: \(metrics.jitter), PLR: \(metrics.packetLostRate), bandwidth: \(metrics.bandwidth), available: \(metrics.availableBitrate),")
    }
}
