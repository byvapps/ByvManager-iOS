//
//  ByvAppDelegate.swift
//  Pods
//
//  Created by Adrian Apodaca on 28/10/16.
//
//

import UIKit
import ByvManager
import FirebaseCore
import FirebaseDynamicLinks

open class ByvAppDelegate: UIResponder, UIApplicationDelegate {

    public var window: UIWindow?
    
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        ByvManager.configure()
        
        if let firebase = Configuration.firebase("enabled"), firebase as? Bool == true {
            // Dynamic links
            if let CUSTOM_URL_SCHEME = Configuration.firebase("dynamic_link_custom_url") as? String {
                // Set deepLinkURLScheme to the custom URL scheme you defined in your
                // Xcode project.
                FIROptions.default().deepLinkURLScheme = CUSTOM_URL_SCHEME
            }
            
            FIRApp.configure()
        }
        
        return true
    }
    
    open func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        ByvManager.didBecomeActive()
    }
    
    open func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        ByvManager.didBecomeInactive()
    }
    
    open func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    open func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    open func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }
    
    // MARK: - Open from URL
    
    open func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if (Configuration.firebase("dynamic_link_custom_url") as? String) != nil {
            let dynamicLink = FIRDynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url)
            if let dynamicLink = dynamicLink {
                // Is a dynamic link, probably for a first open
                if let u = dynamicLink.url {
                    return ByvManager.checkUrl(u)
                }
                return false
            }
        }
        
        return false
    }

}
