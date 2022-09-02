//
//  AppInfoViewController.swift
//  QuickStart
//
//  Created by Ernest Hong on 2022/09/30.
//

import UIKit
import SendbirdLiveSDK
import SendbirdUIKit

final class AppInfoViewController: UIViewController {
    
    @SBUThemeWrapper(theme: SBUTheme.userProfileTheme)
    private var theme: SBUUserProfileTheme
    
    private lazy var scrollView: UIScrollView = UIScrollView()
    
    private lazy var vStack: UIStackView = {
        let vStack = UIStackView()
        vStack.axis = .vertical
        return vStack
    }()
        
    private lazy var appIdView: SettingLabelView = {
        let appIdView = SettingLabelView()
        appIdView.updateUI(title: "Id", description: SendbirdLive.applicationId)
        return appIdView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Application information"
        
        view.backgroundColor = theme.backgroundColor
        
        view.addSubview(scrollView)
        scrollView.addSubview(vStack)
        
        vStack.addArrangedSubview(appIdView)
                
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            vStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            vStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            vStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
    
}
