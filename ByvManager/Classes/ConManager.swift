//
//  ByvConnectionManage.swift
//  Pods
//
//  Created by Adrian Apodaca on 26/10/16.
//
//

import Foundation
import Alamofire
import SVProgressHUD

public typealias Params = [String: Any]
public typealias ConError = (status: Int, error_id: String, error_description: String, localized_description: String, response: DataResponse<Data>?)
public typealias SuccessHandler = (_ response: DataResponse<Data>?) -> Void
public typealias ErrorHandler = (_ error: ConError) -> Void
public typealias CompletionHandler = () -> Void

public struct ConManager {
    
    /// Creates a `DataRequest` using the default `SessionManager` to retrieve the contents of the specified `url`,
    /// `method`, `parameters`, `encoding` and `headers`.
    ///
    /// - parameter url:        The URL.
    /// - parameter method:     The HTTP method. `.get` by default.
    /// - parameter parameters: The parameters. `nil` by default.
    /// - parameter encoding:   The parameter encoding. `URLEncoding.default` by default.
    /// - parameter headers:    The HTTP headers. `nil` by default.
    ///
    /// - returns: The created `DataRequest`.
    @discardableResult
    public static func request(
        _ path: URLConvertible,
        auth: Bool,
        method: HTTPMethod = .get,
        params: Params? = nil,
        encoding: ParameterEncoding,// = URLEncoding.default, // JSONEncoding.default
        sendDevice: Bool = true)
        -> DataRequest
    {
        var manager = SessionManager.default;
        manager.adapter = nil
        manager.retrier = nil
        if auth {
            let oAuthHandler = OAuthHandler()
            manager.adapter = oAuthHandler
            manager.retrier = oAuthHandler
        }
        
        var headers: HTTPHeaders? = nil
        if sendDevice, let dId = Device.id {
            headers = ["DeviceId": "\(dId)"]
        }
        
        var url = "\(Environment.baseUrl())/\(path)"
        if "\(path)".hasPrefix("http") {
            url = "\(path)"
        }
        return manager.request(
            url,
            method: method,
            parameters: params,
            encoding: encoding,
            headers: headers
        )
    }
    
    // MARK: - public methods
    
    public static func OPTIONS(_ path: URLConvertible,
                           params: Params? = nil,
                           auth: Bool = false,
                           encoding: ParameterEncoding,
                           background: Bool = true,
                           success: SuccessHandler? = nil,
                           failed: ErrorHandler? = nil,
                           completion: CompletionHandler? = nil) {
        ConManager.connection(path,
                              params: params,
                              method: .options,
                              auth: auth,
                              encoding: encoding,
                              background: background,
                              success: success,
                              failed: failed,
                              completion: completion)
    }
    
    public static func GET(_ path: URLConvertible,
                           params: Params? = nil,
                           auth: Bool = false,
                           background: Bool = true,
                           success: SuccessHandler? = nil,
                           failed: ErrorHandler? = nil,
                           completion: CompletionHandler? = nil) {
        ConManager.connection(path,
                              params: params,
                              method: .get,
                              auth: auth,
                              encoding: URLEncoding.default,
                              background: background,
                              success: success,
                              failed: failed,
                              completion: completion)
    }
    
    public static func LIST(_ path: URLConvertible,
                           params: Params? = nil,
                           auth: Bool = false,
                           background: Bool = true,
                           success: SuccessHandler? = nil,
                           failed: ErrorHandler? = nil,
                           completion: CompletionHandler? = nil) {
        ConManager.connection(path,
                              params: params,
                              method: .get,
                              auth: auth,
                              encoding: URLEncoding.default,
                              background: background,
                              success: success,
                              failed: failed,
                              completion: completion)
    }
    
    public static func HEAD(_ path: URLConvertible,
                           params: Params? = nil,
                           auth: Bool = false,
                           encoding: ParameterEncoding,
                           background: Bool = true,
                           success: SuccessHandler? = nil,
                           failed: ErrorHandler? = nil,
                           completion: CompletionHandler? = nil) {
        ConManager.connection(path,
                              params: params,
                              method: .head,
                              auth: auth,
                              encoding: encoding,
                              background: background,
                              success: success,
                              failed: failed,
                              completion: completion)
    }
    
    public static func POST(_ path: URLConvertible,
                           params: Params? = nil,
                           auth: Bool = false,
                           encoding: ParameterEncoding? = JSONEncoding.default,
                           background: Bool = true,
                           success: SuccessHandler? = nil,
                           failed: ErrorHandler? = nil,
                           completion: CompletionHandler? = nil) {
        ConManager.connection(path,
                              params: params,
                              method: .post,
                              auth: auth,
                              encoding: encoding!,
                              background: background,
                              success: success,
                              failed: failed,
                              completion: completion)
    }
    
    public static func PUT(_ path: URLConvertible,
                           params: Params? = nil,
                           auth: Bool = false,
                           encoding: ParameterEncoding? = JSONEncoding.default,
                           background: Bool = true,
                           success: SuccessHandler? = nil,
                           failed: ErrorHandler? = nil,
                           completion: CompletionHandler? = nil) {
        ConManager.connection(path,
                              params: params,
                              method: .put,
                              auth: auth,
                              encoding: encoding!,
                              background: background,
                              success: success,
                              failed: failed,
                              completion: completion)
    }
    
    public static func PATCH(_ path: URLConvertible,
                           params: Params? = nil,
                           auth: Bool = false,
                           encoding: ParameterEncoding? = JSONEncoding.default,
                           background: Bool = true,
                           success: SuccessHandler? = nil,
                           failed: ErrorHandler? = nil,
                           completion: CompletionHandler? = nil) {
        ConManager.connection(path,
                              params: params,
                              method: .patch,
                              auth: auth,
                              encoding: encoding!,
                              background: background,
                              success: success,
                              failed: failed,
                              completion: completion)
    }
    
    public static func DELETE(_ path: URLConvertible,
                           params: Params? = nil,
                           auth: Bool = false,
                           encoding: ParameterEncoding,
                           background: Bool = true,
                           success: SuccessHandler? = nil,
                           failed: ErrorHandler? = nil,
                           completion: CompletionHandler? = nil) {
        ConManager.connection(path,
                              params: params,
                              method: .delete,
                              auth: auth,
                              encoding: encoding,
                              background: background,
                              success: success,
                              failed: failed,
                              completion: completion)
    }
    
    public static func TRACE(_ path: URLConvertible,
                           params: Params? = nil,
                           auth: Bool = false,
                           encoding: ParameterEncoding,
                           background: Bool = true,
                           success: SuccessHandler? = nil,
                           failed: ErrorHandler? = nil,
                           completion: CompletionHandler? = nil) {
        ConManager.connection(path,
                              params: params,
                              method: .trace,
                              auth: auth,
                              encoding: encoding,
                              background: background,
                              success: success,
                              failed: failed,
                              completion: completion)
    }
    
    public static func CONNECT(_ path: URLConvertible,
                           params: Params? = nil,
                           auth: Bool = false,
                           encoding: ParameterEncoding,
                           background: Bool = true,
                           success: SuccessHandler? = nil,
                           failed: ErrorHandler? = nil,
                           completion: CompletionHandler? = nil) {
        ConManager.connection(path,
                              params: params,
                              method: .connect,
                              auth: auth,
                              encoding: encoding,
                              background: background,
                              success: success,
                              failed: failed,
                              completion: completion)
    }
    
    public static func connection(_ path: URLConvertible,
                           params: Params? = nil,
                           method: HTTPMethod = .get,
                           auth: Bool = false,
                           encoding: ParameterEncoding,
                           background: Bool = true,
                           success: SuccessHandler? = nil,
                           failed: ErrorHandler? = nil,
                           completion: CompletionHandler? = nil) {
        if !background {
            SVProgressHUD.show()
        }
        self.request(path, auth: auth, method: method, params: params, encoding: encoding, sendDevice: true)
        .validate(statusCode: 200..<300)
            .responseData { response in
                print("REQUEST:\nParams:")
                dump(params)
                debugPrint(response)
                var responseCode: Int = 500
                if let code = response.response?.statusCode {
                    responseCode = code
                }
                switch response.result {
                case .success:
                    if !background {
                        SVProgressHUD.dismiss()
                    }
                    success?(response)
                case .failure(let error):
                    if let data = response.data {
                        let result = String(data: data, encoding: .utf8)
                        print("Error(\(responseCode)): \(result)")
                        let err = ConManager.getError(response, _error: error, _code: responseCode)
                        if !background {
                            SVProgressHUD.showError(withStatus: err.localized_description)
                        }
                        failed?(err)
                    }
                }
                completion?()
        }
    }
    
    // MARK: - private
    
    private static func getError(_ response: DataResponse<Data>?, _error: Error, _code: Int ) -> ConError {
        var error:ConError = ConError(status: _code, error_id: "", error_description: "", localized_description: _error.localizedDescription, response: response)
        
        if let json = response?.result.value as? [String: Any] {
            if let status: Int = json["status"] as? Int {
                error.status = status
            }
            if let error_id: String = json["error_id"] as? String {
                error.error_id = error_id
            }
            if let error_description: String = json["error_description"] as? String {
                error.error_description = error_description
                error.localized_description = error_description
            }
            if let localized_description: String = json["localized_description"] as? String {
                error.localized_description = localized_description
            } else if let message: String = json["message"] as? String {
                error.localized_description = message
            }
        }
        return error
    }
}
