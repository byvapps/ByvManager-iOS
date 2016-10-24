//
//  ByvManager.swift
//  Pods
//
//  Created by Adrian Apodaca on 21/10/16.
//
//

import Foundation

public class ByvManager {
    
    // MARK: - Singleton
    
    //
    // Access the singleton instance
    //
    public static let sharedInstance = ByvManager()
    
    public var baseUrl: String
    public var initialized: Bool = false;
    
    // MARK: - Init
    
    //
    // Custom init to build the spinner UI
    //
    private init() {
        baseUrl = ""
    } //This prevents others from using the default '()' initializer for this class.
    
    // MARK: - Configure
    
    //
    // Configure with path
    //
    func configure(_ path: String) {
        if let dict = NSDictionary(contentsOfFile: path) {
            // Use your dict here
            initialized = true
            baseUrl = dict["baseUrl"] as! String
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
        
    }
}

