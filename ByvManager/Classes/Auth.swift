//
//  Auth.swift
//  Pods
//
//  Created by Adrian Apodaca on 26/10/16.
//
//

import Foundation
import SVProgressHUD
import ByvUtils

public struct Auth {
    
    private static let client_id = Configuration.auth("byv_client_id") as! String
    private static let client_secret = Configuration.auth("byv_client_secret") as! String
    
    private static func authToken(params: Params,
                                  background: Bool = true,
                                  success: SuccessHandler? = nil,
                                  failed: ErrorHandler? = nil,
                                  completion: CompletionHandler? = nil) {
        ConManager.POST(url_token(),
                        params: params,
                        background: background,
                        success: { (response) in
                            if Credentials.store(response?.data) != nil {
                                success?(response)
                            } else {
                                let error:ConError = ConError(status: 500, error_id: "", error_description: "", localized_description: "auth response format incorrect", response: response)
                                
                                SVProgressHUD.showError(withStatus: error.localized_description)
                                failed?(error)
                            }
                            
        }, failed: failed, completion: completion)
    }
    
    public static func register(mail: String,
                                password: String,
                                name: String? = nil,
                                background: Bool = true,
                                success: SuccessHandler? = nil,
                                failed: ErrorHandler? = nil,
                                completion: CompletionHandler? = nil) {
        var params: Params = ["client_id": client_id,
                              "client_secret": client_secret,
                              "grant_type": "signup",
                              "username": mail,
                              "password": password]
        if let name:String = name {
            params["name"] = name
        }
        
        Auth.authToken(params: params, background: background, success: success, failed: failed, completion: completion)
    }
    
    public static func login(mail: String,
                             password: String,
                             background: Bool = true,
                             success: SuccessHandler? = nil,
                             failed: ErrorHandler? = nil,
                             completion: CompletionHandler? = nil) {
        let params: Params = ["client_id": client_id,
                              "client_secret": client_secret,
                              "grant_type": "password",
                              "username": mail,
                              "password": password]
        
        Auth.authToken(params: params, background: background, success: success, failed: failed, completion: completion)
    }
   
    public static func logout(background: Bool = true,
                             success: SuccessHandler? = nil,
                             failed: ErrorHandler? = nil,
                             completion: CompletionHandler? = nil) {
        
        ConManager.POST(url_logout(),
                        params: nil,
                        auth: true,
                        background: background,
                        success: { (response) in
                            Credentials.removeCredentials()
                            success?(response)
        }, failed: failed, completion: completion)
    }

    
    public static func socialLogin(code: String,
                                   background: Bool = true,
                                     success: SuccessHandler? = nil,
                                     failed: ErrorHandler? = nil,
                                     completion: CompletionHandler? = nil) {
        let params: Params = ["client_id": client_id,
                              "client_secret": client_secret,
                              "grant_type": "code",
                              "code": code]
        
        Auth.authToken(params: params, background: background, success: success, failed: failed, completion: completion)
    }
    
    public static func requestMagic(mail: String,
                             background: Bool = true,
                             success: SuccessHandler? = nil,
                             failed: ErrorHandler? = nil,
                             completion: CompletionHandler? = nil) {
        let params: Params = ["email": mail]
        
        ConManager.POST(url_request_magic(),
                        params: params,
                        background: background,
                        success: { (response) in
                            success?(response)
                        }, failed: failed, completion: completion)
    }
    
    public static func magicLogin(code: String,
                                    background: Bool = true,
                                    success: SuccessHandler? = nil,
                                    failed: ErrorHandler? = nil,
                                    completion: CompletionHandler? = nil) {
        let params: Params = ["client_id": client_id,
                              "client_secret": client_secret,
                              "grant_type": "magic_link",
                              "code": code]
        
        Auth.authToken(params: params, background: background, success: success, failed: failed, completion: completion)
    }
    
    public static func requestResetPassword(mail: String,
                                    background: Bool = true,
                                    success: SuccessHandler? = nil,
                                    failed: ErrorHandler? = nil,
                                    completion: CompletionHandler? = nil) {
        let params: Params = ["email": mail]
        
        ConManager.POST(url_request_reset_password(),
                        params: params,
                        background: background,
                        success: { (response) in
                            success?(response)
        }, failed: failed, completion: completion)
    }
    
    public static func resetLogin(code: String,
                                  password: String,
                                  background: Bool = true,
                                  success: SuccessHandler? = nil,
                                  failed: ErrorHandler? = nil,
                                  completion: CompletionHandler? = nil) {
        let params: Params = ["client_id": client_id,
                              "client_secret": client_secret,
                              "grant_type": "password_reset",
                              "code": code,
                              "password": password]
        
        Auth.authToken(params: params, background: background, success: success, failed: failed, completion: completion)
    }
    
    public static func appOpenned(_ url: URL) -> Bool {
        if url.path.contains(url_request_magic_callback()) {
            // Magic link
            if let code = url.getQueryItemValueForKey("code") {
                Auth.magicLogin(code: code, background: false, success: { (response) in
                    print("MAGIC WORKING")
                })
                return true
            }
        }
        
        if url.path.contains(url_request_reset_password_callback()) {
            // Reset password
            if let code = url.getQueryItemValueForKey("code") {
                // Create the alert controller
                let alertController = UIAlertController(title: NSLocalizedString("Nuevo Password", comment: "reset password title"), message: NSLocalizedString("Introduce tu nuevo password", comment: "reset password messgae"), preferredStyle: .alert)
                
                //Add input
                alertController.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = NSLocalizedString("nuevo password", comment: "reset password placeholder")
                })
                
                // Create the actions
                let okAction = UIAlertAction(title: "Cambiar", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    NSLog("OK Pressed")
                    if let password = alertController.textFields?[0].text {
                        Auth.resetLogin(code: code, password: password, background: false, success: { (response) in
                            print("RESET WORKING")
                        })
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.cancel) {
                    UIAlertAction in
                    NSLog("Cancel Pressed")
                }
                
                
                
                // Add the actions
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                
                // Present the controller
                alertController.show()
                return true
            }
        }
        return false
/*
        print("URL: \(url.absoluteString)")
        //let nsurl = NSURL(string: url)
        print("scheme: \(url.scheme)")
        print("host: \(url.host)")
        print("port: \(url.port)")
        print("path: \(url.path)")
        print("path components: \(url.pathComponents)")
        //print("parameterString: \(url.parameterString)")
        print("query: \(url.query)")
        print("fragment: \(url.fragment)")
        return false
 */
    }
    
    
    
}
