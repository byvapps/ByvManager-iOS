//
//  Device.swift
//  Pods
//
//  Created by Adrian Apodaca on 24/10/16.
//
//

import Foundation



struct Device {
    var id: String?
    var uid: String?
    var name: String?
    var os: String?
    var osVersion: String?
    var device: String?
    var manufacturer: String?
    var model: String?
    var appVersion: String?
    var appVersionCode: String?
    var created_at: Double?
    var updated_at: Double?
    var active: Bool?
    var last_connection_start: Double?
    var last_connection_end: Double?
    var pushId: String?
    var badgue: Int?
    var languagueCode: String?
    var countyCode: String?
    var regionCode: String?
    var currencyCode: String?
    
    // MARK: - init
    
    //
    // Init device. If stored get static data from Defaults, else get uid
    //
    private init() {
        if let stored: Dictionary = UserDefaults.standard.object(forKey: "device") as! Dictionary<String, Any>? {
            id = stored["id"] as! String?
            uid = stored["uid"] as! String?
            created_at = stored["created_at"] as! Double?
            updated_at = stored["updated_at"] as! Double?
            active = stored["active"] as! Bool?
            last_connection_start = stored["last_connection_start"] as! Double?
            last_connection_end = stored["last_connection_end"] as! Double?
            pushId = stored["pushId"] as! String?
            badgue = stored["uid"] as! Int?
        } else {
            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                uid = uuid
            } else {
                uid = UUID().uuidString
            }
            active = true
            badgue = 0
        }
        
        name = UIDevice.current.name
        os = "iOS"
        osVersion = UIDevice.current.systemVersion
        device = UIDevice.current.model
        manufacturer = "Apple"
        model = UIDevice.current.localizedModel
        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        appVersionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        languagueCode = Locale.current.languageCode
        countyCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String
        regionCode = Locale.current.regionCode
        currencyCode = Locale.current.currencyCode
    }
    
    // MARK: - private
    
    //
    // create or update in server
    //
    private func storeInServer() {
        if let deviceId = self.id {
            //PUT
            
        } else {
            //POST
            
        }
    }
    
    // MARK: - public static
    
    public static func setDeviceActive(_ active: Bool) {
        var device = Device()
        device.active = active
        device.storeInServer()
    }
    
    public static func setPushId(_ pushId: String) {
        var device = Device()
        device.pushId = pushId
        device.storeInServer()
    }
    
    
}
