//
//  LiveEventSummaryView.swift
//  SendbirdLiveUIKit
//
//  Created by Minhyuk Kim on 2022/10/03.
//

import UIKit
import SendbirdUIKit
import SendbirdLiveSDK

class LiveEventSummaryViewController: SBUBaseViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI Components
    public lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 156))
        return view
    }()
    
    public lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.register(LiveEventSummaryTableViewCell.self, forCellReuseIdentifier: "SummaryCell")
        return tableView
    }()
    
    public var titleLabel = UILabel()
    
    public lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        return imageView
    }()
    
    public lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(SBUIconSet.iconClose.sbu_with(tintColor: SBUColorSet.ondark01), for: .normal)
        button.addTarget(
            self,
            action: #selector(onClickClose),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: - State properties
    public internal(set) var liveEvent: LiveEvent
    
    // MARK: - Initializer
    public required init(liveEvent: LiveEvent) {
        self.liveEvent = liveEvent
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - UIKit Life cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
//        SendbirdLiveUI.connectIfNeeded { [weak self] user, error in
//            guard let self = self else { return }
//
//        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.isHidden = true
        
        // TODO: required?
        self.setupStyles()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Sendbird Life cycle
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(tableView)
        view.addSubview(closeButton)
        
        headerView.addSubview(coverImageView)
        headerView.addSubview(titleLabel)
        
        tableView.tableHeaderView = headerView
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        closeButton
            .sbu_constraint_equalTo(
                leadingAnchor: self.view.leadingAnchor,
                leading: 14,
                topAnchor: self.view.layoutMarginsGuide.topAnchor,
                top: 10
            )
            .sbu_constraint(width: 24, height: 24)
        
        coverImageView
            .sbu_constraint_equalTo(topAnchor: headerView.topAnchor, top: 24, centerXAnchor: headerView.centerXAnchor, centerX: 0)
            .sbu_constraint(width: 80, height: 80)
        
        titleLabel
            .sbu_constraint_equalTo(topAnchor: coverImageView.bottomAnchor, top: 8, centerXAnchor: headerView.centerXAnchor, centerX: 0)
            .sbu_constraint(height: 21)
        
        tableView
            .sbu_constraint_equalTo(
                leadingAnchor: self.view.leadingAnchor, leading: 0,
                trailingAnchor: self.view.trailingAnchor, trailing: 0,
                topAnchor: self.view.layoutMarginsGuide.topAnchor, top: 16,
                bottomAnchor: self.view.layoutMarginsGuide.bottomAnchor, bottom: 16
            )
    }
    
    open override func setupStyles() {
//        self.setupNavigationBar(backgroundColor: SBUColorSet.background500, shadowColor: .clear)
        
//        self.navigationController?.navigationBar.tintColor = SBUColorSet.primary200
//        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: SBUColorSet.ondark01]
        
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = SBUColorSet.ondark04
        
        self.view.backgroundColor = SBUColorSet.background600
        
        self.titleLabel.textColor = SBUColorSet.ondark01
        self.titleLabel.font = SBUFontSet.h1
        
        if let coverURL = liveEvent.coverURL {
            self.coverImageView.loadImage(urlString: coverURL)
            self.coverImageView.contentMode = .scaleAspectFill
        } else {
            self.coverImageView.image = SBUIconSet.iconUser.resize(with: CGSize(width: 27, height: 27)).sbu_with(tintColor: SBUColorSet.onlight01)
            self.coverImageView.backgroundColor = SBUColorSet.background200
            self.coverImageView.contentMode = .center
        }
        
        self.titleLabel.text = liveEvent.title?.trimmed.collapsed// ?? SBUStringSet.Live.CreateLiveEvent.defaultTitle
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
        return 3
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LiveEventSummaryTableViewCell.identifier, for: indexPath) as? LiveEventSummaryTableViewCell else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell: LiveEventSummaryTableViewCell, indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "Total participants"
            cell.descriptionLabel.text = "\(liveEvent.cumulativeParticipantCount)"
        case 1:
            cell.titleLabel.text = "Peak concurrent participants"
            cell.descriptionLabel.text = "\(liveEvent.peakParticipantCount)"
        case 2:
            cell.titleLabel.text = "Duration"
            cell.descriptionLabel.text = liveEvent.duration.durationText()  
            
        default: break
        }
    }
}

// MARK: - TableViewCell
class LiveEventSummaryTableViewCell: SBUTableViewCell {
    static let identifier = "SummaryCell"
    
    var titleLabel = UILabel()
    var descriptionLabel = UILabel()
    
    override func setupViews() {
        super.setupViews()
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(descriptionLabel)
    }
    
    override func setupLayouts() {
        super.setupLayouts()
        
        titleLabel
            .sbu_constraint_equalTo(
                leadingAnchor: self.contentView.leadingAnchor, leading: 24,
                trailingAnchor: self.contentView.trailingAnchor, trailing: 24,
                topAnchor: self.contentView.topAnchor, top: 16
            )
        descriptionLabel
            .sbu_constraint_equalTo(
                leadingAnchor: self.contentView.leadingAnchor, leading: 24,
                trailingAnchor: self.contentView.trailingAnchor, trailing: 24,
                topAnchor: titleLabel.bottomAnchor, top: 4,
                bottomAnchor: self.contentView.bottomAnchor, bottom: 16
            )
    }
    
    override func setupStyles() {
        super.setupStyles()
        
        self.backgroundColor = .clear
        
        self.titleLabel.font = SBUFontSet.body2
        self.titleLabel.textColor = SBUColorSet.ondark02
        
        self.descriptionLabel.font = SBUFontSet.body1
        self.descriptionLabel.textColor = SBUColorSet.ondark01
    }
}
