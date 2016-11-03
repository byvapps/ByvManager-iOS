//
//  AppDelegate.swift
//  ByvManager
//
//  Created by Adrian on 10/21/2016.
//  Copyright (c) 2016 Adrian. All rights reserved.
//

import UIKit
import ByvManager


@UIApplicationMain
class AppDelegate: ByvAppDelegate {
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Auth.appOpenned("https://ra4bt.app.goo.gl/?link=http%3A%2F%2F138.68.136.65%2Fauth-password%2Fmagic%2Fcallback%3Femail%3Dadrian%40byvapps.com&al=byvplayground%3A%2F%2F138.68.136.65%2Fauth-password%2Fmagic%2Fcallback%3Femail%3Dadrian%40byvapps.com&apn=com.byvapps.android.ByvManager-Example&isi=1172311246&ibi=com.byvapps.ByvManager-Example&ius=byvplayground&ifl=http%3A%2F%2F138.68.136.65%2Fauth-password%2Fmagic%2Fcallback%3Femail%3Dadrian%40byvapps.com")
        Auth.appOpenned("http%3A%2F%2F138.68.136.65%2Fauth-password%2Fmagic%2Fcallback%3Femail%3Dadrian%40byvapps.com")
        if super.application(application, didFinishLaunchingWithOptions: launchOptions) {
            
            ByvManager.setEnvironment(.productionEnvironment)
            
            return true
        }
        
        return false
    }

}
