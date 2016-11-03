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
    
    public static func short(_ longUrl: String, spinner: String? = nil, completion: ((_ shortUrl: String) -> Void)? = nil ) {
        let key = Configuration.google("google_api_key")! // if not exist crash
        
        let params: Params = ["longUrl": longUrl]
        
        ConManager.POST("\(url)?key=\(key)",
                        params: params,
                        auth: false,
                        spinner: spinner,
                        success: { (response) in
                            let json = ConManager.json(response)
                            if let id: String = json["id"] as? String {
                                completion?(id)
                            }
                        },
                        failed: { (failed) in
                            completion?(longUrl)
                        })
    }
    
    public static func long(_ shortUrl: String, spinner: String?, completion: ((_ shortUrl: String) -> Void)? = nil) {
        let key = Configuration.google("google_api_key")! // if not exist crash
        
        let params = ["shortUrl": shortUrl]
        
        ConManager.GET("\(url)?key=\(key)",
                        params: params,
                        auth: false,
                        spinner: spinner,
                        success: { (response) in
                            let json = ConManager.json(response)
                            if let longUrl: String = json["longUrl"] as? String {
                                completion?(longUrl)
                            }
            },
                        failed: { (failed) in
                            completion?(shortUrl)
        })
    }
}
