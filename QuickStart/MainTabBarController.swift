//
//  MainTabBarController.swift
//  QuickStart
//
//  Created by Ernest Hong on 2022/09/29.
//

import UIKit
import SendbirdUIKit
import SendbirdLiveUIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [
            UINavigationController(rootViewController: createEventListVC()),
            UINavigationController(rootViewController: createSettingVC()),
        ]
        delegate = self
    }
        
    private func createEventListVC() -> UIViewController {
        let eventListVC = LiveEventListViewController()
        eventListVC.tabBarItem = UITabBarItem(
            title: "Live events",
            image: UIImage(named: "iconLive")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "IconLiveSelected")?.withRenderingMode(.alwaysOriginal)
        )
        return eventListVC
    }
    
    private func createSettingVC() -> UIViewController {
        let settingVC = SettingViewController()
        settingVC.tabBarItem = UITabBarItem(
            title: "My settings",
            image: UIImage(named: "iconSettingsFilled")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "iconSettingsFilledSelected")?.withRenderingMode(.alwaysOriginal)
        )
        return settingVC
    }
}

// MARK: - UITabBarControllerDelegate

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        tabBarController.tabBar.isHidden = false
    }
}
