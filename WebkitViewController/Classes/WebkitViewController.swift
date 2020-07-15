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

extension WebkitViewController {
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
  
  @objc func didTapToolbarButtonItem(_ item: UIBarButtonItem){
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
  
  override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
      UIApplication.shared.isNetworkActivityIndicatorVisible = webView.isLoading
      
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

open class WebkitViewController: UIViewController, WebkitProtocol {
  // MARK: Properties
  open var webView: WKWebView {
    return _webView
  }
  
  fileprivate var _webView: WKWebView
  
  //    public lazy var webView: WKWebView = {
  //        let webView = WKWebView(frame: CGRectZero, configuration: webViewConfiguration)
  //        webView.contentMode = .Redraw
  //        webView.opaque = true
  //        webView.allowsBackForwardNavigationGestures = true
  //        webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
  //        webView.navigationDelegate = self
  //        webView.UIDelegate = self
  //        return webView
  //    }()
  
  open lazy var progressView: UIProgressView = {
    let progressView = UIProgressView(progressViewStyle: .default)
    progressView.alpha = 0.0
    progressView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
    return progressView
  }()
  
  open var URL: Foundation.URL?
  open var cachePolicy: NSURLRequest.CachePolicy
  open var timeoutInterval: TimeInterval
  
  open var backButton: UIBarButtonItem
  open var forwardButton: UIBarButtonItem
  open var reloadButton: UIBarButtonItem
  open var actionButton: UIBarButtonItem
  lazy open var doneButton = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
  
  
  // MARK: Initializer
  public required init(withURL URL: Foundation.URL?, withWebViewConfiguration webViewConfiguration: WKWebViewConfiguration!,withCachePolicy cachePolicy: NSURLRequest.CachePolicy?, withTimeoutInterval timeoutInterval: TimeInterval?) {
    
    
    // WebView
    _webView = WKWebView(frame: CGRect.zero, configuration: webViewConfiguration)
    _webView.contentMode = .redraw
    _webView.isOpaque = true
    _webView.allowsBackForwardNavigationGestures = true
    _webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    
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
    
    _webView.navigationDelegate = self
    _webView.uiDelegate = self
    
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
  
  var hasTopNotch: Bool {
    if #available(iOS 13.0,  *) {
      return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0 > 20
    }else if #available(iOS 11.0, *) {
      return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }

    return false
  }
  
  var toolBarHeight: CGFloat {
    let toolHeight: CGFloat = (hasTopNotch ? 34.0 : 0)
    if let toolBar = self.navigationController?.toolbar {
      return toolHeight + toolBar.frame.size.height
    }
    return toolHeight
  }
  
  // MARK: Life Cycle
  override open func viewDidLoad() {
    super.viewDidLoad()
    definesPresentationContext = true
    progressView.frame = progressViewFrame()
    navigationController?.navigationBar.addSubview(progressView)
    if wasPresented() {
      self.navigationItem.rightBarButtonItems = [doneButton]
    }

    let items = navigationToolbarItems()
    self.setToolbarItems(items, animated: false)
    webView.frame = CGRect(x: view.frame.origin.x,
                           y: view.frame.origin.y,
                           width: view.frame.size.width,
                           height: view.frame.size.height - UIApplication.shared.statusBarFrame.size.height - toolBarHeight
                          )
    if #available(iOS 9.0, *) {
      webView.allowsLinkPreview = false
    }
    navigationController?.toolbar.barTintColor = UIColor.white
    self.navigationController?.navigationBar.isTranslucent = false
    view.addSubview(webView)
  }
  
  override open func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setToolbarHidden(false, animated: false)
  }
  
  override open func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setToolbarHidden(true, animated: false)
    progressView.removeFromSuperview()
  }
  
  // MARK: WKNavigationDelegate - implement more if you like
  open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    // It's kind of odd that we need JS to read loaded HTML?
    webView.evaluateJavaScript("document.body.innerHTML", completionHandler: {
      (html, error) in
      if let html = html {
        debugPrint(html)
      }
    })
  }
  
  open func webView(_ webView: WKWebView,
                    decidePolicyFor navigationAction: WKNavigationAction,
                    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void){
    decisionHandler(.allow)
  }
}
