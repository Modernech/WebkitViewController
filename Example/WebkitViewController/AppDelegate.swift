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
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let navigationController = UINavigationController(rootViewController: ExampleTableViewController(style: .Grouped))
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

