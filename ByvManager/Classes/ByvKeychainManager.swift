//
//  ByvKeychainManager.swift
//  ByvManager
//
//  Created by Adrian Apodaca on 20/9/17.
//

import UIKit
import JNKeychain

class ByvKeychainManager: NSObject {
    static let sharedInstance = ByvKeychainManager()
    
    func getDeviceIdentifierFromKeychain() -> String {
        
        // try to get value from keychain
        var deviceUDID = self.keychain_valueForKey("keychainDeviceUDID") as? String
        if deviceUDID == nil {
            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                deviceUDID = uuid
            } else {
                deviceUDID = UUID().uuidString
            }
            // save new value in keychain
            self.keychain_setObject(deviceUDID! as AnyObject, forKey: "keychainDeviceUDID")
        }
        return deviceUDID!
    }
    
    // MARK: - Keychain
    
    func keychain_setObject(_ object: AnyObject, forKey: String) {
        let result = JNKeychain.saveValue(object, forKey: forKey)
        if !result {
            print("keychain saving: smth went wrong")
        }
    }
    
    func keychain_deleteObjectForKey(_ key: String) -> Bool {
        let result = JNKeychain.deleteValue(forKey: key)
        return result
    }
    
    func keychain_valueForKey(_ key: String) -> AnyObject? {
        let value = JNKeychain.loadValue(forKey: key)
        return value as AnyObject?
    }
}
