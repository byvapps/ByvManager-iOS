//
//  Panic.swift
//  Pods
//
//  Created by Adrian Apodaca on 9/11/16.
//
//

import Foundation
import ByvUtils
import SwiftyJSON

public class Panic: NSObject, UIWebViewDelegate {

    private static var instance: Panic = Panic()
    private var webView: UIWebView? = nil
    private var webUrl: String? = nil
    private var timer: Timer? = nil
    var disabled: Bool = false
    
    public static func check() {
        Panic.instance.check()
    }
    
    @objc private func check() {
        if let url = Environment.absoluteUrl(Configuration.panicUrl()) {
            ConManager.GET(url, success: { response in
                let json = JSON(response?.data!)
                if let disabled: Bool = json["disabled"] as? Bool, disabled == true {
                    //Disabled
                    if let _webUrl = Environment.absoluteUrl(json["disabledUrl"]) {
                        self.webUrl = _webUrl
                        self.showWeb()
                        self.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.check), userInfo: nil, repeats: false)
                    } else {
                        self.removeWebView()
                        return
                    }
                } else if let minVersion: String = json["minVersion"] as? String, Device().appVersion!.isOlderThan(minVersion) {
                    //Older version
                    if let _webUrl = Environment.absoluteUrl(json["minVersionUrl"]) {
                        self.webUrl = _webUrl
                        self.showWeb()
                    } else {
                        self.removeWebView()
                        return
                    }
                } else {
                    self.removeWebView()
                    return
                }
            }, failed: { error in
                print("ERROR CHECKING PANIC MODE")
                debugPrint(error)
            })
        }
    }
    
    private func removeWebView() {
        if webView != nil {
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
            webView?.removeFromSuperview()
            webView = nil
            webUrl = nil
        }
    }
    
    private func showWeb() {
        if webView == nil {
            if let rootViewController = UIApplication.shared.windows[0].rootViewController, let webUrl = webUrl, let _url = URL(string: webUrl)  {
                webView = UIWebView(frame: rootViewController.view.frame)
                webView?.contentMode = UIViewContentMode.scaleToFill
                webView?.delegate = self
                webView?.loadRequest(URLRequest(url: _url))
                rootViewController.view.addSubview(webView!)
            }
            
        }
    }
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let host = request.url?.host {
            if webUrl!.contains(host) {
                return true
            }
        }
        
        if let url = request.url {
            UIApplication.shared.openURL(url)
        }
        
        return false
    }
}
