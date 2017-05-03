//
//  ByvAnalytics.swift
//  camionapp
//
//  Created by Koldo Ruiz on 6/4/17.
//  Copyright © 2017 CamionApp. All rights reserved.
//

import Foundation

class ByvAnalytics {
    
    static func callEvent(type: String, id: Int, action: String) {
        
        let urlString = "api/statsCount/\(type)/\(id)/\(action)"
        
        ConManager.POST(urlString, params: nil, auth: true, background: true, success: { (responseData) in
            
        }, failed: { (error) in
            print(error)
        })
    }
}
