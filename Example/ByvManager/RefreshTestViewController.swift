//
//  RefreshTestViewController.swift
//  ByvManager
//
//  Created by Adrian Apodaca on 28/10/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ByvManager
import SwiftyJSON

class RefreshTestViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var timer:Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(self.loadRequests), userInfo: nil, repeats: true)
    }
    
    public func loadRequests() {
        
        let max = 10
        var count = 0
        var ok = 0
        
        for index in 1...max {
            let url = "\(url_profile())/deviceRequired?attemp=\(index)"
            self.textView.text = self.textView.text.appending("\n\(url) - try")
            ConManager.GET(url, params: nil, auth: true, success: { (responseData) in
                if let data = responseData?.data, JSON(data)["id"].int != nil {
                    self.textView.text = self.textView.text.appending("\n\(url) - ok")
                    ok += 1
                } else {
                    self.textView.text = self.textView.text.appending("\n\(url) - error")
                }
                
                }, failed: { (error) in
                    self.textView.text = self.textView.text.appending("\n\(url) - error")
                }, completion: { () in
                    count += 1
                    if count == max {
                        if (count == max) {
                            self.textView.text = self.textView.text.appending("\n\nTODOS OK!!!!")
                        } else {
                            self.textView.text = self.textView.text.appending("\n\n\(max-count) ERRORES!!!")
                        }
                    }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func close(_ sender: AnyObject) {
        timer?.invalidate()
        self.dismiss(animated: true, completion: nil)
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
