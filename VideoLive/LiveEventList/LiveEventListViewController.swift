//
//  LiveEventListViewController.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2022/08/31.
//

import UIKit
import SendbirdLiveSDK
import SendbirdUIKit
import SendbirdChatSDK

open class LiveEventListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SBUEmptyViewDelegate {
    open var liveEvents: [LiveEvent] = []

    @IBOutlet var tableView: UITableView!

    lazy var emptyView: SBUEmptyView = {
       let view = SBLEmptyView()
        view.delegate = self
        return view
    }()

    open var refreshControl = UIRefreshControl()

    /// Fetches a list of live events.
    open var fetchLiveEventQueryParams: LiveEventListQueryParams = LiveEventListQueryParams(
        limit: 20,
        state: nil,
        createdAtRange: nil,
        participantCountRange: nil,
        durationRange: nil,
        liveEventIds: [],
        createdByUserIds: [],
        types: []
    ) {
        didSet {
            fetchLiveEvents(reset: true)
        }
    }

    open var query: LiveEventListQuery?

    open override func viewDidLoad() {
        super.viewDidLoad()

        // tableview
        self.tableView.backgroundView = emptyView
        self.tableView.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)

        fetchLiveEvents()
    }

    open lazy var rightBarButton: UIButton = {
        let button = UIButton()
        button.setTitle("Go Live", for: .normal)
        button.isUserInteractionEnabled = true
        button.setTitleColor(SBUColorSet.primary300, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(clickGoLive(_:)), for: .touchUpInside)
        return button
    }()

    open var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Live Events"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false

        self.navigationController?.sbu_setupNavigationBarAppearance(tintColor: .white)
        self.setNeedsStatusBarAppearanceUpdate()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    @objc func pullToRefresh(_ sender: Any?) {
        fetchLiveEvents(reset: true)
    }

    open func fetchLiveEvents(reset: Bool = false) {
        if reset || query == nil {
            self.query = SendbirdLive.createLiveEventListQuery(params: fetchLiveEventQueryParams)
            self.liveEvents = []
        }

        self.query?.next { liveEvents, error in
            DispatchQueue.main.async {
                defer {
                    self.reloadTableView(error: error)
                    self.tableView.refreshControl?.endRefreshing()
                }

                guard let liveEvents = liveEvents, error == nil else {
                    self.liveEvents.removeAll()
                    return
                }

                self.liveEvents.append(contentsOf: liveEvents)
            }
        }
    }

    open func reloadTableView(error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if self?.liveEvents.isEmpty == true {
                self?.emptyView.reloadData(error == nil ? .noChannels : .error)
            } else {
                self?.emptyView.reloadData(.none)
            }
            self?.tableView.reloadData()
        }
    }

    public func didSelectRetry() {
        self.emptyView.reloadData(.noChannels)
        self.fetchLiveEvents(reset: true)
    }

    func showLiveEvent(_ liveEvent: LiveEvent) {
        self.tableView.isUserInteractionEnabled = false

        SendbirdLive.getLiveEvent(id: liveEvent.liveEventId) { result in
            DispatchQueue.main.async {
                defer { self.tableView.isUserInteractionEnabled = true }
                guard case .success(let liveEvent) = result, liveEvent.state != .ended else {
                    SBUAlertView.show(
                        title: "Oops!",
                        message: "Can't enter an ended live event",
                        oneTimetheme: .light,
                        confirmButtonItem: .init(title: "OK", completionHandler: { _ in }),
                        cancelButtonItem: nil
                    )
                    return
                }
                if liveEvent.myRole == .host {
                    let descriptionItem = SBUActionSheetItem(
                        title: "Choose your role",
                        color: SBUColorSet.onlight02,
                        textAlignment: .center,
                        completionHandler: nil
                    )

                    let hostItem = SBUActionSheetItem(
                        title: "Host",
                        textAlignment: .center,
                        completionHandler: {
                            liveEvent.enterAsHost(options: .init(turnVideoOn: true, turnAudioOn: true)) { _ in
                                if liveEvent.state == .created {
                                    liveEvent.setEventReady()
                                }

                                liveEvent.startStreaming(mediaOptions: nil)
                                self.performSegue(withIdentifier: "enterLiveEvent", sender: liveEvent)
                            }
                        }
                    )

                    let participantItem = SBUActionSheetItem(
                        title: "Participant",
                        textAlignment: .center,
                        completionHandler: {
                            self.enterLiveEvent(liveEvent)
                        }
                    )
                    let cancelItem = SBUActionSheetItem(
                        title: SBUStringSet.Cancel,
                        color: SBUColorSet.primary300,
                        completionHandler: nil
                    )

                    self.view.endEditing(true)

                    SBUActionSheet.show(
                        items: [descriptionItem, hostItem, participantItem],
                        cancelItem: cancelItem,
                        oneTimetheme: .light
                    )
                } else {
                    self.enterLiveEvent(liveEvent)
                }
            }
        }
    }

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "enterLiveEvent",
           let destination =  segue.destination as? LiveEventViewControllers {
            destination.liveEvent = sender as? LiveEvent
        }
    }
    func enterLiveEvent(_ liveEvent: LiveEvent) {
        liveEvent.enter { error in
            DispatchQueue.main.async {
                guard error == nil else {
                    SBUAlertView.show(
                        title: "Can't enter yet",
                        message: "This live event will open soon.",
                        oneTimetheme: .light,
                        confirmButtonItem: .init(title: SBUStringSet.OK, completionHandler: { _ in }),
                        cancelButtonItem: nil
                    )
                    return
                }

                self.performSegue(withIdentifier: "enterLiveEvent", sender: liveEvent)
            }
        }
    }

    @objc func clickGoLive(_ sender: Any) {
        self.performSegue(withIdentifier: "createLiveEvent", sender: nil)
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return liveEvents.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard liveEvents.count > indexPath.row else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "liveEvent", for: indexPath) as? LiveEventListCell else { return .init() }

        cell.configure(liveEvent: liveEvents[indexPath.row])

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard liveEvents.count > indexPath.row else { return }

        showLiveEvent(liveEvents[indexPath.row])
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !self.liveEvents.isEmpty else { return }
        guard let query = query else { return }
        guard query.hasNext else { return }
        guard indexPath.row == (self.liveEvents.count - Int(self.fetchLiveEventQueryParams.limit) / 4) else { return }
        guard !query.isLoading else { return }

        fetchLiveEvents()
    }
}
