//
//  LoginViewController.swift
//  ByvManager
//
//  Created by Adrian Apodaca on 2/11/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ByvManager
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var passField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func save(_ sender: AnyObject) {
        self.view .endEditing(true)
        ByvAuth.login(mail: mailField.text!, password: passField.text!, background: false, success:{ (response) in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    @IBAction func close(_ sender: AnyObject) {
        self.view .endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func requestResetPassword(_ sender: AnyObject) {
        self.view .endEditing(true)
        ByvAuth.requestResetPassword(mail: mailField.text!, background: false, success:{ (response) in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func MagicLink(_ sender: AnyObject) {
        self.view .endEditing(true)
        ByvAuth.requestMagic(mail: mailField.text!, background: false, success:{ (response) in
            self.dismiss(animated: true, completion: nil)
        })
    }
}
