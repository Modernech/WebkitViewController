//
//  WebkitProtocols+Extensions.swift
//  Pods
//
//  Created by Masahiro Watanabe on 2016/05/03.
//
//

import WebKit

typealias WebkitProtocol = protocol<WebkitBrowsable, WebkitNavigationable>

public protocol WebkitBrowsable: WKUIDelegate {
    var webView: WKWebView { get }
    var progressView: UIProgressView { get }
    
    var URL: Foundation.URL? { get }
    var cachePolicy: NSURLRequest.CachePolicy { get }
    var timeoutInterval: TimeInterval { get }
    
    init(withURL URL: Foundation.URL?, withCachePolicy cachePolicy: NSURLRequest.CachePolicy?, withTimeoutInterval timeoutInterval: TimeInterval?)
}

public extension WebkitBrowsable where Self: UIViewController {
    func progressViewFrame() -> CGRect {
        guard let navigationController = self.navigationController else { return CGRect.zero }
        
        let progressBarHeight: CGFloat = 2.0
        let navigationBarBounds = navigationController.navigationBar.bounds;
        let barFrame = CGRect(x: 0,
                                  y: navigationBarBounds.size.height - progressBarHeight,
                                  width: navigationBarBounds.size.width,
                                  height: progressBarHeight);
        return barFrame
    }
}

public protocol WebkitNavigationable: WKNavigationDelegate {
    var backButton: UIBarButtonItem { get }
    var forwardButton: UIBarButtonItem { get }
    var reloadButton: UIBarButtonItem { get }
    var actionButton: UIBarButtonItem { get }
    var doneButton: UIBarButtonItem { get }
}

public extension WebkitNavigationable where Self: UIViewController {
    func allToolbarItems() -> [UIBarButtonItem] {
        return [backButton, forwardButton, reloadButton, actionButton, doneButton]
    }
    
    func navigationToolbarItems() -> [UIBarButtonItem]? {
        switch(UI_USER_INTERFACE_IDIOM()){
        case .phone:
            // Vertical ? items for vertical layout : horizontal layout
            return traitCollection.verticalSizeClass == .regular ? toolbarItemsWithFlexibleSpace() : toolbarItemsWithFixedSpaceWidth(45.0)
            
        case .pad:
            return toolbarItemsWithFixedSpaceWidth(55.0)
            
        default:
            return nil
        }
    }
    
    func toolbarItemsWithFlexibleSpace() -> [UIBarButtonItem] {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let items = [backButton, flexibleSpace, forwardButton, flexibleSpace, reloadButton, flexibleSpace, actionButton]
        return items
    }
    
    func toolbarItemsWithFixedSpaceWidth(_ width: CGFloat) -> [UIBarButtonItem] {
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = width
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let items = [backButton, fixedSpace, forwardButton, fixedSpace, reloadButton, flexibleSpace, actionButton]
        return items
    }
}
