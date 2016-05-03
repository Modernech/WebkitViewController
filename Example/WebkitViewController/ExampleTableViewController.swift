//
//  ExampleTableViewController.swift
//  WebkitViewController
//
//  Created by Masahiro Watanabe on 2016/04/29.
//  Copyright © 2016年 Masahiro Watanabe. All rights reserved.
//

import UIKit
import WebkitViewController

class ExampleTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        cell.textLabel?.text = indexPath.row == 0 ? "Push" : "Present"
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let URL = NSURL(string: "http://www.apple.com")
        let webViewController = WebkitViewController(withURL: URL, withCachePolicy: nil, withTimeoutInterval: nil)
        
        if indexPath.row == 0 {
            self.navigationController?.pushViewController(webViewController, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: webViewController)
            self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
}
