//
//  Auth.swift
//  Pods
//
//  Created by Adrian Apodaca on 26/10/16.
//
//

import Foundation
import SwiftSpinner

public struct Auth {
    
    private static let client_id = Configuration.auth("byv_client_id") as! String
    private static let client_secret = Configuration.auth("byv_client_secret") as! String
    
    public static func register(mail: String,
                                password: String,
                                name: String? = nil,
                                spinner: String? = nil,
                                success: SuccessHandler? = nil,
                                failed: ErrorHandler? = nil,
                                completion: CompletionHandler? = nil) {
        let params: Params = ["client_id": client_id,
                              "client_secret": client_secret,
                              "grant_type": "signup",
                              "username": mail,
                                      "password": password,
                                      "name": name]
        ConManager.POST(url_token(),
                        params: params,
                        spinner: spinner,
                        success: { (response) in
                            debugPrint(ConManager.json(response))
                            if let cred = Credentials.store(response) {
                                success?(response)
                            } else {
                                let error:ConError = ConError(status: 500, error_id: "", error_description: "", localized_description: "auth response format incorrect", data: response)
                                SwiftSpinner.show(duration: 5.0, title: NSLocalizedString("Error", comment: "Spinner")).addTapHandler({
                                    SwiftSpinner.hide()
                                    }, subtitle: error.localized_description)
                                failed?(error)
                            }
                            
            }, failed: failed, completion: completion)
        
    }
    
    public static func login(mail: String,
                             password: String,
                             spinner: String? = nil,
                             success: SuccessHandler? = nil,
                             failed: ErrorHandler? = nil,
                             completion: CompletionHandler? = nil) {
        let params: Params = ["client_id": client_id,
                              "client_secret": client_secret,
                              "grant_type": "password",
                              "username": mail,
                              "password": password]
        
        ConManager.POST(url_token(),
                        params: params,
                        spinner: spinner,
                        success: { (response) in
                            debugPrint(ConManager.json(response))
                            if let cred = Credentials.store(response) {
                                success?(response)
                            } else {
                                let error:ConError = ConError(status: 500, error_id: "", error_description: "", localized_description: "auth response format incorrect", data: response)
                                SwiftSpinner.show(duration: 5.0, title: NSLocalizedString("Error", comment: "Spinner")).addTapHandler({
                                    SwiftSpinner.hide()
                                    }, subtitle: error.localized_description)
                                failed?(error)
                            }
            }, failed: failed, completion: completion)
    }
    
    public static func socialLogin(code: String,
                                     success: SuccessHandler? = nil,
                                     failed: ErrorHandler? = nil,
                                     completion: CompletionHandler? = nil) {
        let params: Params = ["client_id": client_id,
                              "client_secret": client_secret,
                              "grant_type": "code",
                              "code": code]
        
        ConManager.POST(url_token(),
                        params: params,
                        spinner: NSLocalizedString("Autenticando en el servidor...", comment: "Social Login Spinner"),
                        success: { (response) in
                            debugPrint(ConManager.json(response))
                            if let cred = Credentials.store(response) {
                                success?(response)
                            } else {
                                let error:ConError = ConError(status: 500, error_id: "", error_description: "", localized_description: "auth response format incorrect", data: response)
                                SwiftSpinner.show(duration: 5.0, title: NSLocalizedString("Error", comment: "Spinner")).addTapHandler({
                                    SwiftSpinner.hide()
                                    }, subtitle: error.localized_description)
                                failed?(error)
                            }
            }, failed: failed, completion: completion)
    }
    
    public static func requestMagic(mail: String,
                             spinner: String? = nil,
                             success: SuccessHandler? = nil,
                             failed: ErrorHandler? = nil,
                             completion: CompletionHandler? = nil) {
        let params: Params = ["email": mail]
        
        ConManager.POST(url_request_magic(),
                        params: params,
                        spinner: spinner,
                        success: { (response) in
                            success?(response)
                        }, failed: failed, completion: completion)
    }
    
    public static func appOpenned(_ url: String) -> Bool {
        let nsurl = NSURL(string: url)
        print("scheme: \(nsurl?.scheme)")
        print("host: \(nsurl?.host)")
        print("port: \(nsurl?.port)")
        print("path: \(nsurl?.path)")
        print("path components: \(nsurl?.pathComponents)")
        print("parameterString: \(nsurl?.parameterString)")
        print("query: \(nsurl?.query)")
        print("fragment: \(nsurl?.fragment)")
        return false
    }
    
    private func showCredentialError() {
        
    }
    
}
