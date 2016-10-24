//
//  ByvManager.swift
//  Pods
//
//  Created by Adrian Apodaca on 21/10/16.
//
//

import Foundation

public enum Environment {
    case notDefinedEnvironment
    case developmentEnvironment
    case productionEnvironment
    
    func configBaseUrlKey() -> String {
        switch self {
            case .developmentEnvironment: return "baseUrl_development"
            case .productionEnvironment: return "baseUrl_production"
            case .notDefinedEnvironment: return "baseUr"
        }
    }
}

public class ByvManager {
    
    // MARK: - Singleton
    
    //
    // Access the singleton instance
    //
    public static let sharedInstance = ByvManager()
    
    public var baseUrl: String
    public var environment: Environment
    public var configuration: NSDictionary
    
    // MARK: - Init
    
    //
    // Custom init to build the spinner UI
    //
    private init() {
        baseUrl = ""
        environment = .notDefinedEnvironment
        configuration = NSDictionary()
    } //This prevents others from using the default '()' initializer for this class.
    
    
    // MARK: - Environment
    
    //
    // Set Environment
    //
    public class func setEnvironment(_ env: Environment) {
        if (sharedInstance.environment != env) {
            sharedInstance.environment = env
            let key = sharedInstance.environment.configBaseUrlKey()
            let dic = sharedInstance.configuration
            if let newUrl = dic[key] {
                sharedInstance.baseUrl = newUrl as! String
            } else {
                print("NO EXISTE LA BASE URL EN EL ARCHIVO DE CONFIGURACIÓN <\(key)>!!!")
                fatalError()
            }
        }
    }
    
    //
    // Get Environment
    //
    public class func getEnvironment() -> Environment {
        return sharedInstance.environment
    }
    
    
    // MARK: - Configure
    
    //
    // Configure with path
    //
    func configure(_ path: String) {
        if let dict = NSDictionary(contentsOfFile: path) {
            configuration = dict
            ByvManager.setEnvironment(.developmentEnvironment)
            print("baseUrl: \(baseUrl)")
        } else {
            print("NO EXISTE EL FICHERO DE CONFIGURACIÓN EN LA RUTA <\(path)>!!!")
            fatalError()
        }
    }
    
    //
    // Configure with file name
    //
    public class func configure(_ fileName: String) {
        if let path: String = Bundle.main.path(forResource: fileName, ofType: "plist", inDirectory: nil) {
            sharedInstance.configure(path)
        } else {
            //CRASH
            print("NO EXISTE EL FICHERO DE CONFIGURACIÓN CON NOMBRE <\(fileName).plist>!!!")
            fatalError()
        }
    }
    
    //
    // Configure with default file name "byv-config"
    //
    public class func configure(){
        ByvManager.configure("byv-config")
    }
    
    // MARK: - AppDelegateMethods
    
    //
    // Custom init to build the spinner UI
    //
    public class func didBecomeActive() {
        Device.setDeviceActive(true)
    }
}

