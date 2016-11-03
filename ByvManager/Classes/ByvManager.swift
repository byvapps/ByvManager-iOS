//
//  ByvManager.swift
//  Pods
//
//  Created by Adrian Apodaca on 21/10/16.
//
//

import Foundation

// MARK: - ByvManager

public class ByvManager {
    
    // MARK: - Singleton
    
    //
    // Access the singleton instance
    //
    public static let sharedInstance = ByvManager()
    
    public var configuration: NSDictionary
    private var urls: Dictionary <String, String>
    
    // MARK: - Init
    
    //
    // Custom init to build the spinner UI
    //
    private init() {
        configuration = NSDictionary()
        urls = ["DEVICES_URL":"api/devices",
                 "REGISTER_URL":"api/users",
                 "LOGIN_URL":"auth/token",
                 "REFRESH_TOKEN_URL":"auth/token",
                 "FACBEBOOK_URL":"auth/facebook/app",
                 "TWITTER_URL":"auth/twitter/app",
                 "LINKEDIN_URL":"auth/linkedind/app",
                 "GOOGLE_URL":"auth/google/app",
                 "SOCIAL_SUCCESS_URL":"/auth/webapp/success",
                 "LOGOUT_URL":"/auth/logout"]
    } //This prevents others from using the default '()' initializer for this class.
    
    
    // MARK: - Environment
    
    //
    // Set Environment
    //
    public class func setEnvironment(_ env: Environment) {
        if Environment.current != env {
            Environment.current = env
            print("New baseUrl: \(Environment.baseUrl())")
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
    
    //
    // Get Environment
    //
    public class func getEnvironment() -> Environment {
        return Environment.current
    }
    
    
    public class func path(_ resource: String) -> String? {
        return sharedInstance.urls[resource]! as String
    }
    
    public class func baseUrl() -> String {
        return Environment.baseUrl()
    }
    
    // MARK: - AppDelegateMethods
    
    
    public class func didBecomeActive() {
        Device.setDeviceActive(true)
    }
    
    public class func didBecomeInactive() {
        Device.setDeviceActive(false)
    }
    
    public class func checkUrl(_ url: URL) -> Bool {
        
        return false
    }
}

