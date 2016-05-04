///
//  WebViewController.swift
//  WebkitViewController
//
//  Created by Masahiro Watanabe on 2016/04/30.
//  Copyright © 2016年 Masahiro Watanabe. All rights reserved.
//

import UIKit
import WebKit

public enum ObservedWebViewProperties: String {
    case estimatedProgress
    case canGoBack
    case canGoForward
    case loading
    case title
    static let allValues = [estimatedProgress, canGoBack, canGoForward, loading, title]
}

public extension WebkitViewController {
    func wasPresented() -> Bool {
        return navigationController?.viewControllers.count == 1 &&
            navigationController?.viewControllers[0] == self
    }
    
    func becomeToolbarItemsTarget(){
        allToolbarItems().forEach {
            $0.target = self
            $0.action = #selector(didTapToolbarButtonItem(_:))
        }
    }
    
    func didTapToolbarButtonItem(item: UIBarButtonItem){
        switch(item){
        case self.backButton:
            webView.goBack()
            
        case self.forwardButton:
            webView.goForward()
            
        case self.reloadButton:
            webView.reload()
            
        case self.actionButton:
            guard let url = webView.URL?.absoluteString else { return }
            let activity = UIActivityViewController(activityItems:[url], applicationActivities: nil)
            
            switch(UI_USER_INTERFACE_IDIOM()){
            case .Phone:
                presentViewController(activity, animated: true, completion: nil)
                
            case .Pad:
                let popover = UIPopoverController(contentViewController: activity)
                popover.presentPopoverFromBarButtonItem(item, permittedArrowDirections: .Any, animated: true)
                
            default:
                ()
            }
            
        case self.doneButton:
            self.dismissViewControllerAnimated(true, completion: nil)
            
        default:
            ()
        }
    }
    
    // MARK: KVO
    func startObservingWebViewEvents(){
        ObservedWebViewProperties.allValues.map { $0.rawValue }.forEach { webView.addObserver(self, forKeyPath: $0, options: .New, context: nil) }
    }
    
    func stopObservingWebViewEvents(){
        ObservedWebViewProperties.allValues.map { $0.rawValue }.forEach { webView.removeObserver(self, forKeyPath: $0) }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let webView = object as? WKWebView else { return }
        guard let keyPath = keyPath else { return }
        
        switch(keyPath) {
        case ObservedWebViewProperties.estimatedProgress.rawValue:
            progressView.alpha = 1.0
            progressView.progress = Float(webView.estimatedProgress)
            if progressView.progress == 1.0 {
                progressView.progress = 0.0
                progressView.alpha = 0.0
            }
            
        case ObservedWebViewProperties.canGoBack.rawValue:
            backButton.enabled = webView.canGoBack
            
        case ObservedWebViewProperties.canGoForward.rawValue:
            forwardButton.enabled = webView.canGoForward
            
        case ObservedWebViewProperties.loading.rawValue:
            reloadButton.enabled = !webView.loading
            UIApplication.sharedApplication().networkActivityIndicatorVisible = webView.loading
            
        case ObservedWebViewProperties.title.rawValue:
            navigationItem.title = webView.title
            
        default:
            return
        }
    }
}

public class WebkitViewController: UIViewController, WebkitProtocol {
    // MARK: Properties
    public lazy var webView: WKWebView = {
        let webView = WKWebView(frame: CGRectZero, configuration: WKWebViewConfiguration())
        webView.contentMode = .Redraw
        webView.opaque = true
        webView.allowsBackForwardNavigationGestures = true
        webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        webView.navigationDelegate = self
        webView.UIDelegate = self
        return webView
    }()
    
    public lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .Default)
        progressView.alpha = 0.0
        progressView.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
        return progressView
    }()
    
    public var URL: NSURL?
    public var cachePolicy: NSURLRequestCachePolicy
    public var timeoutInterval: NSTimeInterval
    
    public var backButton: UIBarButtonItem
    public var forwardButton: UIBarButtonItem
    public var reloadButton: UIBarButtonItem
    public var actionButton: UIBarButtonItem
    lazy public var doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil)
    
    // MARK: Initializer
    public required init(withURL URL: NSURL?, withCachePolicy cachePolicy: NSURLRequestCachePolicy?, withTimeoutInterval timeoutInterval: NSTimeInterval?) {
        self.cachePolicy = cachePolicy != nil ? cachePolicy! : .ReloadIgnoringLocalCacheData
        self.timeoutInterval = timeoutInterval != nil ? timeoutInterval! : 30.0
        
        let imageNamed = { (name: String) -> UIImage? in UIImage(named: name, inBundle: NSBundle(forClass: WebkitViewController.self), compatibleWithTraitCollection: nil) }
        
        self.backButton = UIBarButtonItem(image: imageNamed("backButton") , style: .Plain, target: nil, action: nil)
        self.forwardButton = UIBarButtonItem(image: imageNamed("forwardButton"), style: .Plain, target: nil, action: nil)
        self.reloadButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: nil, action: nil)
        self.actionButton = UIBarButtonItem(barButtonSystemItem: .Action, target: nil, action: nil)
        self.backButton.enabled = false
        self.forwardButton.enabled = false
        
        super.init(nibName: nil, bundle: nil)
        
        startObservingWebViewEvents()
        
        becomeToolbarItemsTarget()
        
        if let URL = URL {
            self.URL = URL
            let request = NSURLRequest(URL: URL,
                                       cachePolicy: self.cachePolicy,
                                       timeoutInterval: self.timeoutInterval)
            webView.loadRequest(request)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        stopObservingWebViewEvents()
    }
    
    // MARK: Life Cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        progressView.frame = progressViewFrame()
        navigationController?.navigationBar.addSubview(progressView)
        
        webView.frame = view.frame
        view.addSubview(webView)
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
        progressView.removeFromSuperview()
    }
    
    // MARK: Trait
    override public func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if wasPresented() {
            navigationItem.rightBarButtonItems = [doneButton]
        }
        
        let items = navigationToolbarItems()
        setToolbarItems(items, animated: false)
    }
    
    // MARK: WKNavigationDelegate - implement more if you like
    public func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        // It's kind of odd that we need JS to read loaded HTML?
        webView.evaluateJavaScript("document.body.innerHTML", completionHandler: {
            (html, error) in
            if let html = html {
                debugPrint(html)
            }
        })
    }
}

