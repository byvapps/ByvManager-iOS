//
//  ByvAppDelegate.swift
//  Pods
//
//  Created by Adrian Apodaca on 28/10/16.
//
//

import UIKit

import UserNotifications

import ByvManager

import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseDynamicLinks
import BRYXBanner
import Google

open class ByvAppDelegate: UIResponder, UIApplicationDelegate {
    
    public var window: UIWindow?
    
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        ByvManager.configure()
        ByvManager.debugMode = true
        ByvManager.setEnvironment(.developmentEnvironment)
        
        if let firebase = Configuration.firebase("enabled"), firebase as? Bool == true {
            // Dynamic links
            if let CUSTOM_URL_SCHEME = Configuration.firebase("dynamic_link_custom_url") as? String {
                // Set deepLinkURLScheme to the custom URL scheme you defined in your
                // Xcode project.
                FIROptions.default().deepLinkURLScheme = CUSTOM_URL_SCHEME
            }
            
            //PUSH
            // [START register_for_notifications]
            if #available(iOS 10.0, *) {
                let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                UNUserNotificationCenter.current().requestAuthorization(
                    options: authOptions,
                    completionHandler: {_, _ in })
                
                // For iOS 10 display notification (sent via APNS)
                UNUserNotificationCenter.current().delegate = self
                // For iOS 10 data message (sent via FCM)
                FIRMessaging.messaging().remoteMessageDelegate = self
                
            } else {
                let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                application.registerUserNotificationSettings(settings)
            }
            
            application.registerForRemoteNotifications()
            
            // [END register_for_notifications]
            
            FIRApp.configure()
            
            // Add observer for InstanceID token refresh callback.
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.tokenRefreshNotification),
                                                   name: .firInstanceIDTokenRefresh,
                                                   object: nil)
        }
        
        self.setupGoogleAnalytics()
        
        return true
    }
    
    func setupGoogleAnalytics() {
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError? = nil
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        gai?.logger.logLevel = GAILogLevel.verbose  // remove before app release
    }
    
    open func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        ByvManager.didBecomeActive()
        
        // PUSH
        connectToFcm()
    }
    
    open func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        ByvManager.didBecomeInactive()
    }
    
    open func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // PUSH
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
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
                    ByvManager.checkUrl(u)
                }
                return false
            }
        }
        
        return ByvManager.checkUrl(url)
    }
    
    open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let url = userActivity.webpageURL!
        print("url: \(url)")
        print("dynamic_link_custom_url: \(Configuration.firebase("dynamic_link_custom_url")!)")
        if (Configuration.firebase("dynamic_link_custom_url") as? String) != nil {
            if let handled = (FIRDynamicLinks.dynamicLinks()?.handleUniversalLink(url) { (dynamiclink, error) in
                if let linkUrl = URL(string: self.parseDynamicLink(url)) {
                    ByvManager.checkUrl(linkUrl)
                }
                }), handled == true {
                return true
            } else {
                return ByvManager.checkUrl(url)
            }
        }
        return false
    }
    
    // MARK: - PUSH
    
    // [START receive_message]
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                          fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        // Print full message.
        print("\(userInfo)")
        
        self.makePushAction(userInfo: userInfo)
    }
    // [END receive_message]
    
    // [START refresh_token]
    @objc func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            Device.setPushId(refreshedToken)
        }
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    // [START connect_to_fcm]
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(String(describing: error))")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]
    
    func parseDynamicLink(_ url: URL) -> String {
        if let host = Configuration.firebase("dynamic_link_url") as? String, let hostUrl = URL(string: host), url.host == hostUrl.host {
            if let link = url.getQueryItemValueForKey("link") {
                return link
            }
        }
        return ""
    }
    
    func makePushAction(userInfo: [AnyHashable: Any]) {
        if !ByvManager.makePushAction(viewKey: userInfo["viewKey"] as? String, info: userInfo) {
            if let title = userInfo["title"] as? String, let body = userInfo["body"] as? String {
                let ac = UIAlertController(title: title, message: body, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: NSLocalizedString("cerrar", comment: ""), style: .cancel, handler: nil))
                ac.show()
            }
        }
    }
    
}

// PUSH

// [START ios_10_message_handling]
@available(iOS 10, *)
extension ByvAppDelegate : UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices. No silenciosos
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        // Print full message.
        print("%@", userInfo)
        
        if let title = userInfo["title"] as? String, let body = userInfo["body"] as? String {
            let banner = Banner(title: title, subtitle: body, backgroundColor:  UIColor(hex: 0x262527))
            //            banner.textColor = .black
            banner.dismissesOnSwipe = true
            banner.didTapBlock = {
                self.makePushAction(userInfo: userInfo)
            }
            banner.show(duration: 3.0)
        }
        
    }
}
extension ByvAppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices. Sileciosos
    public func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        let state = UIApplication.shared.applicationState
        print("State: \(state)")
        print(remoteMessage)
        print(remoteMessage.appData)
        if let modelKey = remoteMessage.appData["model"] as? String,
            let className = Configuration.pushModel(modelKey),
            let action = remoteMessage.appData["action"] as? String,
            let idStr = remoteMessage.appData["id"] as? String {
            let className = Bundle.main.infoDictionary!["CFBundleName"] as! String + "." + className
            if let grabbedClass = NSClassFromString(className) as? SilentPushModel.Type {
                grabbedClass.pushRecibed(id: Int(idStr)!, action: action, info: remoteMessage.appData)
            }
        }
    }
}
// [END ios_10_message_handling]



// Google Analytics
class ByvGA {
    public static func setUserId(_ userId:Int?) {
        var value:String? = nil
        if let userId = userId {
            value = "\(userId)"
        }
        GAI.sharedInstance().defaultTracker.set(kGAIUserId, value: value)
    }
    
    public static func sendEvent(category:String?, action:String?, label:String? = nil, value:NSNumber? = nil) {
        if let builder = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value) {
            GAI.sharedInstance().defaultTracker?.send(builder.build() as [NSObject : AnyObject])
        }
    }
}
