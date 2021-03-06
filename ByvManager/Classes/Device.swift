//
//  Device.swift
//  Pods
//
//  Created by Adrian Apodaca on 24/10/16.
//
//

import Foundation
import Alamofire
import SwiftyJSON

public struct Device {
    
    public static var autoResetBadge = true
    
    var deviceId: String?
    var uid: String
    var name: String?
    var os: String
    var osVersion: String
    var device: String
    var manufacturer: String
    var model: String
    var appVersion: String?
    var appVersionCode: String?
    var createdAt: Date?
    var updatedAt: Date?
    var active: Bool
    var lastConnectionStart: Date?
    var lastConnectionEnd: Date?
    var pushId: String?
    var badge: Int
    var languageCode: String?
    var preferredLang: String?
    var countryCode: String?
    var regionCode: String?
    var currencyCode: String?
    var timezone: String?
    
    // MARK: - init
    
    //
    // Init device. If stored get static data from Defaults, else get uid
    //
    public init() {
        var jsonStr:String = ""
        if let str = UserDefaults.standard.string(forKey: "deviceJsonData") {
            jsonStr = str
        }
        let stored = JSON(parseJSON: jsonStr)
        
        if let id = stored["_id"].string {
            self.deviceId = id
        }
        
        if let uid = stored["uid"].string {
            self.uid = uid
        } else {
            self.uid = ByvKeychainManager.sharedInstance.getDeviceIdentifierFromKeychain()
        }
        
        if let active = stored["active"].int{
            self.active = active == 1
        } else {
            self.active = true
        }
        
        if let badge = stored["badge"].int {
            self.badge = badge
        } else {
            self.badge = 0
        }
        
        if let pushId = stored["pushId"].string {
            self.pushId = pushId
        }
        
        if let preferredLang = stored["preferredLang"].string {
            self.preferredLang = preferredLang
        }
        
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let createdAt = stored["createdAt"].string {
            self.createdAt = formatter.date(from: createdAt)
        }
        
        if let updatedAt = stored["updatedAt"].string {
            self.updatedAt = formatter.date(from: updatedAt)
        }
        
        if let lastConnectionStart = stored["lastConnectionStart"].string {
            self.lastConnectionStart = formatter.date(from: lastConnectionStart)
        }
        
        if let lastConnectionEnd = stored["lastConnectionEnd"].string {
            self.lastConnectionEnd = formatter.date(from: lastConnectionEnd)
        }
        
        name = UIDevice.current.name
        os = "iOS"
        osVersion = UIDevice.current.systemVersion
        device = UIDevice.current.model
        manufacturer = "Apple"
        model = UIDevice.current.localizedModel
        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        appVersionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        languageCode = Locale.current.languageCode
        countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String
        regionCode = Locale.current.regionCode
        currencyCode = Locale.current.currencyCode
        timezone = TimeZone.current.identifier
    }
    
    // MARK: - private
    
    //
    // create or update in server
    //
    private func storeInServer() {
        var params: Params = self.parameters()
        if Device.autoResetBadge {
            params["badge"] = NSNumber(integerLiteral: 0)
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        var path: String
        var method: HTTPMethod
        if let deviceId = self.deviceId {
            method = .put
            path = "\(url_devices())/\(deviceId)"
        } else {
            method = .post
            path = url_devices()
        }
        
        ConManager.connection(path,
                              params: params,
                              method: method,
                              encoding: JSONEncoding.default,
                              success: { (responseData) in
                                if let data: Data = responseData?.data {
                                    do {
                                        let json = try JSON(data: data)
                                        self.store(json)
                                    } catch {
                                        
                                    }
                                }
        })
    }
    
    //
    // convert Device to Parameters
    //
    private func parameters() -> Parameters {
        var response: Parameters = Parameters()
        if let name = self.name {
            response["name"] = name
        }
        response["uid"] = uid
        response["active"] = active
        
        if let pushId = self.pushId {
            response["pushId"] = pushId
        }
        response["badge"] = badge
        response["os"] = os
        response["osVersion"] = osVersion
        response["device"] = device
        response["manufacturer"] = manufacturer
        response["model"] = model
        
        if let appVersion = self.appVersion {
            response["appVersion"] = appVersion
        }
        if let appVersionCode = self.appVersionCode {
            response["appVersionCode"] = appVersionCode
        }
        if let languageCode = self.languageCode {
            response["languageCode"] = languageCode
        }
        if let preferredLang = self.preferredLang {
            response["preferredLang"] = preferredLang
        }
        if let countryCode = self.countryCode {
            response["countryCode"] = countryCode
        }
        if let regionCode = self.regionCode {
            response["regionCode"] = regionCode
        }
        if let currencyCode = self.currencyCode {
            response["currencyCode"] = currencyCode
        }
        if let timezone = self.timezone {
            response["timezone"] = timezone
        }
        return response
    }
    
    private func store(_ json: JSON?) {
        if json?["_id"].string != nil {
            let defs = UserDefaults.standard
            defs.set(json?.rawString(), forKey: "deviceJsonData")
            defs.synchronize()
        } else {
            print("Error storing device Json")
        }
    }
    
    // MARK: - public static
    
    public static func setDeviceActive(_ active: Bool) {
        var device = Device()
        device.active = active
        device.badge = 0
        device.storeInServer()
    }
    
    public static func setPushId(_ pushId: String) {
        var device = Device()
        device.pushId = pushId
        device.storeInServer()
    }
}
