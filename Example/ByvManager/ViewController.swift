//
//  ViewController.swift
//  ByvManager
//
//  Created by Adrian on 10/21/2016.
//  Copyright (c) 2016 Adrian. All rights reserved.
//

import UIKit
import ByvManager
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var tokenLbl: UILabel!
    @IBOutlet weak var profileTextView: UITextView!
    
    var socialWebView: SocialWebViewController = SocialWebViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        socialWebView.loadPreWeb()
        
        /*
        let token = FIRInstanceID.instanceID().token()
        print("InstanceID token: \(token!)")
 */
        
        /*
        URLShortener.short("http://www.google.com", spinner: nil) { (shortUrl) in
            print("shortUrl: \(shortUrl)")
            URLShortener.long(shortUrl, spinner: nil) { (longUrl) in
                print("longUrl: \(longUrl)")
            }
        }
        */
        
        ConManager.GET("api/search",
                       params: ["offset": 0,
                                "limit": 10],
                       auth: false,
                       background: false,
                       success: { (responseData) in
                        var pages = 0
                        var total = 0
                        if let pagesStr: String = responseData?.response?.allHeaderFields["X-Total-Pages"] as? String,
                            let pagesInt: Int = Int(pagesStr),
                            let totalStr: String = responseData?.response?.allHeaderFields["X-Total-Count"] as? String,
                            let totalInt: Int = Int(totalStr){
                            pages = pagesInt
                            total = totalInt
                        }
                        
                        print("START")
                        print("Pages: \(pages)")
                        print("Count: \(total)")
                        
                        let json = ConManager.jsonArray(responseData?.data)
                        
                        debugPrint(json)
                        print("END")
        });
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateView()
    }
    
    private func updateView() {
        tokenLbl.text = Credentials.token()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showProfile(_ sender: AnyObject) {
        let url = "\(url_profile())"
        self.profileTextView.text = ""
        ConManager.GET(url, params: nil, auth: true, background: false, success: { (responseData) in
            if let data = responseData?.data, let text: String = String(data: data, encoding: .utf8) {
                self.profileTextView.text = text
            }
            self.updateView()
        })
    }
    
    @IBAction func facebook(_ sender: AnyObject) {
        self.loginSocial(SocialType.facebook)
    }
    
    @IBAction func twitter(_ sender: AnyObject) {
        self.loginSocial(SocialType.twitter)
    }
    
    @IBAction func linkedin(_ sender: AnyObject) {
        self.loginSocial(SocialType.linkedin)
    }
    
    @IBAction func Google(_ sender: AnyObject) {
        self.loginSocial(SocialType.google)
    }
    
    @IBAction func logout(_ sender: Any) {
        Auth.logout(background: false, success: { (response) in
            self.updateView()
        })
    }
    
    func loginSocial(_ type: SocialType) {
        socialWebView.type = type
        let nav = UINavigationController(rootViewController: socialWebView)
        self.present(nav, animated: true, completion: nil)
    }
}

