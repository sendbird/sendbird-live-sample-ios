//
//  HostSelectionViewController.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2023/10/13.
//

import UIKit
import SendbirdUIKit
import SendbirdLiveSDK
import SendbirdChatSDK

class HostSelectionViewController: UITableViewController, HostSelectionDelegate {

    public internal(set) var selectedUserIds: [String] = []

    public var rightBarButton: UIBarButtonItem? {
        didSet {
            self.navigationItem.rightBarButtonItem = self.rightBarButton
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let barButton = UIBarButtonItem(
            image: SBUIconSet.iconPlus
                .sbu_with(tintColor: SBUColorSet.primary200)
                .resize(with: CGSize(width: 24, height: 24)),
            style: .plain,
            target: self,
            action: #selector(didTapRightBarButton)
        )
        barButton.isEnabled = selectedUserIds.count < 10
        self.rightBarButton = barButton

        let title = UILabel()
        title.text = "Users who can be host"
        title.font = SBUFontSet.h3
        title.textColor = SBUColorSet.ondark01
        self.navigationItem.titleView = title
    }

    @objc open func didTapRightBarButton() {
        SBUAlertView.show(
            title: "Add user",
            needInputField: true,
            placeHolder: "Enter user ID",
            oneTimetheme: .dark,
            confirmButtonItem: SBUAlertButtonItem(
                title: "Add",
                completionHandler: { info in
                    guard let userId = info as? String else { return }
                    self.selectUser(userId: userId)
                }
            ),
            cancelButtonItem: SBUAlertButtonItem(
                title: SBUStringSet.Cancel,
                completionHandler: { _ in }
            )
        )
    }

    public func selectUser(userId: String) {
        guard !userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !self.selectedUserIds.contains(userId) else { return }

        self.selectedUserIds.append(userId)

        self.rightBarButton?.isEnabled = self.selectedUserIds.count < 10

        self.tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let vc = self.navigationController?.previousViewController as? CreateLiveEventViewController else { return }
        vc.selectedUserIds = selectedUserIds
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedUserIds.count
    }

    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard selectedUserIds.count > indexPath.row else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "host") as? SelectedHostTableViewCell else { return UITableViewCell() }

        let userId = selectedUserIds[indexPath.row]

        cell.selectionStyle = .none
        cell.delegate = self

        cell.configure(userId: userId)
        cell.setupStyles()

        if userId == SendbirdChat.getCurrentUser()?.userId {
            cell.actionButton.isEnabled = false
        }

        return cell
    }

    public func removeUserFromHost(_ userId: String) {
        self.selectedUserIds.removeAll(where: { $0 == userId })
        self.rightBarButton?.isEnabled = self.selectedUserIds.count < 10

        self.tableView.reloadData()
    }
}

protocol HostSelectionDelegate: AnyObject {
    func removeUserFromHost(_ userId: String)
}

protocol SelectedHostTableViewCellProtocol: SBUTableViewCell {
    var userId: String { get }
    var delegate: HostSelectionDelegate? { get set }

    func configure(userId: String)
}

class SelectedHostTableViewCell: SBUTableViewCell, SelectedHostTableViewCellProtocol {
    var userId: String = ""

    weak var delegate: HostSelectionDelegate?

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var userIdLabel: UILabel!
    @IBOutlet var actionButton: UIButton!

    public func configure(userId: String) {
        self.userId = userId
        actionButton.isEnabled = userId != SendbirdChat.getCurrentUser()?.userId

        if userId == SendbirdChat.getCurrentUser()?.userId {
            self.userIdLabel.text = "\(userId) (You)"
        } else {
            self.userIdLabel.text = userId
        }

        self.profileImageView.image = SBUIconSet.iconUser.resize(with: CGSize(width: 20, height: 20)).sbu_with(tintColor: SBUColorSet.onlight01)
    }

    @IBAction func didTapActionButton(_ sender: Any) {
        SBUActionSheet.show(
            items: [
                SBUActionSheetItem(
                    title: userId,
                    color: SBUColorSet.ondark02,
                    font: SBUFontSet.body2,
                    textAlignment: .center
                ),
                SBUActionSheetItem(
                    title: "Remove",
                    color: SBUColorSet.ondark01,
                    font: SBUFontSet.subtitle1,
                    textAlignment: .center
                ) {
                    self.delegate?.removeUserFromHost(self.userId)
                }
            ],
            cancelItem: SBUActionSheetItem(
                title: SBUStringSet.Cancel,
                color: SBUColorSet.primary200,
                font: SBUFontSet.button2,
                textAlignment: .center
            ),
            oneTimetheme: .dark
        )
    }
}
extension UINavigationController {
    var previousViewController: UIViewController? {
       viewControllers.count > 1 ? viewControllers[viewControllers.count - 1] : nil
    }
}
