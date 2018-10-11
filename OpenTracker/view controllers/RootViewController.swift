//
//  RootViewController.swift
//  OpenTracker
//
//  Created by Alexander Skorulis on 12/10/18.
//  Copyright © 2018 Alexander Skorulis. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    let tabController = UITabBarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let home = HomeViewController()
        let history = HistoryViewController()
        
        home.title = "Home"
        history.title = "History"
        
        tabController.viewControllers = [home,history]
        
        tabController.view.frame = self.view.bounds
        tabController.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        self.addChild(tabController)
        self.view.addSubview(tabController.view)
        tabController.didMove(toParent: self)
    }
    

}
