//
//  ByvManager.swift
//  Pods
//
//  Created by Adrian Apodaca on 21/10/16.
//
//

import Foundation
import SVProgressHUD
import ByvModalNav
import ByvUtils

public protocol PushActionController {
    func loadFromPush(info: [AnyHashable : Any], completion: ((Bool) -> Void)?)
}

public protocol SilentPushModel {
    static func pushRecibed(id: Int, action: String, info: [AnyHashable : Any])
}

// MARK: - Global Notifications

public struct ByvNotifications {
    public static let login = Notification.Name("ByvNotificationLogin")
    public static let logout = Notification.Name("ByvNotificationLogout")
    public static let credUpdated = Notification.Name("ByvNotificationCredentialsUpdated")
}

// MARK: - ByvManager

public class ByvManager {
    
    //public static let sockets = Sockets()
    public static var debugMode = false
    
    // MARK: - Singleton
    
    //
    // Access the singleton instance
    //
    public static let sharedInstance = ByvManager()
    
    // MARK: - Init
    
    //
    // Custom init to build the spinner UI
    //
    private init() {
        
    } //This prevents others from using the default '()' initializer for this class.
    
    // MARK: - Environment
    
    //
    // Set Environment
    //
    public class func setEnvironment(_ env: Environment) {
        if Environment.current != env {
            Environment.current = env
            if ByvManager.debugMode {
                print("New baseUrl: \(Environment.baseUrl())")
            }
        }
    }
    
    //
    // Configure with file name
    //
    public class func configure(_ fileName: String) {
        Configuration.configure(fileName)
    }
    
    //
    // Configure with default file name "byv-config"
    //
    public class func configure() {
        Configuration.configure("byv-config")
    }
    
    // MARK: - AppDelegateMethods
    
    
    public class func didBecomeActive() {
        Device.setDeviceActive(true)
        //ByvManager.sockets.connect()
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.setMinimumDismissTimeInterval(3.0)
        
        Panic.check()
    }
    
    public class func didBecomeInactive() {
        Device.setDeviceActive(false)
        //ByvManager.sockets.disconnect()
        
        NotificationCenter.default.removeObserver(ByvManager.sharedInstance, name:  Notification.Name("SVProgressHUDDidReceiveTouchEventNotification"), object: nil)
    }
    
    @discardableResult
    public class func checkUrl(_ url: URL) -> Bool {
        if ByvAuth.appOpenned(url) {
            return true
        }
        
        return false
    }
    
    @discardableResult
    public class func makePushAction(viewKey: String?, info: [AnyHashable : Any]) -> Bool {
        if let viewKey = viewKey, let action = Configuration.pushAction(viewKey) {
            var vc:PushActionController? = nil
            if let storyName = action["storyBoardName"], let storyId = action["storyBoardId"] {
                let story = UIStoryboard(name: storyName, bundle: nil)
                vc = story.instantiateViewController(withIdentifier: storyId) as? PushActionController
            } else if let className = action["viewControllerClass"] {
                let className = Bundle.main.infoDictionary!["CFBundleName"] as! String + "." + className
                if let grabbedClass = NSClassFromString(className) as? UIViewController.Type {
                    vc = grabbedClass.init() as? PushActionController
                }
            }
            
            if vc != nil {
                SVProgressHUD.show()
                vc?.loadFromPush(info: info, completion: { (correct) in
                    if correct {
                        SVProgressHUD.dismiss()
                        let modal = ByvModalNav(rootViewController: vc as! UIViewController)
                        modal.onlyInRoot = false
                        UIViewController.presentFromVisibleViewController(modal, animated: true, completion: nil)
                    } else {
                        SVProgressHUD.showError(withStatus: NSLocalizedString("Error cargando el contenido", comment: ""))
                    }
                })
                return true
            }
        }
        return false
    }
}
