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
    
    // MARK: - AppDelegateMethods
    
    
    public class func didBecomeActive() {
        Device.setDeviceActive(true)
    }
    
    public class func didBecomeInactive() {
        Device.setDeviceActive(false)
    }
    
    @discardableResult
    public class func checkUrl(_ url: URL) -> Bool {
        if Auth.appOpenned(url) {
            return true
        }
        
        return false
    }
}

