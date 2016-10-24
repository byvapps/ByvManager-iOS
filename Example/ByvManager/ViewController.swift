//
//  ViewController.swift
//  ByvManager
//
//  Created by Adrian on 10/21/2016.
//  Copyright (c) 2016 Adrian. All rights reserved.
//

import UIKit
import ByvManager

class ViewController: UIViewController {
    
    @IBOutlet weak var baseUrlLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        baseUrlLbl.text = ByvManager.sharedInstance.baseUrl
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

