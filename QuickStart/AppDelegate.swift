//
//  AppDelegate.swift
//  QuickStart
//
//  Created by Minhyuk Kim on 2022/08/29.
//

// SBUView
// SBULifeCycle
// sbu_constraints

// let a = SBUChannelViewController()
// -> view model -> SendbirdChat / SendbirdUI reference

// set current user
// call SendbirdUI.connect

// 화면 로딩할때마다 update user info (렌더링 하는 부분들만)
// -> 유저가 다르면? -> 에러뱉고 끝

// view model initialize할떄 SendbirdUI.connectIfNeeded -> current User 확인 & connect


import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

