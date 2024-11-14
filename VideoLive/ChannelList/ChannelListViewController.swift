//
//  ChannelListViewController.swift
//  VideoLive
//
//  Created by Tez Park on 11/14/24.
//

import UIKit
import SendbirdUIKit

class ChannelListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func onClickShowGroupChannelList(_ sender: Any) {
        let vc = SBUGroupChannelListViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onClickShowOpenChannelList(_ sender: Any) {
        let vc = SBUOpenChannelListViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
