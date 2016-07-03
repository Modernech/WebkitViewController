# WebkitViewController

[![CI Status](http://img.shields.io/travis/Masahiro Watanabe/WebkitViewController.svg?style=flat)](https://travis-ci.org/Masahiro Watanabe/WebkitViewController)
[![Version](https://img.shields.io/cocoapods/v/WebkitViewController.svg?style=flat)](http://cocoapods.org/pods/WebkitViewController)
[![License](https://img.shields.io/cocoapods/l/WebkitViewController.svg?style=flat)](http://cocoapods.org/pods/WebkitViewController)
[![Platform](https://img.shields.io/cocoapods/p/WebkitViewController.svg?style=flat)](http://cocoapods.org/pods/WebkitViewController)

WebkitViewController is a simple WKWebView-based WebViewController written purely in Swift.

 * Basic navigation functions such as Next, Back, Reload, Action.
 * Reacts to any orientation regardless of device type.

It tries to remain as minimum as what an in-app webView with basic function would be.

## Image
* Toolbar with Next, Back, Reload, Action buttons/
* Compatible with iPhone and iPad.
* Responds to rotation.

<img src="https://raw.githubusercontent.com/mshrwtnb/WebkitViewController/master/Images/Screenshot001.png" width="500" height="360">

## Example
```Swift
let URL = NSURL(string: "http://www.apple.com")
let webViewController = WebkitViewController(withURL: URL, withCachePolicy: nil, withTimeoutInterval: nil)
self.navigationController?.pushViewController(webViewController, animated: true)
```

## Requirements
* Swift 3.0 or later
* iOS 8.0 and later
* iPhone or iPad

## Settings
* Disable NSAppTransportSecurity for unlimited browsing.

## Installation
* [CocoaPods](http://cocoapods.org)

```ruby
pod "WebkitViewController"
```

* [Carthage](https://github.com/Carthage/Carthage)

```
Working on it.
```
## Author

Masahiro Watanabe, m@nsocean.org

## License

WebkitViewController is available under the MIT license. See the LICENSE file for more info.
