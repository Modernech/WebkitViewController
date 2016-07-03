//
//  AppDelegate.swift
//  WebkitViewController
//
//  Created by Masahiro Watanabe on 2016/04/30.
//  Copyright © 2016年 Masahiro Watanabe. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let navigationController = UINavigationController(rootViewController: ExampleTableViewController(style: .grouped))
        
        self.window = UIWindow(frame: UIScreen.main().bounds)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

