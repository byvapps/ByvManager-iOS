//
//  FacebookWebViewController.swift
//  ByvManager
//
//  Created by Adrian Apodaca on 25/10/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ByvManager

class FacebookWebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let html = "<h1>CARGANDO...</h1><h1>CARGANDO...</h1><h1>CARGANDO...</h1><h1>CARGANDO...</h1><h1>CARGANDO...</h1><h1>CARGANDO...</h1><h1>CARGANDO...</h1><h1>CARGANDO...</h1><h1>CARGANDO...</h1><h1>CARGANDO...</h1><h1>CARGANDO...</h1>"
        webView.loadHTMLString(html, baseURL: nil)
        
        let url = URL(string: "\(Environment.baseUrl())/\(url_facebook_login())")!
        //let url = URL(string: "http://byvapps.com/playground/")!
        webView.delegate = self
        webView.loadRequest(URLRequest(url: url))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("URL: \(String(describing: request.url?.absoluteURL))")
        print("PATH: \(String(describing: request.url?.path))")
        
        let callbackPath = "/\(url_facebook_login())/\(url_social_callback())"
        print("callbackPath: \(callbackPath)")
        if request.url?.path == callbackPath {
            let urlComponents = NSURLComponents(string: request.url!.absoluteString)
            let queryItems = urlComponents?.queryItems
            
            var params: Dictionary <String, Any> = Dictionary()
            for item in queryItems! {
                params[item.name] = item.value
            }
            
            if let code = params["code"] as! String? {
                Auth.socialLogin(code: code, success: { (data) in
                    self.close(sender: nil)
                })
                
            }
            
            print("access_token: \(String(describing: params["access_token"]))")
            print("refresh_token: \(String(describing: params["refresh_token"]))")
            
            
            
            return true
        }
        
        
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("webViewDidStartLoad")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webViewDidFinishLoad")
        
        print("RESPUESTA: \(webView.stringByEvaluatingJavaScript(from: "getCredentials()")!)")
        

        let jsonData: String = webView.stringByEvaluatingJavaScript(from: "document.body.innerHTML")!
        if let json = try? JSONSerialization.jsonObject(with: jsonData.data(using: .utf8)!) {
            print("JSON: \(json)")
            self.close(sender: nil)
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("didFailLoadWithError: \(error)")
    }
    
    @IBAction func close(sender: UIBarButtonItem?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
