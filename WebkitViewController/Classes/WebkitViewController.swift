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
    
    func didTapToolbarButtonItem(_ item: UIBarButtonItem){
        switch(item){
        case self.backButton:
            webView.goBack()
            
        case self.forwardButton:
            webView.goForward()
            
        case self.reloadButton:
            webView.reload()
            
        case self.actionButton:
            guard let url = webView.url?.absoluteString else { return }
            let activity = UIActivityViewController(activityItems:[url], applicationActivities: nil)
            
            switch(UI_USER_INTERFACE_IDIOM()){
            case .phone:
                present(activity, animated: true, completion: nil)
                
            case .pad:
                let popover = UIPopoverController(contentViewController: activity)
                popover.present(from: item, permittedArrowDirections: .any, animated: true)
                
            default:
                ()
            }
            
        case self.doneButton:
            self.dismiss(animated: true, completion: nil)
            
        default:
            ()
        }
    }
    
    // MARK: KVO
    func startObservingWebViewEvents(){
        ObservedWebViewProperties.allValues.map { $0.rawValue }.forEach { webView.addObserver(self, forKeyPath: $0, options: .new, context: nil) }
    }
    
    func stopObservingWebViewEvents(){
        ObservedWebViewProperties.allValues.map { $0.rawValue }.forEach { webView.removeObserver(self, forKeyPath: $0) }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
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
            backButton.isEnabled = webView.canGoBack
            
        case ObservedWebViewProperties.canGoForward.rawValue:
            forwardButton.isEnabled = webView.canGoForward
            
        case ObservedWebViewProperties.loading.rawValue:
            reloadButton.isEnabled = !webView.isLoading
            UIApplication.shared().isNetworkActivityIndicatorVisible = webView.isLoading
            
        case ObservedWebViewProperties.title.rawValue:
            navigationItem.title = webView.title
            
        default:
            return
        }
    }
    
    // open links with target=“_blank”
    @objc(webView:createWebViewWithConfiguration:forNavigationAction:windowFeatures:) public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

public class WebkitViewController: UIViewController, WebkitProtocol {
    // MARK: Properties
    public lazy var webView: WKWebView = {
        let webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
        webView.contentMode = .redraw
        webView.isOpaque = true
        webView.allowsBackForwardNavigationGestures = true
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        return webView
    }()
    
    public lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.alpha = 0.0
        progressView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        return progressView
    }()
    
    public var URL: Foundation.URL?
    public var cachePolicy: NSURLRequest.CachePolicy
    public var timeoutInterval: TimeInterval
    
    public var backButton: UIBarButtonItem
    public var forwardButton: UIBarButtonItem
    public var reloadButton: UIBarButtonItem
    public var actionButton: UIBarButtonItem
    lazy public var doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    
    // MARK: Initializer
    public required init(withURL URL: Foundation.URL?, withCachePolicy cachePolicy: NSURLRequest.CachePolicy?, withTimeoutInterval timeoutInterval: TimeInterval?) {
        self.cachePolicy = cachePolicy != nil ? cachePolicy! : .reloadIgnoringLocalCacheData
        self.timeoutInterval = timeoutInterval != nil ? timeoutInterval! : 30.0
        
        let imageNamed = { (name: String) -> UIImage? in UIImage(named: name, in: Bundle(for: WebkitViewController.self), compatibleWith: nil) }
        
        self.backButton = UIBarButtonItem(image: imageNamed("backButton") , style: .plain, target: nil, action: nil)
        self.forwardButton = UIBarButtonItem(image: imageNamed("forwardButton"), style: .plain, target: nil, action: nil)
        self.reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)
        self.actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
        self.backButton.isEnabled = false
        self.forwardButton.isEnabled = false
        
        super.init(nibName: nil, bundle: nil)
        
        startObservingWebViewEvents()
        
        becomeToolbarItemsTarget()
        
        if let URL = URL {
            self.URL = URL
            let request = URLRequest(url: URL,
                                       cachePolicy: self.cachePolicy,
                                       timeoutInterval: self.timeoutInterval)
            webView.load(request)
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
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
        progressView.removeFromSuperview()
    }
    
    // MARK: Trait
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if wasPresented() {
            navigationItem.rightBarButtonItems = [doneButton]
        }
        
        let items = navigationToolbarItems()
        setToolbarItems(items, animated: false)
    }
    
    // MARK: WKNavigationDelegate - implement more if you like
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // It's kind of odd that we need JS to read loaded HTML?
        webView.evaluateJavaScript("document.body.innerHTML", completionHandler: {
            (html, error) in
            if let html = html {
                debugPrint(html)
            }
        })
    }
}

