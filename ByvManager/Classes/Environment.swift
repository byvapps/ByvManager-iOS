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
    
    public static func absoluteUrl(_ path: String?) -> String {
        if var temp = path {
            if !temp.contains("http") {
                if !temp.hasPrefix("/") {
                    temp = "/" + temp
                }
                temp = Environment.baseUrl() + temp
            }
            return temp
        }
        return ""
    }
    
    public static func getAbsoluteURL(_ url: String?) -> URL? {
        if let urlFinal = URL(string: Environment.absoluteUrl(url)) {
            return urlFinal
        } else {
            return URL(string: Environment.absoluteUrl(url?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)))
        }
    }
}
