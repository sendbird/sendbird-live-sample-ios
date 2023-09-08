//
//  HostListViewController.swift
//  SendbirdLiveUIKit
//
//  Created by Minhyuk Kim on 2022/11/08.
//

import SendbirdUIKit
import SendbirdLiveSDK
import SendbirdChatSDK
import UIKit

class HostListViewController: SBUBaseViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI Components
    public lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.register(SBUUserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DescriptionCell")
        return tableView
    }()

    public var titleLabel = UILabel()

    // MARK: - State properties
    public internal(set) var liveEvent: LiveEvent
    public internal(set) var openChannel: OpenChannel
    
    let userIdsForHost: [String]
    
    public required init(liveEvent: LiveEvent, openChannel: OpenChannel) {
        self.liveEvent = liveEvent
        self.openChannel = openChannel
        if let currentUserId = SendbirdChat.getCurrentUser()?.userId {
            var userIdsForHost = liveEvent.userIdsForHost
            userIdsForHost.removeAll(where: { $0 == currentUserId })
            self.userIdsForHost = userIdsForHost
        } else {
            userIdsForHost = []
        }
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - UIKit Life cycle
    open override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // MARK: - Sendbird Life cycle
    open override func setupViews() {
        super.setupViews()

        view.addSubview(tableView)
        
        self.title = "Hosts"
    }

    open override func setupLayouts() {
        super.setupLayouts()
        
        tableView
            .sbu_constraint_equalTo(
                leadingAnchor: self.view.leadingAnchor, leading: 0,
                trailingAnchor: self.view.trailingAnchor, trailing: 0,
                topAnchor: self.view.layoutMarginsGuide.topAnchor, top: 16,
                bottomAnchor: self.view.layoutMarginsGuide.bottomAnchor, bottom: 16
            )
    }

    open override func setupStyles() {
        self.navigationController?.navigationBar.tintColor = SBUColorSet.primary200
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: SBUColorSet.ondark01]

        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = SBUColorSet.ondark04

        self.view.backgroundColor = SBUColorSet.background600

        self.titleLabel.textColor = SBUColorSet.ondark01
        self.titleLabel.font = SBUFontSet.h1
        
        let title = UILabel()
        title.text = "Host"
        title.font = SBUFontSet.h3
        title.textColor = SBUColorSet.ondark01
        self.navigationItem.titleView = title
        
        self.titleLabel.text = liveEvent.title?.trimmed.collapsed
    }

    // MARK: - Actions
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

    // MARK: - UITableViewDataSource & UITableViewDelegate
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userIdsForHost.count + 2
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? SBUUserCell,
                  let currentUser = SendbirdChat.getCurrentUser() else { return UITableViewCell() }
            cell.configure(type: .operators, user: SBUUser(user: currentUser))
            cell.operatorLabel.text = "Host"
            cell.operatorLabel.isHidden = false
            cell.theme = .dark
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath)
            cell.backgroundColor = .clear
            let titleLabel = UILabel()
            titleLabel.text = "Host users"
            titleLabel.font = SBUFontSet.subtitle2
            titleLabel.textColor = SBUColorSet.ondark01
            
            let descriptionLabel = UILabel()
            descriptionLabel.text = "Any one of the users in the list below can act as a host for the live event. If the current host leaves the event, another user can act as the host."
            descriptionLabel.font = SBUFontSet.body3
            descriptionLabel.textColor = SBUColorSet.ondark02
            descriptionLabel.numberOfLines = 0
            
            let stackView = SBUStackView(axis: .vertical, alignment: .leading, spacing: 5)
            stackView.setVStack([titleLabel, descriptionLabel])
            
            cell.contentView.addSubview(stackView)
            stackView
                .sbu_constraint(equalTo: cell.contentView, leading: 16, trailing: -16, top: 16, bottom: 14)

            cell.selectionStyle = .none
            
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? SBUUserCell else { return UITableViewCell() }
            cell.configure(type: .operators, user: SBUUser(userId: userIdsForHost[indexPath.row - 2]))
            cell.nicknameLabel.text = userIdsForHost[indexPath.row - 2]
            cell.moreButton = .init()
            cell.theme = .dark
            cell.selectionStyle = .none
            return cell
        }
    }
}
