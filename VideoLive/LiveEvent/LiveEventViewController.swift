//
//  LiveEventViewController.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2023/09/26.
//

import UIKit
import SendbirdLiveSDK
import SendbirdUIKit
import AVKit

class LiveEventViewController: UIViewController {
    var liveEvent: LiveEvent!

    @IBOutlet var mediaControlView: UIView!

    @objc func toggleTranslucent(gesture: UITapGestureRecognizer) {
        mediaControlView.isHidden.toggle()
    }

    @IBAction func startLiveEvent(_ sender: Any) {
        liveEvent.startEvent(mediaOptions: nil) { _ in
            self.startDurationTimer()
        }
    }

    @IBOutlet var audioDeviceButton: UIButton!
    @IBOutlet var cameraFlipButton: UIButton!
    @IBOutlet var micButton: UIButton!
    @IBOutlet var cameraButton: UIButton!

    @IBOutlet var collectionView: UICollectionView!

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var coverImageView: UIImageView!

    @IBOutlet var participantCountLabel: UIButton!

    @IBOutlet var hostLabel: UILabel!

    @IBAction func flipCamera(_ sender: Any) {
        liveEvent.switchCamera()
    }

    @IBAction func toggleMic(_ sender: UIButton) {
        guard liveEvent.isActiveHost,
              let hostId = liveEvent.currentLiveUser?.userIdentifier else { return }

        sender.isSelected.toggle()

        if sender.isSelected {
            liveEvent.muteAudioInput { _ in
                self.updateHostCell(for: hostId)
            }
            sender.setImage(UIImage(named: "icon-audio-off"), for: .normal)
        } else {
            liveEvent.unmuteAudioInput { _ in
                self.updateHostCell(for: hostId)
            }
            sender.setImage(UIImage(named: "icon-audio-on"), for: .normal)
        }
    }

    @IBAction func toggleVideo(_ sender: UIButton) {
        guard liveEvent.isActiveHost,
              let hostId = liveEvent.currentLiveUser?.userIdentifier else { return }

        sender.isSelected.toggle()

        if sender.isSelected {
            liveEvent.stopVideo { _ in
                self.updateHostCell(for: hostId)
            }
            sender.setImage(UIImage(named: "icon-video-off"), for: .normal)
        } else {
            liveEvent.startVideo { _ in
                self.updateHostCell(for: hostId)
            }
            sender.setImage(UIImage(named: "icon-video-on"), for: .normal)
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.isHidden = true

    }

    func updateLiveEventInfo() {
        if let coverURL = liveEvent.coverURL {
            coverImageView.loadImage(urlString: coverURL)
            coverImageView.contentMode = .scaleAspectFill
        } else {
            coverImageView.image = SBUIconSet.iconUser.resize(with: CGSize(width: 20, height: 20)).sbu_with(tintColor: SBUColorSet.onlight01)
            coverImageView.contentMode = .center
        }
        titleLabel.text = liveEvent.title ?? "Live Event"
        hostLabel.text = Array(liveEvent.hosts.map(\.userId)).joined(separator: ", ")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        liveEvent.addDelegate(self, forKey: "LiveEventViewController")
        
        collectionView.register(UINib(nibName: "HostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "host")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if !liveEvent.isActiveHost {
            audioDeviceButton.isHidden = true
            cameraFlipButton.isHidden = true
            micButton.isHidden = true
            cameraButton.isHidden = true
        }
        
        let routePickerView = AVRoutePickerView(frame: CGRect(x: 0, y: 0, width: audioDeviceButton.frame.width, height: audioDeviceButton.frame.height))
        routePickerView.delegate = self
        routePickerView.activeTintColor = .clear
        routePickerView.tintColor = .clear
        audioDeviceButton.addSubview(routePickerView)
        
        if liveEvent.state == .ongoing {
            startDurationTimer()
        } else {
            updateStatusButton()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleTranslucent))
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
        
        updateLiveEventInfo()
    }

    @IBOutlet var statusButton: UIButton!

    @IBAction func exit(_ sender: Any) {
        if liveEvent.isActiveHost {

            let items: [SBUActionSheetItem] = [
                SBUActionSheetItem(
                    title: "End live event",
                    color: SBUColorSet.error200,
                    textAlignment: .center,
                    completionHandler: {
                        self.liveEvent.endEvent { error in
                            guard error == nil else { return }
                            let summaryVC = LiveEventSummaryViewController(liveEvent: self.liveEvent)
                            self.navigationController?.pushViewController(summaryVC, animated: false)
                        }
                    }
                ),
                SBUActionSheetItem(
                    title: "Exit without ending",
                    textAlignment: .center,
                    completionHandler: {
                        self.liveEvent.exitAsHost { _ in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                )
            ]

            let cancelItem = SBUActionSheetItem(
                title: SBUStringSet.Cancel,
                color: SBUColorSet.primary200,
                textAlignment: .center,
                completionHandler: nil
            )

            self.view.endEditing(true)
            SBUActionSheet.show(
                items: items,
                cancelItem: cancelItem,
                oneTimetheme: .dark
            )
        } else {
            liveEvent.exit { _ in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    var durationTimer: Timer?
    func startDurationTimer() {
        guard self.durationTimer == nil else { return }

        self.statusButton.isEnabled = false
        self.statusButton.setTitleColor(.white, for: .normal)
        self.statusButton.backgroundColor = .red
        self.statusButton.setTitle("00:00:00", for: .normal)
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
            if !liveEvent.isActiveHost {
                statusButton.setTitle("00:00", for: .normal)
                statusButton.isEnabled = false
            }
            break
        case .ongoing:
            statusButton.setTitle(liveEvent.duration.durationText(), for: .normal)
        case .ended:
            statusButton.setTitle((liveEvent.endedAt! - liveEvent.startedAt!).durationText(), for: .normal)
            coverImageView.isHidden = true
        @unknown default:
            break
        }
    }
    @IBAction func onClickReaction(_ sender: Any) {
        guard let liveEvent = liveEvent else { return }
        
        liveEvent.increaseReactionCount(key: "LIKE") { result in
            debugPrint("\(#function) - [Live reaction] increaseReactionCount result: \(result)")
        }
    }
}

extension LiveEventViewController: LiveEventDelegate {
    func updateHostCell(for hostId: String) {
        guard let index = liveEvent.hosts.firstIndex(where: { $0.hostId == hostId }) else { return }
        UIView.performWithoutAnimation {
            let cell = collectionView.cellForItem(at: .init(row: index, section: 0)) as? HostCollectionViewCell
            cell?.updateView(with: liveEvent.hosts[index])
        }
    }

    func didHostMuteAudioInput(_ liveEvent: SendbirdLiveSDK.LiveEvent, host: SendbirdLiveSDK.Host) {
        updateHostCell(for: host.hostId)
    }
    func didHostVideoResolutionChange(_ liveEvent: LiveEvent, host: Host, resolution: Resolution) {
        print("Host changed: \(host.userId) and \(resolution.width) and \(resolution.height)")
    }

    func didHostUnmuteAudioInput(_ liveEvent: SendbirdLiveSDK.LiveEvent, host: SendbirdLiveSDK.Host) {
        updateHostCell(for: host.hostId)
    }

    func didHostStartVideo(_ liveEvent: SendbirdLiveSDK.LiveEvent, host: SendbirdLiveSDK.Host) {
        updateHostCell(for: host.hostId)
    }

    func didHostStopVideo(_ liveEvent: SendbirdLiveSDK.LiveEvent, host: SendbirdLiveSDK.Host) {
        updateHostCell(for: host.hostId)
    }

    func didHostEnter(_ liveEvent: SendbirdLiveSDK.LiveEvent, host: SendbirdLiveSDK.Host) {
        updateLiveEventInfo()
        collectionView.reloadData()
    }

    func didHostExit(_ liveEvent: SendbirdLiveSDK.LiveEvent, host: SendbirdLiveSDK.Host) {
        updateLiveEventInfo()
        collectionView.reloadData()
    }

    func didHostConnect(_ liveEvent: SendbirdLiveSDK.LiveEvent, host: SendbirdLiveSDK.Host) {
        updateLiveEventInfo()
        updateHostCell(for: host.hostId)
    }

    func didHostDisconnect(_ liveEvent: SendbirdLiveSDK.LiveEvent, host: SendbirdLiveSDK.Host) {
        updateLiveEventInfo()
        updateHostCell(for: host.hostId)
    }

    func didParticipantCountChange(_ liveEvent: SendbirdLiveSDK.LiveEvent, participantCountInfo: SendbirdLiveSDK.ParticipantCountInfo) {
        participantCountLabel.setTitle("\(participantCountInfo.participantCount)", for: .normal)
    }

    func didLiveEventReady(_ liveEvent: SendbirdLiveSDK.LiveEvent) {
        updateLiveEventInfo()
    }

    func didLiveEventStart(_ liveEvent: SendbirdLiveSDK.LiveEvent) {
        updateLiveEventInfo()
        startDurationTimer()
    }

    func didLiveEventEnd(_ liveEvent: SendbirdLiveSDK.LiveEvent) {
        guard liveEvent.endedBy != SendbirdLive.currentUser?.userId else { return }
        
        self.updateLiveEventInfo()
        if liveEvent.myRole == .host {
            let summaryVC = LiveEventSummaryViewController(liveEvent: self.liveEvent)
            self.navigationController?.pushViewController(summaryVC, animated: false)
        } else {
            SBUAlertView.show(
                title: "Live Event has ended",
                confirmButtonItem: .init(title: "Okay", completionHandler: { _ in
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }),
                cancelButtonItem: nil
            )
        }
    }

    func didLiveEventInfoUpdate(_ liveEvent: SendbirdLiveSDK.LiveEvent) {
        updateLiveEventInfo()
    }

    func didExit(_ liveEvent: SendbirdLiveSDK.LiveEvent, error: Error) {
        SBUAlertView.show(
            title: "You have been disconnected from the Live Event",
            confirmButtonItem: .init(title: "Okay", completionHandler: { _ in
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }),
            cancelButtonItem: nil
        )
    }

    func didDisconnect(_ liveEvent: LiveEvent, error: Error) {
        
    }
    
    func didReconnect(_ liveEvent: LiveEvent) {
        
    }
    
    func didUpdateCustomItems(_ liveEvent: SendbirdLiveSDK.LiveEvent, customItems: [String: String], updatedKeys: [String]) {

    }

    func didDeleteCustomItems(_ liveEvent: SendbirdLiveSDK.LiveEvent, customItems: [String: String], deletedKeys: [String]) {

    }

    func didReactionCountUpdate(_ liveEvent: SendbirdLiveSDK.LiveEvent, key: String, value: Int) {
        debugPrint("\(#function) - [Live reaction] didReactionCountUpdate key: \(key), value: \(value)")
    }
}

extension LiveEventViewController: AVRoutePickerViewDelegate {
    func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        self.liveEvent?.resetCamera()
    }
}

extension LiveEventViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return liveEvent.hosts.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "host", for: indexPath) as? HostCollectionViewCell else { return UICollectionViewCell() }
 
        collectionView.contentInset.top = max((collectionView.frame.height - collectionView.contentSize.height) / 2, 0)

        let host = liveEvent.hosts[indexPath.row]
        cell.host = host
        cell.liveEvent = liveEvent
        cell.updateView(with: host)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        switch liveEvent.hosts.count {
        case ...1:
            let width = collectionView.bounds.width
            let height = collectionView.bounds.height
            return CGSize(width: width, height: height)
        case 2:
            let width = collectionView.bounds.width
            let height = (collectionView.bounds.height - 8) / 2
            return CGSize(width: width, height: height)
        case 2...4:
            let width = (collectionView.bounds.width - 8) / 2
            let height = (collectionView.bounds.height - 8) / 2
            return CGSize(width: width, height: height)
        default:
            let height = (collectionView.bounds.width - 8) / 2
            let width = height
            return CGSize(width: width, height: height)
        }
    }

}
