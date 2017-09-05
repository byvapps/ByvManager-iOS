//
//  ConfigurationManager.swift
//  Pods
//
//  Created by Adrian Apodaca on 26/10/16.
//
//

import Foundation

public struct Configuration {
    
    private static var dic: [String: Any]? = nil
    
    // MARK: - Configuration
    
    //
    // Configure with path
    //
    func configure(_ path: String) {
        if let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            Configuration.dic = dict
        } else {
            print("NO EXISTE EL FICHERO DE CONFIGURACIÓN EN LA RUTA <\(path)>!!!")
            fatalError()
        }
    }
    
    //
    // Configure with file name
    //
    public static func configure(_ fileName: String) {
        if let path: String = Bundle.main.path(forResource: fileName, ofType: "plist", inDirectory: nil) {
            Configuration().configure(path)
        } else {
            //CRASH
            print("NO EXISTE EL FICHERO DE CONFIGURACIÓN CON NOMBRE <\(fileName).plist>!!!")
            fatalError()
        }
    }
    
    public static func get(_ key: String) -> Any? {
        return Configuration.dic?[key]
    }
    
    public static func auth(_ key: String) -> Any? {
        return Configuration.getDic("auth")?[key]
    }
    
    public static func baseUrl(_ key: String) -> Any? {
        return Configuration.getDic("baseUrl")?[key]
    }
    
    public static func override(_ key: String) -> Any? {
        return Configuration.getDic("override")?[key]
    }
    
    public static func firebase(_ key: String) -> Any? {
        return Configuration.getDic("firebase")?[key]
    }
    
    public static func google(_ key: String) -> Any? {
        return Configuration.getDic("google")?[key]
    }
    
    public static func getDic(_ key: String) -> [String: Any]? {
        return Configuration.get(key) as? Dictionary <String, Any>
    }
    
    public static func panicUrl() -> String? {
        if let dic = Configuration.getDic("panic") {
            if Environment.current == .developmentEnvironment {
                return dic["development"] as? String
            } else {
                return dic["production"] as? String
            }
        }
        return nil
    }
    
    public static func pushModel(_ key: String) -> String? {
        if let push = Configuration.getDic("pushNotifications"), let models = push["models"] as? [String: String] {
            return models[key]
        }
        return nil
    }
    
    public static func pushAction(_ key: String) -> Dictionary <String, String>? {
        if let push = Configuration.getDic("pushNotifications"), let models = push["actions"] as? [String: [String: String]] {
            return models[key]
        }
        return nil
    }
}
