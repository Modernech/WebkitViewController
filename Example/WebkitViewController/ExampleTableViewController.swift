//
//  ExampleTableViewController.swift
//  WebkitViewController
//
//  Created by Masahiro Watanabe on 2016/04/29.
//  Copyright © 2016年 Masahiro Watanabe. All rights reserved.
//

import UIKit
import WebKit
import WebkitViewController

class ExampleTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = (indexPath as NSIndexPath).row == 0 ? "Push" : "Present"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let configuration = WKWebViewConfiguration()
        let URL = Foundation.URL(string: "http://news.google.com")
        let webViewController = WebkitViewController(withURL: URL, withWebViewConfiguration: configuration, withCachePolicy: nil, withTimeoutInterval: nil)
        
        if (indexPath as NSIndexPath).row == 0 {
            self.navigationController?.pushViewController(webViewController, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: webViewController)
            self.navigationController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
}
