//
//  Environment.swift
//  Pods
//
//  Created by Adrian Apodaca on 26/10/16.
//
//

import Foundation

// MARK: - Environment

public enum Environment {
    case notDefinedEnvironment
    case developmentEnvironment
    case productionEnvironment
    
    public static var current =  Environment.notDefinedEnvironment
    
    func configBaseUrlKey() -> String {
        switch self {
        case .developmentEnvironment: return "baseUrl_development"
        case .productionEnvironment: return "baseUrl_production"
        case .notDefinedEnvironment: return "baseUrl"
        }
    }
    
    public func baseUrl() -> String {
        switch self {
        case .developmentEnvironment: return Configuration.baseUrl("development") as! String
        case .productionEnvironment: return Configuration.baseUrl("production") as! String
        case .notDefinedEnvironment: return Configuration.baseUrl("baseUrl") as! String
        }
    }
    
    public static func baseUrl() -> String {
        return current.baseUrl()
    }
}
