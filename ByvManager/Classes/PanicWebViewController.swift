//
//  PanicWebViewController.swift
//  Pods
//
//  Created by Adrian Apodaca on 11/5/17.
//
//

import UIKit
import ByvUtils

class PanicWebViewController: UIViewController, UIWebViewDelegate {

    public var webUrl:URL? = nil
    var webView: UIWebView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isOpaque = false
        self.view.addSubview(webView)
        let views = ["webView": webView]
        var allConstraints = [NSLayoutConstraint]()
        
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[webView]-0-|",
            options: [],
            metrics: nil,
            views: views)
        allConstraints += verticalConstraints
        
        webView.delegate = self
        
        let horizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[webView]-0-|",
            options: [],
            metrics: nil,
            views: views)
        allConstraints += horizontalConstraints
        
        NSLayoutConstraint.activate(allConstraints)
        
        if let webUrl = webUrl {
            webView.loadRequest(URLRequest(url: webUrl))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let host = request.url?.host {
            if let webUrl = webUrl, webUrl.absoluteString.contains(host) {
                return true
            }
        }
        
        if let url = request.url {
            UIApplication.shared.openURL(url)
        }
        
        return false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
