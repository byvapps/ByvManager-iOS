//
//  URLShortener.swift
//  Pods
//
//  Created by Adrian Apodaca on 2/11/16.
//
//

import Foundation

public struct URLShortener {
    
    private static let url: String = "https://www.googleapis.com/urlshortener/v1/url"
    
    public static func short(_ longUrl: String, background: Bool = true, completion: ((_ shortUrl: String) -> Void)? = nil ) {
        let key = Configuration.google("google_api_key")! // if not exist crash
        
        let params: Params = ["longUrl": longUrl]
        
        ConManager.POST("\(url)?key=\(key)",
                        params: params,
                        auth: false,
                        background: background,
                        success: { (response) in
                            if let json = response?.result.value as? [String: Any], let id: String = json["id"] as? String {
                                completion?(id)
                            }
                        },
                        failed: { (failed) in
                            completion?(longUrl)
                        })
    }
    
    public static func long(_ shortUrl: String, background: Bool = true, completion: ((_ shortUrl: String) -> Void)? = nil) {
        let key = Configuration.google("google_api_key")! // if not exist crash
        
        let params = ["shortUrl": shortUrl]
        
        ConManager.GET("\(url)?key=\(key)",
                        params: params,
                        auth: false,
                        background: background,
                        success: { (response) in
                            if let json = response?.result.value as? [String: Any], let longUrl: String = json["longUrl"] as? String {
                                completion?(longUrl)
                            }
            },
                        failed: { (failed) in
                            completion?(shortUrl)
        })
    }
}
