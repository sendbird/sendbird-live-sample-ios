//
//  LiveEventSettingsViewController.swift
//  SendbirdLiveUIKit
//
//  Created by Jaesung Lee on 2022/09/26.
//

import UIKit
import PhotosUI
import SendbirdUIKit
import SendbirdLiveSDK
import MobileCoreServices

open class LiveEventSettingsViewController: SBUBaseViewController, SBUSelectablePhotoViewDelegate, SBUActionSheetDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    public func didDismissActionSheet() {

    }
    
    // MARK: - UI
    
    // MARK: Header (Navigation items)
    /// A view that represents a left `UIBarButtonItem` in navigation bar.
    public var leftBarButton: UIBarButtonItem? = nil {
        didSet {
            self.navigationItem.leftBarButtonItem = self.leftBarButton
        }
    }
    
    /// A view that represents a right `UIBarButtonItem` in navigation bar.
    public var rightBarButton: UIBarButtonItem? = nil {
        didSet {
            self.navigationItem.rightBarButtonItem = self.rightBarButton
        }
    }
    
    var defaultLeftBarButton: UIBarButtonItem {
        let backButton = UIBarButtonItem(
            image: SBUIconSet.iconBack
                .sbu_with(tintColor: SBUColorSet.primary200)
                .resize(with: CGSize(width: 24, height: 24)),
            style: .plain,
            target: self,
            action: #selector(didTapLeftBarButton)
        )
        return backButton
    }
    
    var defaultRightBarButton: UIBarButtonItem {
        let createChannelButton = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(didTapRightBarButton)
        )
        createChannelButton.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return createChannelButton
    }
    
    // MARK: List
    public var tableView = UITableView()
    
    /// A view that shows channel information on the settings.
    public var channelInfoView: UIView? = SBUChannelSettingsChannelInfoView()
    
    
    public lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 156))
        return view
    }()
    
    public var titleLabel = UILabel()
    
    public lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - State properties
    public internal(set) var liveEvent: LiveEvent!
    
    // MARK: - UIKit Life cycle
    
    required public init(liveEvent: LiveEvent) {
        self.liveEvent = liveEvent
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, renamed: "init(liveEvent:)")
    required dynamic public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Sendbird Life cycle
    open override func setupViews() {
        super.setupViews()
        
        // Navigation Items
        if self.leftBarButton == nil {
            self.leftBarButton = self.defaultLeftBarButton
        }
        if self.rightBarButton == nil {
            self.rightBarButton = self.defaultRightBarButton
        }
        
        let title = UILabel()
        title.text = "Live event information"
        title.font = SBUFontSet.h3
        title.textColor = SBUColorSet.ondark01
        self.navigationItem.titleView = title
        
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        
        // tableview
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.bounces = false
        self.tableView.alwaysBounceVertical = false
        self.tableView.separatorColor = SBUColorSet.ondark04
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(ActionTableViewCell.self, forCellReuseIdentifier: "ActionCell")
        self.tableView.register(DetailTableViewCell.self, forCellReuseIdentifier: "DetailCell")
        self.view.addSubview(self.tableView)
        
        headerView.addSubview(coverImageView)
        headerView.addSubview(titleLabel)
        
        tableView.tableHeaderView = headerView
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        coverImageView
            .sbu_constraint_equalTo(topAnchor: headerView.topAnchor, top: 24, centerXAnchor: headerView.centerXAnchor, centerX: 0)
            .sbu_constraint(width: 80, height: 80)
        
        titleLabel
            .sbu_constraint_equalTo(topAnchor: coverImageView.bottomAnchor, top: 8, centerXAnchor: headerView.centerXAnchor, centerX: 0)
            .sbu_constraint(height: 21)

        self.tableView.sbu_constraint(equalTo: self.view, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        super.setupStyles()
//        
//        self.setupNavigationBar(
//            backgroundColor: SBUColorSet.background500,
//            shadowColor: .clear
//        )
        
        self.leftBarButton?.tintColor = SBUColorSet.primary200
        self.rightBarButton?.tintColor = SBUColorSet.primary200
        
        self.view.backgroundColor = SBUColorSet.background600
        // list
        self.tableView.backgroundColor = .clear
        
        self.setCoverImage()
        if let coverURL = liveEvent.coverURL {
            self.coverImageView.loadImage(urlString: coverURL)
            self.coverImageView.contentMode = .scaleAspectFill
        } else {
//            self.coverImageView.image = SBUIconSet.Live.iconLive.sbu_with(tintColor: SBUColorSet.ondark01).resize(with: CGSize(width: 27, height: 27))
        }
        
        self.titleLabel.text = liveEvent.title?.trimmed.collapsed ?? "Live Event"
        self.titleLabel.textColor = SBUColorSet.ondark01
        self.titleLabel.font = SBUFontSet.h1

        self.tableView.reloadData()
    }
    
    func setCoverImage() {
        if let coverURL = liveEvent.coverURL {
            self.coverImageView.loadImage(urlString: coverURL)
            self.coverImageView.contentMode = .scaleAspectFill
        } else {
            self.coverImageView.image = SBUIconSet.iconUser.resize(with: CGSize(width: 27, height: 27)).sbu_with(tintColor: SBUColorSet.onlight01)
            self.coverImageView.backgroundColor = SBUColorSet.background200
            self.coverImageView.contentMode = .center
        }
    }
    
    // MARK: - UITableView Delegate/DataSource
    open func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0...2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell") as? ActionTableViewCell else { return UITableViewCell() }
            
            cell.selectionStyle = .none
            
            switch indexPath.row {
            case 0:
                cell.iconImageView.image = SBUIconSet.iconOperator.sbu_with(tintColor: SBUColorSet.primary200)
                cell.titleLabel.text = "Host"
                cell.countLabel.text = "\(liveEvent.userIdsForHost.count)"
                
                let imageView = UIImageView(image: SBUIconSet.iconChevronRight.resize(with: CGSize(width: 24, height: 24)).sbu_with(tintColor: SBUColorSet.ondark01))
                imageView.contentMode = .center
                imageView.sbu_constraint(width: 24, height: 24)
                cell.detailView.addArrangedSubview(imageView)
                
                cell.contentVStackView.arrangedSubviews.filter { $0 is UILabel }.forEach { $0.removeFromSuperview() }
                
            case 1:
                cell.iconImageView.image = SBUIconSet.iconMembers.sbu_with(tintColor: SBUColorSet.primary200)
                cell.titleLabel.text = "Participants"
                cell.countLabel.text = "\(liveEvent.openChannel?.participantCount ?? 0)"
                
                let imageView = UIImageView(image: SBUIconSet.iconChevronRight.resize(with: CGSize(width: 24, height: 24)).sbu_with(tintColor: SBUColorSet.ondark01))
                imageView.contentMode = .center
                imageView.sbu_constraint(width: 24, height: 24)
                cell.detailView.addArrangedSubview(imageView)
                
                cell.contentVStackView.arrangedSubviews.filter { $0 is UILabel }.forEach { $0.removeFromSuperview() }
                
            case 2:
                cell.iconImageView.image = SBUIconSet.iconFreeze.sbu_with(tintColor: SBUColorSet.primary200)
                cell.titleLabel.text = "Freeze chat"
                cell.countLabel.text = ""
                
                let frozenSwitch = UISwitch()
                frozenSwitch.onTintColor = SBUColorSet.primary200
                frozenSwitch.isOn = liveEvent.openChannel?.isFrozen == true
                frozenSwitch.isEnabled = false
                frozenSwitch.sbu_constraint(width: 51, height: 31)
                cell.detailView.addArrangedSubview(frozenSwitch)
                
                let descriptionLabel = UILabel()
                descriptionLabel.text = "Only operators can send a message. This doesn't stop the live event."
                descriptionLabel.font = SBUFontSet.body3
                descriptionLabel.textColor = SBUColorSet.ondark02
                descriptionLabel.numberOfLines = 0
                
                cell.contentVStackView.arrangedSubviews.filter { $0 is UILabel }.forEach { $0.removeFromSuperview() }
                cell.contentVStackView.addArrangedSubview(descriptionLabel)
                
            default: break
            }
            
            return cell
        case 3...:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell") as? DetailTableViewCell else { return UITableViewCell() }
            
            cell.selectionStyle = .none
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
            
            switch indexPath.row {
            case 3:
                cell.titleLabel.text = "Live event ID"
                cell.detailLabel.text = liveEvent.liveEventId
            case 4:
                cell.titleLabel.text = "Created at"
                cell.detailLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(liveEvent.createdAt) / 1000))
            case 5:
                cell.titleLabel.text = "Created by"
                cell.detailLabel.text = liveEvent.createdBy
            case 6:
                cell.titleLabel.text = "Started at"
                if let startedAt = liveEvent.startedAt {
                    cell.detailLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(startedAt) / 1000))
                } else {
                    cell.detailLabel.text = ""
                }
                
            case 7:
                cell.titleLabel.text = "Started by"
                cell.detailLabel.text = liveEvent.startedBy
                
            default: break
            }
            return cell
        default: return UITableViewCell()
        }
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            guard let channel = liveEvent.openChannel else { return }
            
            let hostListVC = HostListViewController(liveEvent: liveEvent, openChannel: channel)
            
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(hostListVC, animated: true)
            
        case 1:
            guard let channel = liveEvent.openChannel else { return }
            let participantListVC = SBUViewControllerSet.OpenUserListViewController.init(channel: channel, userListType: .participants)
            participantListVC.theme = .dark
            participantListVC.componentTheme = .dark
            let usercell = SBLUserCell()
            usercell.theme = .dark
            participantListVC.listComponent?.register(userCell: usercell)
            
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(participantListVC, animated: true)

        default: break
        }
    }
    
    // MARK: - Actions
    open func didTapLeftBarButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    open func didTapRightBarButton() {
        self.showChannelEditActionSheet()
    }
    
    /// This function shows the live event name change popup.
    public func changeLiveEventTitle() {
        let saveButton = SBUAlertButtonItem(title: SBUStringSet.Save) {[weak self] newTitle in
            guard let self = self else { return }
            guard let newTitle = newTitle as? String else { return }
            
            let trimmedEventTitle = newTitle.truncating(maxBytes: 191)
            guard trimmedEventTitle.count > 0 else { return }

            var params = LiveEvent.UpdateParams()
            params.title = trimmedEventTitle
            self.liveEvent.updateLiveEventInfo(params: params) { error in
                guard error == nil else { return }
                self.setupStyles()
            }
        }
        
        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) { _ in }

        SBUAlertView.show(
            title: "Change Event Title",
            needInputField: true,
            placeHolder: "New Title",
            centerYRatio: 0.75,
            oneTimetheme: .dark,
            confirmButtonItem: saveButton,
            cancelButtonItem: cancelButton
        )
    }
    
    // MARK: - Image Picker
    /// This function used to when edit button click.
    public func showChannelEditActionSheet() {
        let titleItem = SBUActionSheetItem(
            title: "Edit this event?",
            color: SBUColorSet.ondark02,
            font: SBUFontSet.body2,
            textAlignment: .center
        )
        let changeTitleItem = SBUActionSheetItem(
            title: "Change title",
            textAlignment: .center,
            completionHandler: nil
        )
        let changeCoverImageItem = SBUActionSheetItem(
            title: "Change cover image",
            textAlignment: .center,
            completionHandler: nil
        )
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: SBUColorSet.primary200,
            completionHandler: nil
        )

        SBUActionSheet.show(
            items: [titleItem, changeTitleItem, changeCoverImageItem],
            cancelItem: cancelItem,
            identifier: 1,
            oneTimetheme: .dark,
            delegate: self
        )

        self.updateStyles()
    }

    public func didSelectActionSheetItem(index: Int, identifier: Int) {
        // sheetID Edit
        if identifier == 1 {
            switch index {
            case 1: self.changeLiveEventTitle()
            case 2:
                DispatchQueue.main.async {
                    self.selectLiveEventCoverImage()
                }
            default: break
            }
        }
        // sheet ID: Picker
        else if identifier == 2 {
            switch index {
            case 0:
                var params = LiveEvent.UpdateParams()
                params.coverURL = nil
                self.liveEvent.updateLiveEventInfo(params: params) { error in
                    guard error == nil else { return }
                    self.setupStyles()
                }

            default:
                let type = MediaResourceType.init(rawValue: index-1) ?? .unknown
                self.showChannelImagePicker(with: type)
            }
        }
    }


    /// This function shows the channel image selection menu.
    public func selectLiveEventCoverImage() {
        let removeItem = SBUActionSheetItem(
            title: SBUStringSet.RemovePhoto,
            color: SBUColorSet.error200,
            textAlignment: .center,
            completionHandler: nil
        )
        let cameraItem = SBUActionSheetItem(
            title: SBUStringSet.TakePhoto,
            textAlignment: .center,
            completionHandler: nil
        )
        let libraryItem = SBUActionSheetItem(
            title: SBUStringSet.ChoosePhoto,
            textAlignment: .center,
            completionHandler: nil
        )
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: SBUColorSet.primary200,
            textAlignment: .center,
            completionHandler: nil
        )
        SBUActionSheet.show(
            items: [removeItem, cameraItem, libraryItem],
            cancelItem: cancelItem,
            identifier: 2,
            oneTimetheme: .dark,
            delegate: self
        )
    }

    /// This function shows image picker for changing channel image.
    /// - Parameter type: Media resource type (`MediaResourceType`)
    /// - Since: 3.0.0
    open func showChannelImagePicker(with type: MediaResourceType) {
        switch type {
        case .camera:
            PermissionManager.shared.requestDeviceAccessIfNeeded(for: .video) { isGranted in
                if isGranted {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.showCamera()
                    }
                } else {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(
                            settingsURL,
                            options: [:],
                            completionHandler: nil
                        )
                    }
                }
            }
        case .library:
            PermissionManager.shared.requestPhotoAccessIfNeeded { status in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    switch status {
                    case .all:
                        self.showPhotoLibraryPicker()
                    case .limited:
                        self.showLimitedPhotoLibraryPicker()
                    default:
                        self.showPermissionAlert()
                    }
                }
            }
        default: break
        }
    }

    open func showPermissionAlert() {
        let settingButton = SBUAlertButtonItem(title: SBUStringSet.Settings) { info in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }

        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) {_ in }

        SBUAlertView.show(
            title: SBUStringSet.Alert_Allow_PhotoLibrary_Access,
            message: SBUStringSet.Alert_Allow_PhotoLibrary_Access_Message,
            oneTimetheme: .dark,
            confirmButtonItem: settingButton,
            cancelButtonItem: cancelButton
        )
    }

    /// Presents `UIImagePickerController` for using camera.
    open func showCamera() {
        let sourceType: UIImagePickerController.SourceType = .camera
        let mediaType: [String] = [
            String(kUTTypeImage)
        ]

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.mediaTypes = mediaType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }

    /// Presents `UIImagePickerController`. If `SBUGlobals.UsingPHPicker`is `true`, it presents `PHPickerViewController` in iOS 14 or later.
    /// - NOTE: If you want to use customized `PHPickerConfiguration`, please override this method.
    open func showPhotoLibraryPicker() {
        if #available(iOS 14, *), SBUGlobals.isPHPickerEnabled {
            var configuration = PHPickerConfiguration()
            configuration.filter = .any(of: [.images])
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
            return
        }

        let sourceType: UIImagePickerController.SourceType = .photoLibrary
        let mediaType: [String] = [
            String(kUTTypeImage),
        ]

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.mediaTypes = mediaType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }

    open func showLimitedPhotoLibraryPicker() {
        let selectablePhotoVC = SBUSelectablePhotoViewController(mediaType: .image)
        selectablePhotoVC.delegate = self
        let nav = UINavigationController(rootViewController: selectablePhotoVC)
        self.present(nav, animated: true, completion: nil)
    }

    // MARK: SBUSelectablePhotoViewDelegate
    open func didTapSendImageData(_ data: Data) {
        guard let image = UIImage(data: data) else { return }
        self.updateCoverImage(image)
    }

    // MARK: UIImagePickerViewControllerDelegate
    /// Updates cover image
    /// - Parameter image: Image to be updated
    open func updateCoverImage(_ image: UIImage?) {
        var params = LiveEvent.UpdateParams()
        params.coverFile = image?.jpegData(compressionQuality: 0.8)
        liveEvent?.updateLiveEventInfo(params: params) { error in
            guard error == nil else { return }
            self.setupStyles()
        }
    }

    // MARK: - UIImagePickerViewControllerDelegate
    open func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            picker.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                guard let originalImage = info[.originalImage] as? UIImage else { return }

                self.updateCoverImage(originalImage)
            }
        }

    // MARK: - PHPickerViewControllerDelegate
    /// Override this method to handle the `results` from `PHPickerViewController`.
    /// As defaults, it doesn't support multi-selection and live photo.
    /// - Important: To use this method, please assign self as delegate to `PHPickerViewController` object.
    @available(iOS 14, *)
    open func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        results.forEach {
            let itemProvider = $0.itemProvider
            // image
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                itemProvider.loadItem(forTypeIdentifier: UTType.image.identifier, options: [:]) { url, error in
                    if itemProvider.canLoadObject(ofClass: UIImage.self) {
                        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] imageItem, error in
                            guard let self = self else { return }
                            guard let originalImage = imageItem as? UIImage else { return }
                            self.updateCoverImage(originalImage)
                        }
                    }
                }
            }
        }
    }
    
    class ActionTableViewCell: SBUTableViewCell {
        var contentVStackView = SBUStackView(axis: .vertical, alignment: .fill, spacing: 12)
        var contentStackView = SBUStackView(axis: .horizontal, alignment: .center, spacing: 16)
        
        var iconImageView = UIImageView()
        var titleLabel = UILabel()
        var countLabel = UILabel()
        var detailView = SBUStackView()
        
        override func prepareForReuse() {
            super.prepareForReuse()
            
            self.detailView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        }
        
        override func setupViews() {
            super.setupViews()
            contentVStackView.setVStack([
                contentStackView.setHStack([
                    iconImageView,
                    titleLabel,
                    UIView(),
                    countLabel,
                    detailView
                ])
            ])
            
            contentView.addSubview(contentVStackView)
        }
        
        override func setupLayouts() {
            super.setupLayouts()
            
            contentVStackView
                .sbu_constraint(equalTo: self.contentView, leading: 16, trailing: -20, top: 16, bottom: 16)
            
            iconImageView.sbu_constraint(width: 24, height: 24)
            titleLabel.sbu_constraint(height: 24)
            countLabel.sbu_constraint(height: 24)
            detailView.sbu_constraint(height: 31)
        }
        
        override func setupStyles() {
            super.setupStyles()
            
            self.backgroundColor = .clear
            
            titleLabel.textColor = SBUColorSet.ondark01
            titleLabel.font = SBUFontSet.subtitle2
            
            countLabel.textColor = SBUColorSet.ondark02
            countLabel.font = SBUFontSet.subtitle2
        }
    }
    
    class DetailTableViewCell: SBUTableViewCell {
        var contentStackView = SBUStackView(axis: .vertical, alignment: .leading, spacing: 4)
        
        var titleLabel = UILabel()
        var detailLabel = UILabel()
        
        override func setupViews() {
            super.setupViews()
            
            contentStackView.setVStack([titleLabel, detailLabel])
            
            contentView.addSubview(contentStackView)
        }
        
        override func setupLayouts() {
            super.setupLayouts()
            
            titleLabel
                .sbu_constraint(height: 16)
            detailLabel
                .sbu_constraint(height: 20)
            contentStackView
                .sbu_constraint(equalTo: self.contentView, leading: 16, trailing: -20, top: 16, bottom: 16)
        }
        
        override func setupStyles() {
            super.setupStyles()
            
            self.backgroundColor = .clear
            
            titleLabel.font = SBUFontSet.body2
            titleLabel.textColor = SBUColorSet.ondark02
            
            detailLabel.font = SBUFontSet.body1
            detailLabel.textColor = SBUColorSet.ondark01
        }
    }
}

class SBLUserCell: SBUUserCell {
    override func configure(type: UserListType, user: SBUUser, isChecked: Bool = false, operatorMode: Bool = false) {
        super.configure(type: type, user: user, isChecked: isChecked, operatorMode: operatorMode)
        
        self.moreButton.isHidden = true
        self.operatorLabel.isHidden = true
    }
}
