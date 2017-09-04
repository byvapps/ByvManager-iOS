//
//  SocialWebViewController.swift
//  Pods
//
//  Created by Adrian Apodaca on 28/10/16.
//
//

import UIKit
import SVProgressHUD

public enum SocialType {
    case facebook
    case twitter
    case linkedin
    case google
    
    func title() -> String {
        switch self {
        case .facebook: return "Facebook"
        case .twitter: return "Twitter"
        case .linkedin: return "Linkedin"
        case .google: return "Google"
        }
    }
    
    func path() -> String {
        switch self {
        case .facebook: return url_facebook_login()
        case .twitter: return url_twitter_login()
        case .linkedin: return url_linkedin_login()
        case .google: return url_google_login()
        }
    }
    
    func codeKey() -> String {
        switch self {
        case .facebook: return "code"
        case .twitter: return "oauth_token"
        case .linkedin: return "code"
        case .google: return "code"
        }
    }
}

public class SocialWebViewController: UIViewController, UIWebViewDelegate {
    private let html = "<!DOCTYPE html><html><head><style>body {text-align: center;font-family: sans-serif;color: #555;}.loader {border: 5px solid #f3f3f3;border-radius: 50%;border-top: 5px solid #888;width: 50px;height: 50px;margin: auto;margin-top: 20%;-webkit-animation: spin 2s linear infinite;animation: spin 1.4s linear infinite;}@-webkit-keyframes spin {0% { -webkit-transform: rotate(0deg); }100% { -webkit-transform: rotate(360deg); }}@keyframes spin {0% { transform: rotate(0deg); }100% { transform: rotate(360deg); }}</style></head><body><div class=\"loader\"></div></body></html>"
    private var _type: SocialType = .facebook
    
    public var type: SocialType {
        get {
            return _type
        }
        set (newType) {
            _type = newType
            self.navigationItem.title = _type.title()
        }
    }
    
    
    private var webView: UIWebView = UIWebView()
    private var _code: String? = nil
    
    public func loadPreWeb() {
        
        webView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(webView)
        
        let v: UIView = webView
        
        let views = ["view": v]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options:[], metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: views)
        
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
        
        if self.navigationController?.viewControllers[0] == self {
            let bi = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action:  #selector(self.close(sender:)))
            self.navigationItem.rightBarButtonItem = bi
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _code = nil
        webView.alpha = 1.0
        let url = "\(Environment.baseUrl())/\(type.path())"
        self.webView.delegate = self
        self.webView.loadRequest(URLRequest(url: URL(string: url)!))
        
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if ByvManager.debugMode {
            print("URL: \(String(describing: request.url?.absoluteURL))")
            print("PATH: \(String(describing: request.url?.path))")
        }
        
        let callbackPath = "/\(type.path())/\(url_social_callback())"
        if ByvManager.debugMode {
            print("callbackPath: \(callbackPath)")
        }
        if request.url?.path == callbackPath {
            let urlComponents = NSURLComponents(string: request.url!.absoluteString)
            let queryItems = urlComponents?.queryItems
            
            var params: [String: Any] = [:]
            for item in queryItems! {
                params[item.name] = item.value
            }
            
            if let code = params[self.type.codeKey()] as! String? {
                _code = code
                webView.alpha = 0.0
            }
            return true
        }
        return true
    }
    
    public func webViewDidStartLoad(_ webView: UIWebView) {
//        print("webViewDidStartLoad")
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        
        if let code = _code {
            Auth.socialLogin(code: code, background: false, success: { (data) in
                self.close(sender: nil)
            })
            _code = nil
        }
        
//        print("webViewDidFinishLoad")
//        
//        print("RESPUESTA: \(webView.stringByEvaluatingJavaScript(from: "getCredentials()")!)")
//        
//        
//        let jsonData: String = webView.stringByEvaluatingJavaScript(from: "document.body.innerHTML")!
//        if let json = try? JSONSerialization.jsonObject(with: jsonData.data(using: .utf8)!) {
//            print("JSON: \(json)")
//            self.close(sender: nil)
//        }
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        SVProgressHUD.showError(withStatus: NSLocalizedString("Error", comment: "Spinner"))
    }

    func close(sender: UIBarButtonItem?) {
        webView.loadHTMLString(html, baseURL: nil)
        if self.navigationController?.viewControllers[0] == self {
            self.dismiss(animated: true, completion: nil)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}
