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
    private var webViewController: PanicWebViewController? = nil
    private var preViewController: UIViewController? = nil
    private var webUrl: String? = nil
    private var timer: Timer? = nil
    var inPanicMode: Bool = false
    
    public static func check() {
        Panic.instance.check()
    }
    
    public static func isInPanic() ->Bool {
        return Panic.instance.inPanicMode
    }
    
    public static func updatePreViewController(_ vc:UIViewController) {
        Panic.instance.preViewController = vc
    }
    
    @objc private func check() {
        if let url = Environment.absoluteUrl(Configuration.panicUrl()) {
            ConManager.GET(url, success: { response in
                if let data:Data = response?.data {
                    let json = JSON(data: data)
                    if let disabled: Bool = json["disabled"].bool, disabled == true {
                        //Disabled
                        if let _webUrl = Environment.absoluteUrl(json["disabledUrl"]) {
                            self.webUrl = _webUrl
                            self.showWeb()
                            self.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.check), userInfo: nil, repeats: false)
                        } else {
                            self.removeWebView()
                            return
                        }
                    } else if let minVersion: String = json["minVersion"].string, Device().appVersion!.isOlderThan(minVersion) {
                        //Older version
                        if let _webUrl = Environment.absoluteUrl(json["minVersionUrl"].stringValue) {
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
                }
            }, failed: { error in
                print("ERROR CHECKING PANIC MODE")
                debugPrint(error)
            })
        }
    }
    
    private func removeWebView() {
        inPanicMode = false
        if webViewController != nil {
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
            UIApplication.shared.windows[0].rootViewController = preViewController
            webViewController = nil
            webUrl = nil
        }
    }
    
    private func showWeb() {
        inPanicMode = true
        if webViewController == nil {
            if let webUrl = webUrl, let _url = URL(string: webUrl)  {
                webViewController = PanicWebViewController()
                webViewController?.webUrl = _url
                preViewController = UIApplication.shared.windows[0].rootViewController
                UIApplication.shared.windows[0].rootViewController = webViewController
            }
        }
    }
    
}
