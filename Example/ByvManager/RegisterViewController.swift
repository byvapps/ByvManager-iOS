//
//  RegisterViewController.swift
//  ByvManager
//
//  Created by Adrian Apodaca on 26/10/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ByvManager

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func save(_ sender: AnyObject) {
        self.view.endEditing(true)
        ByvAuth.register(mail: mailField.text!, password: passField.text!, name: nameField.text!, background: false, success:{ (response) in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    @IBAction func close(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}
