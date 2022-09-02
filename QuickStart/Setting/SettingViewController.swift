//
//  SettingViewController.swift
//  QuickStart
//
//  Created by Ernest Hong on 2022/09/29.
//

import UIKit
import SendbirdUIKit
import SendbirdLiveSDK

final class SettingViewController: UIViewController {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "My settings"
        return label
    }()
    
    private lazy var scrollView: UIScrollView = UIScrollView()
    
    private lazy var settingContentView = SettingContentView(
        signOutAction: { [weak self] in
            self?.didTouchSignOut()
        },
        appInfoAction: { [weak self] in
            self?.didTouchAppInfo()
        }
    )

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupStyles()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        
        view.addSubview(scrollView)
        scrollView.addSubview(settingContentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        settingContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingContentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            settingContentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            settingContentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            settingContentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            settingContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let user = SBUGlobals.currentUser {
            settingContentView.updateUI(user: user)
        }
    }
    
    private func setupStyles() {
        let theme = SBUTheme.channelListTheme
        
        let navigationBar = navigationController?.navigationBar
        navigationBar?.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor),
            for: .default
        )
        navigationBar?.shadowImage = UIImage.from(
            color: theme.navigationBarShadowColor
        )
        navigationController?.sbu_setupNavigationBarAppearance(
            tintColor: theme.navigationBarTintColor
        )
        
        view.backgroundColor = theme.backgroundColor
        titleLabel.tintColor = theme.leftBarButtonTintColor
        titleLabel.font = SBUFontSet.h1
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    }
    
    private func didTouchSignOut() {
        SendbirdLive.deauthenticate { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss(animated: true)
            }
        }
    }
    
    private func didTouchAppInfo() {
        let appInfoVC = AppInfoViewController()
        appInfoVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(appInfoVC, animated: true)
    }
}
