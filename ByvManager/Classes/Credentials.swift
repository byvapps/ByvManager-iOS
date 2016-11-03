//
//  Credentials.swift
//  Pods
//
//  Created by Adrian Apodaca on 27/10/16.
//
//

import Foundation

public struct Credentials {
    var token_type: String = "bearer"
    var access_token: String
    var expires: Date = Date(timeIntervalSinceNow: 9999999*9999999)
    var refresh_token: String
    var data: Data
    
    init(_ data: Data) {
        self.data = data
        let json = ConManager.json(data)
        if let token_type = json[Credentials.tokenTypeKey()] as! String? {
            self.token_type = token_type
        }
        if let access_token = json[Credentials.accessTokenKey()] as! String? {
            self.access_token = access_token
        } else {
            self.access_token = ""
        }
        if let interval = json[Credentials.expiresKey()] as! Int? {
            self.expires = Date(timeIntervalSinceNow: TimeInterval(interval))
        }
        if let refresh_token = json[Credentials.refreshTokenKey()] as! String? {
            self.refresh_token = refresh_token
        } else {
             self.refresh_token = ""
        }
    }
    
    // MARK: - public
    
    @discardableResult
    public static func store(_ responseData: Data?) -> Credentials? {
        if let data = responseData {
            var credentials = Credentials(data)
            if credentials.access_token.characters.count > 0 {
                credentials.store()
                return credentials
            }
        }
        return nil
    }
    
    public static func store(_ cred: Credentials) {
        let defs = UserDefaults.standard
        defs.set(cred.data, forKey: "credentials")
        defs.synchronize()
    }
    
    public static func removeCredentials() {
        let defs = UserDefaults.standard
        defs.removeObject(forKey: "credentials")
        defs.synchronize()
    }
    
    public static func current() -> Credentials? {
        let defs = UserDefaults.standard
        if let data = defs.object(forKey: "credentials") as! Data? {
            return Credentials(data)
        }
        return nil
    }
    
    public static func token() -> String? {
        return Credentials.current()?.access_token
    }
    
    // MARK: - private
    
    private func store() {
        let defs = UserDefaults.standard
        defs.set(self.data, forKey: "credentials")
        defs.synchronize()
    }
    
    private static func accessTokenKey() -> String {
        if let path = Configuration.get("access_token") {
            return path as! String
        } else {
            return "access_token"
        }
    }
    
    private static func refreshTokenKey() -> String {
        if let path = Configuration.get("refresh_token") {
            return path as! String
        } else {
            return "refresh_token"
        }
    }
    
    private static func expiresKey() -> String {
        if let path = Configuration.get("expires") {
            return path as! String
        } else {
            return "expires"
        }
    }
    
    private static func tokenTypeKey() -> String {
        if let path = Configuration.get("token_type") {
            return path as! String
        } else {
            return "token_type"
        }
    }
}
